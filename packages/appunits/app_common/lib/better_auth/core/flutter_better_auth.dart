import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:app_common/better_auth/core/storage/custom_persist_cookie_jar.dart';
import 'package:app_common/better_auth/flutter_better_auth.dart';
import 'package:core/storage.dart';

import 'api/bearer_interceptor.dart';
import 'api/interceptor.dart';
import 'api/web_credentials.dart';
import 'storage/memory_storage.dart';

class FlutterBetterAuth {
  static BetterAuthClient? _client;
  static bool _initialized = false;
  static _BetterAuthLifecycleObserver? _lifecycleObserver;

  static late String baseUrl;
  static late Dio dioClient;
  static late StorageInterface? storage;
  static late CustomPersistCookieJar cookieJar;
  static String? appScheme;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static bool _wasOnline = true;

  // Better Auth `bearer` plugin: the session token captured from the
  // `set-auth-token` response header, sent as `Authorization: Bearer`.
  // Persisted through core's [SecureStore] port; the host injects the
  // platform keychain/keystore implementation at initialization.
  static const String _bearerKey = 'better_auth_bearer_token';
  static SecureStore? _secureStore;
  static String? _bearerToken;

  /// Current bearer token, if the server's `bearer` plugin issued one.
  static String? get bearerToken => _bearerToken;

  /// Persists a new bearer token (called by the interceptor).
  static void setBearerToken(String? token) {
    _bearerToken = token;
    final store = _secureStore;
    if (store == null) return;
    if (token == null || token.isEmpty) {
      unawaited(store.delete(_bearerKey).catchError((_) {}));
    } else {
      unawaited(store.write(_bearerKey, token).catchError((_) {}));
    }
  }

  static Future<void> initialize({
    required String url,
    Dio? dio,
    StorageInterface? store,

    /// Host-provided secure KV (keychain/keystore). When omitted, an
    /// in-memory store is used so the client still works in tests and previews;
    /// tokens then do not survive a restart.
    SecureStore? secureStore,

    /// Native deep-link scheme, for example `myapp`.
    ///
    /// Required for native social authentication. It is sent to Better Auth as
    /// `expo-origin` and used as the default OAuth callback scheme.
    String? scheme,

    /// Refresh the auth stream whenever the app returns to the foreground.
    bool refreshSessionOnAppResume = true,

    /// Refresh the auth stream whenever the device regains network
    /// connectivity (offline -> online transition). Mirrors the Expo
    /// online-manager behavior.
    bool refreshSessionOnReconnect = true,
  }) async {
    if (_initialized) return;
    _secureStore = secureStore ?? MemorySecureStore();
    baseUrl = url;
    appScheme = scheme;
    if (store == null && !kIsWeb) {
      // Encrypted, chunked cookie persistence by default on native platforms.
      storage = SecureStorage(store: _secureStore!);
    } else {
      storage = store;
    }
    dioClient =
        dio ??
        Dio(
          BaseOptions(
            headers: {
              'content-type': 'application/json',
              if (!kIsWeb) 'user-agent': 'FlutterBetterAuth/1.0.0',
            },
            validateStatus: (status) => status != null && status < 300,
          ),
        );
    final origin = scheme == null || scheme.isEmpty ? null : '$scheme://';
    dioClient.options.headers.putIfAbsent(
      'content-type',
      () => 'application/json',
    );
    if (!kIsWeb) {
      dioClient.options.headers.putIfAbsent(
        'user-agent',
        () => 'FlutterBetterAuth/1.0.0',
      );
    }
    dioClient.options.headers['x-skip-oauth-proxy'] = 'true';
    if (origin != null) {
      dioClient.options.headers['expo-origin'] = origin;
      // Better Auth's server reads the STANDARD `Origin` header (not
      // `expo-origin`) and rejects cookie-mutating endpoints — e.g. `signOut`
      // — with MISSING_OR_NULL_ORIGIN when it is absent. Native dart:io HTTP
      // clients send no Origin of their own, so mirror the trusted scheme
      // origin (which the backend lists in trustedOrigins) here. Skipped on
      // web, where the browser supplies Origin itself.
      if (!kIsWeb) {
        dioClient.options.headers['origin'] = origin;
      }
    }
    cookieJar = CustomPersistCookieJar(
      store: storage,
      storage: MemoryStorage(),
    );
    if (kIsWeb) {
      // The browser owns the Cookie header; let it persist/send cookies.
      enableWebCredentials(dioClient);
    } else {
      dioClient.interceptors.add(CookieManager(cookieJar));
    }
    // Bearer-token fallback (works cross-origin where cookies are blocked).
    try {
      _bearerToken = await _secureStore?.read(_bearerKey);
    } catch (_) {
      _bearerToken = null;
    }
    dioClient.interceptors.add(BearerTokenInterceptor());
    dioClient.interceptors.add(RemoveNullsInterceptor());
    dioClient.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          final path = response.requestOptions.path;
          final ok =
              (response.statusCode ?? 0) < 300; // sign-out may return 204
          if (ok) {
            if (path.contains('/sign-in') ||
                path.contains('/sign-up') ||
                path.contains('/update-user') ||
                path.contains('/change-email') ||
                path.contains('/change-password')) {
              unawaited(_refreshSession());
            } else if (path.contains('/sign-out')) {
              await cookieJar.clearFor(Uri.parse(baseUrl));
              setBearerToken(null);
              _authStreamController.add(null);
            }
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _authStreamController.add(null);
          }
          handler.next(error);
        },
      ),
    );
    _client = BetterAuthClient(dioClient, baseUrl: baseUrl);
    _initialized = true;
    if (refreshSessionOnAppResume) {
      _lifecycleObserver = _BetterAuthLifecycleObserver();
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    }
    if (refreshSessionOnReconnect && !kIsWeb) {
      _wasOnline = true;
      _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
        final online = results.any((r) => r != ConnectivityResult.none);
        // Only refetch on the offline -> online edge, not every change.
        if (online && !_wasOnline) {
          unawaited(_refreshSession());
        }
        _wasOnline = online;
      });
    }
  }

  @visibleForTesting
  static void reset() {
    final observer = _lifecycleObserver;
    if (observer != null) {
      WidgetsBinding.instance.removeObserver(observer);
    }
    _lifecycleObserver = null;
    unawaited(_connectivitySub?.cancel());
    _connectivitySub = null;
    _wasOnline = true;
    _bearerToken = null;
    _client = null;
    _initialized = false;
  }

  static final StreamController<User?> _authStreamController =
      StreamController<User?>.broadcast();
  static Stream<User?> get _onAuthChange => _authStreamController.stream;

  static Future<void> _refreshSession() async {
    try {
      final result = await client.getSession();
      result.maybeWhen(
        orElse: () {
          _authStreamController.add(null);
        },
        ok: (success) {
          _authStreamController.add(success?.user);
        },
        err: (error) {
          // The 401 interceptor emits signed-out state. Other errors may be
          // transient network failures and must not clear the current user.
        },
      );
    } catch (_) {}
  }

  static Future<void> refreshSession() => _refreshSession();

  static BetterAuthClient get client {
    assert(
      _initialized,
      'FlutterBetterAuth not initialized. Call initialize() first.',
    );
    return _client!;
  }
}

extension OnAuthChangeExtension on BetterAuthClient {
  Stream<User?> get onAuthChange => FlutterBetterAuth._onAuthChange;
}

class _BetterAuthLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(FlutterBetterAuth.refreshSession());
    }
  }
}

/// 认证层的 Riverpod 装配。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../../../app/network/ps_request_context.dart';
import '../data/auth_session_store.dart';
import '../data/planstar_auth_api.dart';
import '../data/remote_auth_repository.dart';
import '../domain/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

/// 会话存储（令牌进安全存储、资料进普通偏好）。
final authSessionStoreProvider = Provider<AuthSessionStore>(
  (ref) => AuthSessionStore(
    store: ref.watch(appStoreProvider),
    context: ref.watch(pnRequestContextProvider),
  ),
);

/// 登录接口客户端。
final planstarAuthApiProvider = Provider<PlanstarAuthApi>(
  (ref) => PlanstarAuthApi(
    client: ref.watch(apiClientProvider),
    clientType: ref.watch(apiConfigProvider).clientType,
  ),
);

/// 认证仓库端口。
///
/// 声明成 [AuthRepository] 而不是具体类：测试里用
/// `overrideWithValue(FakeAuthRepository())` 就能整层替换。
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => RemoteAuthRepository(
    api: ref.watch(planstarAuthApiProvider),
    store: ref.watch(authSessionStoreProvider),
    context: ref.watch(pnRequestContextProvider),
  ),
);

/// 登录状态。
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// 请求上下文（UI 侧偶尔需要读 `psSession`，例如分享/支付的 H5 链接）。
final requestContextProvider = Provider<PsRequestContext>(
  (ref) => ref.watch(pnRequestContextProvider),
);

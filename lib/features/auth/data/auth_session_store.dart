/// 会话的本地持久化。
///
/// 与来源 `lib\account\AccountService` 的读写对照：
///
/// | | 来源 | 这里 |
/// |---|---|---|
/// | 令牌 | `SharedPreferences("account")` 的 `psSession`，**明文** | `SecureStore` 的 `psSession`（Keystore/Keychain） |
/// | 资料 | 同一个 prefs 的 `profile`，`URLEncoder` 之后的 JSON | `KeyValueStore` 的 `profile`，纯 JSON |
/// | 损坏数据 | `read()` 无 try/catch → 启动即崩（23 页 §3.1） | 任何异常都返回 `null`（当作未登录） |
///
/// 三处差异都是有意的：
///
/// 1. **令牌进安全存储**：来源的 `psSession` 与 `profile` 一起躺在明文 prefs 里
///    （M6-05），root 设备可读；
/// 2. **不 URL 编码**：`URLEncoder` 会把昵称里的 `+` 变成空格（23 页 §3.2），
///    纯 JSON 没有这个问题；
/// 3. **坏数据不崩**：这是"启动即崩且没有降级路径"的直接修正。
library;

import 'dart:convert';

import 'package:core/storage.dart';
import 'package:flutter/foundation.dart';

import '../../../app/network/app_bootstrap.dart';
import '../../../app/network/ps_request_context.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';

/// 会话存储。
final class AuthSessionStore {
  /// 创建存储。
  AuthSessionStore({required AppStore store, required PsRequestContext context})
    : _store = store,
      _context = context;

  final AppStore _store;
  final PsRequestContext _context;

  /// 资料在普通偏好里的键（对齐来源 `SharedPreferences("account")` 的 `profile`）。
  static const String profileKey = 'profile';

  /// 读会话。没有、或数据损坏时返回 `null`。
  ///
  /// 读到令牌会顺手灌进 [PsRequestContext]，这样冷启动后的第一个请求就带
  /// `Cookie: psSession=…`——不需要调用方记得先"恢复会话再发请求"。
  Future<AuthSession?> read() async {
    try {
      final String? token = await _store.secure.read(psSessionStorageKey);
      final String? raw = await _store.preferences.read(profileKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<Object?, Object?>) {
        return null;
      }
      final profile = <String, Object?>{};
      decoded.forEach((Object? key, Object? value) => profile['$key'] = value);
      final user = AuthUser.fromJson(profile);
      if (!user.isValid) {
        return null;
      }
      if (token != null && token.isNotEmpty) {
        _context.psSession = token;
      }
      return AuthSession(user: user, token: token);
    } catch (error) {
      // 坏数据 = 未登录。**不要**把异常抛到启动路径上（23 页 §3.1）。
      debugPrint('[auth] 读取本地会话失败，按未登录处理：$error');
      return null;
    }
  }

  /// 写会话。令牌写安全存储，资料写普通偏好。
  Future<void> write(AuthSession session) async {
    final String? token = session.token;
    if (token != null && token.isNotEmpty) {
      await _store.secure.write(psSessionStorageKey, token);
      _context.psSession = token;
    }
    await _store.preferences.write(
      profileKey,
      jsonEncode(session.user.toJson()),
    );
  }

  /// 清会话。
  Future<void> clear() async {
    _context.clearSession();
    try {
      await _store.secure.delete(psSessionStorageKey);
      await _store.preferences.delete(profileKey);
    } catch (error) {
      debugPrint('[auth] 清理本地会话失败：$error');
    }
  }
}

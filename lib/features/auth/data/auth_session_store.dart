/// 会话的本地持久化。
///
/// 存储口径：
///
/// | | 位置 | 形式 |
/// |---|---|---|
/// | 令牌 | `SecureStore` 的 `psSession`（Keystore/Keychain） | 密文，不落明文 prefs |
/// | 资料 | `KeyValueStore` 的 `profile` | 纯 JSON，不做 URL 编码 |
/// | 损坏数据 | `read()` 全程 try/catch | 任何异常都返回 `null`（当作未登录） |
///
/// 三条都是有意的：
///
/// 1. **令牌进安全存储**：令牌与资料一起躺在明文 prefs 里时，root 设备
///    可以直接读走会话；
/// 2. **不 URL 编码**：表单式 URL 编码会把昵称里的 `+` 变成空格，
///    纯 JSON 没有这个问题；
/// 3. **坏数据不崩**：读盘失败必须有降级路径，不能"启动即崩且无处可退"。
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

  /// 资料在普通偏好里的键。
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
      // 坏数据 = 未登录。**不要**把异常抛到启动路径上。
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

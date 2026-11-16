import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 应用语言控制器。`null` 表示跟随系统，显式设置后覆盖系统语言。
///
/// 与 [ThemeModeController]（见 `app/theme.dart`）保持同一种形态：
/// 只维护内存状态，持久化留给后续接入 `package:core/storage.dart` 时
/// 在 [set] 里写入、在 [build] 里读回。
final class AppLocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  /// 显式设置语言；传 `null` 恢复跟随系统。
  void set(Locale? locale) => state = locale;
}

/// 全局语言覆盖（`null` = 跟随系统）。
final appLocaleProvider = NotifierProvider<AppLocaleController, Locale?>(
  AppLocaleController.new,
);

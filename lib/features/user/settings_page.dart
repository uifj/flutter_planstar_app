import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/ui/ps_cell.dart';
import '../auth/application/auth_providers.dart';
import 'application/profile_providers.dart';
import '../../l10n/user_localizations.dart';
import '../../l10n/app_localizations.dart';

/// 设置页（企划星 `MoreSettingActivity` + `MoreSettingFragment`）。
///
/// ## 为什么放在 `user` 而不是 `app`
///
/// 它是"我的"里的二级页，入口在个人中心，数据（昵称/手机号）也来自
/// `userProfileProvider`，所以留在 `user` 里。只有 [themeModeProvider] 是
/// app 级的——主题模式不属于任何 feature，放在 `app/theme.dart` 是对的，
/// 这里 import 它是**跨层但单向**的依赖（feature → app 的主题状态），
/// 反过来 app 不依赖 user。
///
/// ## 与 Android 的差异
///
/// - 原页有 12 个入口（含"清除缓存""检查更新""关于""账号安全"等），
///   这里只保留**当前有真实行为**的几项：深色模式（真的切换）、退出登录
///   （真的清会话）、其余用 toast 说明"待接入"而不是做成点不动的死链。
/// - **不做"清除缓存"的实际清理**：`package:core/cache.dart` 的 `HttpCacheStore` 有
///   `clear()`，但这里没有注入实例，写一个假成功提示会误导。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// 与 `pubspec.yaml` 的 `version:` 保持一致。
  /// 正式实现应改用 `PackageInfo.fromPlatform()`——这里避免为一个字符串
  /// 引入新依赖。
  static const String _appVersion = '9.9.39';

  /// 消息通知开关（本地状态，未落盘）。
  bool _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final UserProfile profile = ref.watch(userProfileProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final bool loggedIn = ref.watch(authControllerProvider).isLoggedIn;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: UserLocalizations.of(context).settingsPage_53),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 32),
        children: <Widget>[
          _Group(
            children: <Widget>[
              PsCell(
                label: UserLocalizations.of(context).settingsPage_60,
                value: profile.nickname,
                onTap: loggedIn
                    ? () => context.push('/me/edit-profile')
                    : () => _toast(UserLocalizations.of(context).settingsPage_64),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_67,
                value: profile.mobileLabel ?? UserLocalizations.of(context).settingsPage_68,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_69),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_72,
                onTap: () => context.push('/feedback'),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_76,
                value: UserLocalizations.of(context).settingsPage_77,
                showDivider: false,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_79),
              ),
            ],
          ),
          _Group(
            children: <Widget>[
              PsCell(
                label: UserLocalizations.of(context).settingsPage_86,
                trailing: Switch.adaptive(
                  value: _pushEnabled,
                  activeTrackColor: colors.brand,
                  onChanged: (bool value) =>
                      setState(() => _pushEnabled = value),
                ),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_95,
                value: _themeModeLabel(themeMode),
                // 三态循环：跟随系统 → 亮 → 暗 → 跟随系统。
                onTap: () => ref.read(themeModeProvider.notifier).set(
                  switch (themeMode) {
                    ThemeMode.system => ThemeMode.light,
                    ThemeMode.light => ThemeMode.dark,
                    ThemeMode.dark => ThemeMode.system,
                  },
                ),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_107,
                value: UserLocalizations.of(context).settingsPage_108,
                showDivider: false,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_110),
              ),
            ],
          ),
          _Group(
            children: <Widget>[
              PsCell(
                label: UserLocalizations.of(context).settingsPage_117,
                value: _appVersion,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_119),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_122,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_123),
              ),
              PsCell(
                label: UserLocalizations.of(context).settingsPage_126,
                showDivider: false,
                onTap: () => _toast(UserLocalizations.of(context).settingsPage_128),
              ),
            ],
          ),
          if (loggedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _confirmLogout,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    UserLocalizations.of(context).userLogout,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.error,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => UserLocalizations.of(context).settingsPage_162,
    ThemeMode.light => '关闭',
    ThemeMode.dark => UserLocalizations.of(context).settingsPage_164,
  };

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(UserLocalizations.of(context).userLogout),
        content: Text(UserLocalizations.of(context).settingsPage_172),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(UserLocalizations.of(context).settingsPage_180),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    _toast(UserLocalizations.of(context).settingsPage_188);
    context.go('/me');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 白底分组（上下留 8dp 间距）。
class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(children: children),
    );
  }
}

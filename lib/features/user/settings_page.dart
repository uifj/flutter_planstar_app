import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/theme.dart';
import '../../shared/ui/ps_cell.dart';
import '../auth/application/auth_providers.dart';
import 'application/profile_providers.dart';
import '../../l10n/l10n.dart';

/// 设置页。
///
/// ## 为什么放在 `user` 而不是 `app`
///
/// 它是"我的"里的二级页，入口在个人中心，数据（昵称/手机号）也来自
/// `userProfileProvider`，所以留在 `user` 里。只有 [themeModeProvider] 是
/// app 级的——主题模式不属于任何 feature，放在 `app/theme.dart` 是对的，
/// 这里 import 它是**跨层但单向**的依赖（feature → app 的主题状态），
/// 反过来 app 不依赖 user。
///
/// ## 设计取舍
///
/// - 设置入口不做全集（"清除缓存""检查更新""关于""账号安全"等），
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
  static const String _appVersion = '1.0.1';

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
      appBar: AdaptiveAppBar(title: context.l10n.settingsPage_53),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        children: <Widget>[
          _Group(
            title: context.l10n.settingsPageGroupAccount,
            children: <Widget>[
              PsCell(
                leading: Icon(
                  LucideIcons.user,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_60,
                value: profile.nickname.isEmpty
                    ? (loggedIn
                          ? context.l10n.authUser_119
                          : context.l10n.profileProviders_58)
                    : profile.nickname,
                onTap: loggedIn
                    ? () => context.push('/me/edit-profile')
                    : () => _toast(context.l10n.settingsPage_64),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.smartphone,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_67,
                value: profile.mobileLabel ?? context.l10n.settingsPage_68,
                onTap: () => _toast(context.l10n.settingsPage_69),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.messageCircle,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_72,
                onTap: () => context.push('/feedback'),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.idCard,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_76,
                value: context.l10n.settingsPage_77,
                showDivider: false,
                onTap: () => _toast(context.l10n.settingsPage_79),
                horizontalPadding: AppSpacing.md,
              ),
            ],
          ),
          _Group(
            title: context.l10n.settingsPageGroupGeneral,
            children: <Widget>[
              PsCell(
                leading: Icon(
                  LucideIcons.bell,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_86,
                trailing: Switch.adaptive(
                  value: _pushEnabled,
                  activeTrackColor: colors.brand,
                  onChanged: (bool value) =>
                      setState(() => _pushEnabled = value),
                ),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.moon,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_95,
                value: _themeModeLabel(themeMode),
                // 三态循环：跟随系统 → 亮 → 暗 → 跟随系统。
                onTap: () => ref.read(themeModeProvider.notifier).set(
                  switch (themeMode) {
                    ThemeMode.system => ThemeMode.light,
                    ThemeMode.light => ThemeMode.dark,
                    ThemeMode.dark => ThemeMode.system,
                  },
                ),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_107,
                value: context.l10n.settingsPage_108,
                showDivider: false,
                onTap: () => _toast(context.l10n.settingsPage_110),
                horizontalPadding: AppSpacing.md,
              ),
            ],
          ),
          _Group(
            title: context.l10n.settingsPageGroupAbout,
            children: <Widget>[
              PsCell(
                leading: Icon(
                  LucideIcons.info,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_117,
                value: _appVersion,
                onTap: () => _toast(context.l10n.settingsPage_119),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.fileText,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_122,
                onTap: () => _toast(context.l10n.settingsPage_123),
                horizontalPadding: AppSpacing.md,
              ),
              PsCell(
                leading: Icon(
                  LucideIcons.shield,
                  size: 18,
                  color: colors.textSecondary,
                ),
                label: context.l10n.settingsPage_126,
                showDivider: false,
                onTap: () => _toast(context.l10n.settingsPage_128),
                horizontalPadding: AppSpacing.md,
              ),
            ],
          ),
          if (loggedIn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _confirmLogout,
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.bgCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    context.l10n.userLogout,
                    style: TextStyle(
                      fontSize: 16,
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
    ThemeMode.system => context.l10n.settingsPage_162,
    ThemeMode.light => context.l10n.settingsPageDarkModeOff,
    ThemeMode.dark => context.l10n.settingsPage_164,
  };

  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(context.l10n.userLogout),
        content: Text(context.l10n.settingsPage_172),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.settingsPage_180),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    _toast(context.l10n.settingsPage_188);
    context.go('/me');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 白底分组卡片（左右 16 边距、圆角 12），可选分组标题（caption + 三级文字色）。
class _Group extends StatelessWidget {
  const _Group({required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: AppTypography.caption,
                  color: colors.textTertiary,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

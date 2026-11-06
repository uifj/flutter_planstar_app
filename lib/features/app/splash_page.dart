import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

/// 隐私协议同意状态。
///
/// 企划星用 `PrivacyHelper`（SharedPreferences 存储）。
/// 这里用 Riverpod 内存状态——应用重启后需要重新同意。
/// 接入 `shared_preferences` 持久化时只需把 `StateProvider` 换成
/// `StateNotifierProvider` + `SharedPreferences` 读写。
final privacyAgreedProvider = StateProvider<bool>((ref) => false);

/// 隐私协议 + 启动页（企划星 `PrivacyActivity` + `SplashActivity`）。
///
/// ## 企划星的启动流程
///
/// 1. `PrivacyActivity`（LAUNCHER）：检查是否已同意隐私协议。
///    - 已同意 → 跳 `SplashActivity`，这里 finish。
///    - 未同意 → 弹隐私协议弹窗，同意后跳 Splash，不同意进浏览模式。
/// 2. `SplashActivity`：品牌广告屏（视频/图片 + 倒计时 + 跳过），
///    倒计时结束后进 `MainActivity`。
///
/// ## Flutter 实现
///
/// 把两步合成一个页面：
/// - **未同意隐私协议** → 弹隐私协议弹窗，同意后进首页；
/// - **已同意** → 品牌启动屏（Logo + slogan + 2 秒后自动进首页）。
///
/// ## 与 Android 的差异
///
/// - 不做广告视频/图片轮播：需要运营素材和 CDN。
/// - 不做倒计时跳过按钮：没有广告就没有倒计时的必要。
/// - 不做"浏览模式"（不同意隐私协议时的降级浏览）：
///   企划星的浏览模式是一套独立的只读列表，本项目不做。
/// - 隐私同意状态用内存 `StateProvider` 存储（重启需重新同意），
///   接入 `shared_preferences` 后可持久化。
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndNavigate());
  }

  void _checkAndNavigate() {
    if (!mounted) return;
    final agreed = ref.read(privacyAgreedProvider);

    if (!agreed) {
      // 未同意 → 显示隐私弹窗。
      _showPrivacyDialog();
      return;
    }

    // 已同意 → 2 秒后进首页。
    Future<void>.delayed(const Duration(seconds: 2)).then((_) {
      if (!mounted) return;
      context.go('/');
    });
  }

  void _showPrivacyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PrivacyDialog(
        onAgree: () {
          ref.read(privacyAgreedProvider.notifier).state = true;
          Navigator.of(dialogContext).pop();
          // 同意后进首页。
          context.go('/');
        },
        onDisagree: () {
          Navigator.of(dialogContext).pop();
          // 不同意 → 退出应用。
          // 企划星进浏览模式；浏览模式是独立的只读列表，本项目不做。
          SystemNavigator.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      child: AdaptiveScaffold(
        backgroundColor: colors.brand,
        body: Stack(
          children: <Widget>[
            // 品牌 logo 居中
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).appTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.brand,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).splashPage_129,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // 底部版权信息
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding + 20,
              child: Column(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).splashPage_146,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All rights reserved.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 隐私协议弹窗。
class _PrivacyDialog extends StatelessWidget {
  const _PrivacyDialog({required this.onAgree, required this.onDisagree});

  final VoidCallback onAgree;
  final VoidCallback onDisagree;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).splashPage_180),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).splashPage_187,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            _Bullet(
              text: AppLocalizations.of(context).splashPage_192,
            ),
            _Bullet(
              text: AppLocalizations.of(context).splashPage_195,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).splashPage_199,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onDisagree,
          child: Text(AppLocalizations.of(context).splashPage_208),
        ),
        FilledButton(
          onPressed: onAgree,
          child: Text(AppLocalizations.of(context).splashPage_212),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('· ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

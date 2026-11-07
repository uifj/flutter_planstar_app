import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../l10n/l10n.dart';
import '../application/bilibili_launcher.dart';

/// 视频播放方式选择面板。
///
/// 只在能拿到 bvid 时展示：应用内用 WebView 加载官方播放页，
/// 或者直接拉起哔哩哔哩客户端。客户端未安装时由 `openInApp` 降级到浏览器，
/// 这里再提示用户，并提供改走应用内播放的入口。
Future<void> showBilibiliSheet(
  BuildContext context, {
  required String bvid,
}) async {
  final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
  final String normalized = extractBvid(bvid) ?? bvid;

  final _BilibiliAction? action = await showModalBottomSheet<_BilibiliAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => Container(
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sheetContext.l10n.bilibiliOpenSheet_32,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _SheetAction(
              icon: LucideIcons.monitorPlay,
              label: sheetContext.l10n.bilibiliOpenSheet_41,
              onTap: () =>
                  Navigator.of(sheetContext).pop(_BilibiliAction.inApp),
            ),
            _SheetAction(
              icon: LucideIcons.externalLink,
              label: sheetContext.l10n.bilibiliOpenSheet_46,
              onTap: () =>
                  Navigator.of(sheetContext).pop(_BilibiliAction.external),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  sheetContext.l10n.actionCancel,
                  style: TextStyle(color: colors.textTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  switch (action) {
    case _BilibiliAction.inApp:
      context.push('/bilibili/${Uri.encodeComponent(normalized)}');
    case _BilibiliAction.external:
      final BilibiliOpenResult result = await openInApp(normalized);
      if (!context.mounted) return;
      if (result == BilibiliOpenResult.openedInBrowser) {
        _notify(
          context,
          message: context.l10n.bilibiliOpenSheet_72,
          actionLabel: context.l10n.bilibiliOpenSheet_41,
          onAction: () {
            if (context.mounted) {
              context.push('/bilibili/${Uri.encodeComponent(normalized)}');
            }
          },
        );
      } else if (result == BilibiliOpenResult.failed) {
        _notify(context, message: context.l10n.bilibiliOpenSheet_80);
      }
  }
}

void _notify(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}

enum _BilibiliAction { inApp, external }

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: colors.textSecondary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

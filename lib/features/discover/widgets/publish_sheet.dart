import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';

/// 发布动态面板（对应企划星发现页右下角的 `btnNewPost`）。
///
/// 只做最小可用闭环：写文字 → 发布 → 插到热门流头部。
/// 图片/视频/关联演出都不做——那需要上传服务与演出选择器，
/// 在半成品状态放出入口比没有入口更糟。
class PublishSheet extends StatefulWidget {
  const PublishSheet({super.key, required this.onPublish});

  final void Function(String title) onPublish;

  static Future<void> show(
    BuildContext context, {
    required void Function(String title) onPublish,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PublishSheet(onPublish: onPublish),
    );
  }

  @override
  State<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<PublishSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _canPublish = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim().isNotEmpty;
      if (next != _canPublish) setState(() => _canPublish = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    context.l10n.publishSheet_69,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      context.l10n.actionCancel,
                      style: TextStyle(color: colors.textTertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.bgSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 5,
                  maxLength: 120,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: context.l10n.publishSheet_98,
                    counterStyle: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: _canPublish
                      ? () {
                          widget.onPublish(_controller.text);
                          Navigator.of(context).maybePop();
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.brand,
                    disabledBackgroundColor: colors.brandDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    context.l10n.publishSheet_122,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

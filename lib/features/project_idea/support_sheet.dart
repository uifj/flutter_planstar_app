import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../project_idea/model/project_idea.dart';
import 'project_idea_feedback.dart';

/// 支持档位（仅表达意愿，不扣星币）。
const List<int> ideaSupportTiers = <int>[5, 10, 20];

/// 支持理由上限（Spec §4.5）。
const int ideaSupportReasonMaxLength = 60;

/// 一次支持的提交参数。
final class SupportSelection {
  const SupportSelection({required this.tier, required this.reason});

  /// 意愿档位：5 / 10 / 20 星币。
  final int tier;

  /// 可选文字理由（≤60 字，未填为空串）。
  final String reason;
}

typedef SupportSubmitCallback =
    Future<IdeaVoteResult> Function(SupportSelection selection);

/// 支持弹窗（`showModalBottomSheet`）。
///
/// 提交动作由 [onSubmit] 注入：叠卡页与详情页各自决定走哪个 Provider，
/// 组件本身只负责表单状态与 loading，因此可以直接在 widget test 里用假回调
/// 驱动，不依赖网络。
class SupportSheet extends StatefulWidget {
  const SupportSheet({super.key, required this.onSubmit, this.onError});

  /// 提交回调；抛出异常时保留弹窗内容并提示。
  final SupportSubmitCallback onSubmit;

  /// 提交失败时通知调用方（叠卡页用来让卡片回弹）。
  final VoidCallback? onError;

  /// 弹出面板；取消返回 `null`，成功返回接口结果。
  static Future<IdeaVoteResult?> show(
    BuildContext context, {
    required SupportSubmitCallback onSubmit,
    VoidCallback? onError,
  }) {
    return showModalBottomSheet<IdeaVoteResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SupportSheet(onSubmit: onSubmit, onError: onError),
    );
  }

  @override
  State<SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends State<SupportSheet> {
  final TextEditingController _reason = TextEditingController();
  int _tier = ideaSupportTiers.first;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // 字数计数依赖输入内容，直接 setState 重建整块即可（输入量很小）。
    _reason.addListener(_handleReasonChanged);
  }

  @override
  void dispose() {
    _reason.removeListener(_handleReasonChanged);
    _reason.dispose();
    super.dispose();
  }

  void _handleReasonChanged() => setState(() {});

  void _appendTag(String tag) {
    if (_submitting) return;
    final current = _reason.text.trim();
    if (current.contains(tag)) return;
    final next = current.isEmpty ? tag : '$current，$tag';
    final clamped = next.length > ideaSupportReasonMaxLength
        ? next.substring(0, ideaSupportReasonMaxLength)
        : next;
    _reason.value = TextEditingValue(
      text: clamped,
      selection: TextSelection.collapsed(offset: clamped.length),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final result = await widget.onSubmit(
        SupportSelection(tier: _tier, reason: _reason.text.trim()),
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = ideaVoteErrorText(context, error);
      });
      widget.onError?.call();
      showIdeaToast(context, _errorText!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = context.l10n;

    return Padding(
      // 键盘弹起时把面板顶上去，否则理由输入框会被挡住。
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.supportSheetTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      icon: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.supportSheetSubtitle,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    for (final int tier in ideaSupportTiers) ...<Widget>[
                      if (tier != ideaSupportTiers.first)
                        const SizedBox(width: 10),
                      Expanded(child: _buildTier(context, tier)),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                // 免责说明是 Spec 的硬要求：档位数字必须和后端"不扣费"语义
                // 同时出现，否则用户会以为是付费按钮。
                Row(
                  key: const ValueKey<String>('support-disclaimer'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(LucideIcons.info, size: 14, color: colors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.supportDisclaimer,
                        style: TextStyle(fontSize: 12, color: colors.warning),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const ValueKey<String>('support-reason-field'),
                  controller: _reason,
                  enabled: !_submitting,
                  maxLength: ideaSupportReasonMaxLength,
                  maxLines: 3,
                  minLines: 2,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.supportReasonHint,
                    filled: true,
                    fillColor: colors.bgPage,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    counterStyle: TextStyle(
                      fontSize: 11,
                      color: colors.textDisabled,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _buildTag(context, l10n.supportReasonCreative),
                    _buildTag(context, l10n.supportReasonJoin),
                    _buildTag(context, l10n.supportReasonLaunch),
                  ],
                ),
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    _errorText!,
                    style: TextStyle(fontSize: 12, color: colors.error),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          minimumSize: const Size(0, 46),
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: Text(l10n.actionCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey<String>('support-submit'),
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.brand,
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onBrand,
                                ),
                              )
                            : Text(l10n.supportSubmit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTier(BuildContext context, int tier) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final selected = _tier == tier;
    return InkWell(
      key: ValueKey<String>('support-tier-$tier'),
      onTap: _submitting ? null : () => setState(() => _tier = tier),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgPage,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? colors.brand : colors.border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          context.l10n.ideaTierOption(tier),
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.brand : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final selected = _reason.text.contains(tag);
    return InkWell(
      onTap: _submitting ? null : () => _appendTag(tag),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgPage,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: selected ? colors.brand : colors.border),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 12,
            color: selected ? colors.brand : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

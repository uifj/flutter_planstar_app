import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/l10n.dart';
import '../project_idea/model/project_idea.dart';
import 'project_idea_feedback.dart';

/// 不支持的标准理由（Spec §4.6）。`code` 与后端理由字典一致。
enum IdeaOpposeReason {
  notInterested('not_interested'),
  tooManySimilar('too_many_similar'),
  notEnoughInfo('not_enough_info'),
  notExecutable('not_executable'),
  unreasonablePricing('unreasonable_pricing'),
  other('other');

  const IdeaOpposeReason(this.code);

  /// 后端理由码（`reasonCode`）。
  final String code;

  String labelOf(BuildContext context) => switch (this) {
    IdeaOpposeReason.notInterested => context.l10n.opposeReasonNotInterested,
    IdeaOpposeReason.tooManySimilar => context.l10n.opposeReasonTooManySimilar,
    IdeaOpposeReason.notEnoughInfo => context.l10n.opposeReasonNotEnoughInfo,
    IdeaOpposeReason.notExecutable => context.l10n.opposeReasonNotExecutable,
    IdeaOpposeReason.unreasonablePricing =>
      context.l10n.opposeReasonUnreasonablePricing,
    IdeaOpposeReason.other => context.l10n.opposeReasonOther,
  };
}

/// 一次不支持的提交参数。
final class OpposeSelection {
  const OpposeSelection({required this.reasonCode, required this.reasonText});

  final String reasonCode;
  final String reasonText;
}

typedef OpposeSubmitCallback =
    Future<IdeaVoteResult> Function(OpposeSelection selection);

/// 不支持理由上限（Spec §4.6）。
const int ideaOpposeReasonMaxLength = 100;

/// 不支持弹窗。
///
/// 与 [SupportSheet] 一样，提交由 [onSubmit] 注入，组件本身可在 widget test
/// 里用假回调直接驱动。
class OpposeSheet extends StatefulWidget {
  const OpposeSheet({super.key, required this.onSubmit, this.onError});

  final OpposeSubmitCallback onSubmit;
  final VoidCallback? onError;

  static Future<IdeaVoteResult?> show(
    BuildContext context, {
    required OpposeSubmitCallback onSubmit,
    VoidCallback? onError,
  }) {
    return showModalBottomSheet<IdeaVoteResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OpposeSheet(onSubmit: onSubmit, onError: onError),
    );
  }

  @override
  State<OpposeSheet> createState() => _OpposeSheetState();
}

class _OpposeSheetState extends State<OpposeSheet> {
  final TextEditingController _reasonText = TextEditingController();
  IdeaOpposeReason? _reason;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _reasonText.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _reasonText.removeListener(_handleTextChanged);
    _reasonText.dispose();
    super.dispose();
  }

  void _handleTextChanged() => setState(() {});

  /// 「其他」必须填写自定义理由；其余选项的自定义输入是可选的。
  bool get _canSubmit {
    if (_submitting || _reason == null) return false;
    if (_reason == IdeaOpposeReason.other) {
      return _reasonText.text.trim().isNotEmpty;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final reason = _reason!;
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final result = await widget.onSubmit(
        OpposeSelection(
          reasonCode: reason.code,
          reasonText: _reasonText.text.trim(),
        ),
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
                        l10n.opposeSheetTitle,
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
                  l10n.opposeSheetSubtitle,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
                const SizedBox(height: 12),
                for (final IdeaOpposeReason reason in IdeaOpposeReason.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildReason(context, reason),
                  ),
                if (_reason != null) ...<Widget>[
                  const SizedBox(height: 4),
                  TextField(
                    key: const ValueKey<String>('oppose-reason-field'),
                    controller: _reasonText,
                    enabled: !_submitting,
                    maxLength: ideaOpposeReasonMaxLength,
                    maxLines: 3,
                    minLines: 2,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.opposeReasonTextHint,
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
                ],
                if (_errorText != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: TextStyle(fontSize: 12, color: colors.error),
                  ),
                ],
                const SizedBox(height: 16),
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
                        key: const ValueKey<String>('oppose-submit'),
                        onPressed: _canSubmit ? _submit : null,
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
                            : Text(l10n.opposeSubmit),
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

  Widget _buildReason(BuildContext context, IdeaOpposeReason reason) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final selected = _reason == reason;
    return InkWell(
      key: ValueKey<String>('oppose-reason-${reason.code}'),
      onTap: _submitting ? null : () => setState(() => _reason = reason),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? colors.brandSubtle : colors.bgPage,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? colors.brand : colors.border,
            width: selected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                reason.labelOf(context),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? colors.brand : colors.textPrimary,
                ),
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 18,
              color: selected ? colors.brand : colors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

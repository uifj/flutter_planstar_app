import 'package:core/result.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// 表态失败 → 用户可读文案（Spec §4.8 / Task 6）。
///
/// 只有四类值得单独翻译：作者自投（403）、频控（429）、网络/超时、其余
/// 服务端业务错误。服务端已经给了中文原文的业务错误直接透传，避免把
/// 「参数不合法」这类具体原因吞成一句笼统的"操作失败"。
String ideaVoteErrorText(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is Failure) {
    if (error.statusCode == 403 || error.code.contains('SELF_VOTE')) {
      return l10n.ideaErrorSelfVote;
    }
    if (error.statusCode == 429 || error.code.contains('TOO_MANY')) {
      return l10n.ideaErrorTooFrequent;
    }
    if (error.type == FailureType.network ||
        error.type == FailureType.timeout) {
      return l10n.ideaErrorNetwork;
    }
    return error.message.isEmpty ? l10n.ideaErrorNetwork : error.message;
  }
  return l10n.ideaErrorNetwork;
}

/// 统一 Toast（叠卡页与详情页共用）。先收起上一条，避免连续操作时排队。
void showIdeaToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

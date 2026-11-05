import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 首页服务保障条（`view_home_guarantee.xml`）。
///
/// 26dp 高、白底 + 1dp `#f3f3f3` 描边 + 8dp 圆角、左右与上边距 15dp。
/// 内容是一排 12sp `text_131415` 的承诺项，项与项之间夹 1dp 竖线。
/// 企划星的文案由服务端下发（`HomeGuaranteeBean.items`，最多渲染 4 项），
/// 这里用同一批固定文案——它们是平台级承诺，不随运营变化。
class HomeGuaranteeFloor extends StatelessWidget {
  const HomeGuaranteeFloor({
    super.key,
    this.items = const <String>['100%真票', '无票赔付', '出票保真', '配送保障'],
    this.onTap,
  });

  final List<String> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final shown = items.take(4).toList(growable: false);
    if (shown.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 26,
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.divider, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (var i = 0; i < shown.length; i++) ...<Widget>[
                if (i > 0) Container(width: 1, height: 10, color: colors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    shown[i],
                    style: TextStyle(fontSize: 12, height: 1.1, color: colors.textPrimary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

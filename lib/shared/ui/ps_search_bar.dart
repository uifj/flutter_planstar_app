import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// 首页搜索栏（`home_search_bar.xml`）。
///
/// 尺寸全部来自原 layout：整条 36dp、白底 + 1.5dp 品牌色描边 + 8dp 圆角；
/// 左侧城市 13sp 粗体 `text_0`（带下拉箭头）；中间 1dp `#ffd9d9d9` 分隔线（18dp 高）；
/// 提示文案 13sp `text_2`；右侧「搜索」按钮 13sp 粗体白字、品牌红底、6dp 圆角、
/// 左右 14dp 内边距、四周 3dp 外边距。
///
/// 提示文案用**滚动轮播**而不是静态文字：企划星这里挂的是 `MarqueeView`
/// （`mvDirection=bottom_to_top`、`mvInterval=5000`、`mvAnimDuration=500`），
/// 用来轮播热门搜索词。静态文字会丢掉这个"轮播热搜"的信息量。
class PsSearchBar extends StatelessWidget {
  const PsSearchBar({
    super.key,
    required this.city,
    required this.hints,
    this.onTapCity,
    this.onTapSearch,
    this.onTapField,
    this.hint,
  });

  final String city;

  /// 轮播的热搜词。
  final List<String> hints;

  final VoidCallback? onTapCity;
  final VoidCallback? onTapSearch;
  final VoidCallback? onTapField;

  /// 没有热搜词时显示的静态占位；`null` 时用默认文案。
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.brand, width: 1.5),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapCity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    city,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (onTapCity != null)
                    Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: colors.textPrimary,
                    ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 18, color: colors.border),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapField,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: hints.isEmpty
                    ? Text(
                        hint ?? context.l10n.psSearchBar_25,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textTertiary,
                        ),
                      )
                    : _MarqueeHint(hints: hints),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapSearch,
            child: Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                context.l10n.psSearchBar_104,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 自下而上的文字轮播（`MarqueeView` 的最小等价实现）。
class _MarqueeHint extends StatefulWidget {
  const _MarqueeHint({required this.hints});

  final List<String> hints;

  @override
  State<_MarqueeHint> createState() => _MarqueeHintState();
}

class _MarqueeHintState extends State<_MarqueeHint> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant _MarqueeHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hints.length != widget.hints.length) {
      _index = 0;
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    if (widget.hints.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.hints.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return ClipRect(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Align(
          key: ValueKey<int>(_index),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.hints[_index % widget.hints.length],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: colors.textTertiary),
          ),
        ),
      ),
    );
  }
}

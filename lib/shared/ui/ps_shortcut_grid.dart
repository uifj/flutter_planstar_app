import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 一个快捷入口。
///
/// 分类图标不用位图：本地图片资源已移除，快捷入口统一用 Lucide 矢量图标。
/// 这里用矢量图标 + 品牌色淡底圆角块，
/// 尺寸与排版为 40×40 图标位 + 4dp 间距 + 11sp 文案。
class PsShortcut {
  const PsShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  /// 图标底色；`null` 时按 [icon] 的哈希从品牌色系里派生。
  final Color? color;
}

/// 首页快捷入口宫格。
///
/// - 5 列 × 2 行一页；
/// - 每项 50dp 宽、图标 40×40、文案 11sp；
/// - 超过一页时显示 20×4 的指示器（`#ffe6e6e6` 轨道 + 12dp `#ffff2261` 滑块）。
///
/// 指示器只在 `pages > 1` 时渲染：只有一页还画一条静止的滑块，
/// 会让用户以为可以左滑。
class PsShortcutGrid extends StatefulWidget {
  const PsShortcutGrid({
    super.key,
    required this.items,
    this.columns = 5,
    this.rowsPerPage = 2,
    this.horizontalPadding = 12,
  });

  final List<PsShortcut> items;
  final int columns;
  final int rowsPerPage;
  final double horizontalPadding;

  @override
  State<PsShortcutGrid> createState() => _PsShortcutGridState();
}

class _PsShortcutGridState extends State<PsShortcutGrid> {
  static const double _itemHeight = 59;
  static const double _rowGap = 8;

  final PageController _controller = PageController();
  int _page = 0;

  int get _perPage => widget.columns * widget.rowsPerPage;

  int get _pageCount {
    if (widget.items.isEmpty) return 1;
    return (widget.items.length + _perPage - 1) ~/ _perPage;
  }

  double get _pageHeight =>
      widget.rowsPerPage * _itemHeight + (widget.rowsPerPage - 1) * _rowGap;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: _pageHeight,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, page) {
                final start = page * _perPage;
                final slice = widget.items
                    .skip(start)
                    .take(_perPage)
                    .toList(growable: false);
                return _ShortcutPage(
                  items: slice,
                  columns: widget.columns,
                  itemHeight: _itemHeight,
                  rowGap: _rowGap,
                  horizontalPadding: widget.horizontalPadding,
                );
              },
            ),
          ),
          if (_pageCount > 1) ...<Widget>[
            const SizedBox(height: 6),
            // 指示器：20×4 圆角轨道，滑块 12dp。
            Container(
              width: 20,
              height: 4,
              decoration: BoxDecoration(
                color: colors.skeleton,
                borderRadius: BorderRadius.circular(2),
              ),
              alignment: Alignment.centerLeft,
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _pageCount == 1
                    ? Alignment.centerLeft
                    : Alignment(-1 + 2 * _page / (_pageCount - 1), 0),
                child: Container(
                  width: 12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.brand,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShortcutPage extends StatelessWidget {
  const _ShortcutPage({
    required this.items,
    required this.columns,
    required this.itemHeight,
    required this.rowGap,
    required this.horizontalPadding,
  });

  final List<PsShortcut> items;
  final int columns;
  final double itemHeight;
  final double rowGap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: <Widget>[
          for (
            var row = 0;
            row < (items.length / columns).ceil();
            row++
          ) ...<Widget>[
            if (row > 0) SizedBox(height: rowGap),
            SizedBox(
              height: itemHeight,
              child: Row(
                children: <Widget>[
                  for (var column = 0; column < columns; column++)
                    Expanded(child: _slot(row * columns + column)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slot(int index) {
    if (index >= items.length) return const SizedBox.shrink();
    return _ShortcutItem(item: items[index]);
  }
}

class _ShortcutItem extends StatelessWidget {
  const _ShortcutItem({required this.item});

  final PsShortcut item;

  /// 品牌色系的 6 组淡底/主色对，按 label 派生，保证同一分类每次颜色一致。
  static const List<(Color, Color)> _tones = <(Color, Color)>[
    (Color(0xFFFFE8F1), Color(0xFFFF317B)),
    (Color(0xFFF0EAFE), Color(0xFF6C4BE0)),
    (Color(0xFFE8F1FF), Color(0xFF2F6FE4)),
    (Color(0xFFFFF3E0), Color(0xFFE8873A)),
    (Color(0xFFE4F7F3), Color(0xFF2AA08C)),
    (Color(0xFFFFEDE8), Color(0xFFE4573F)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final hash = item.label.codeUnits.fold<int>(
      0,
      (acc, unit) => (acc * 31 + unit) & 0x7FFFFFFF,
    );
    final (background, foreground) = _tones[hash % _tones.length];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color?.withValues(alpha: 0.12) ?? background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 22, color: item.color ?? foreground),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

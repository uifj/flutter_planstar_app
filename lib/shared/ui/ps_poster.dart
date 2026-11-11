import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'ps_network_images.dart';

/// 海报位。
///
/// ## 图片来源：开源免费图床
///
/// 本地 `assets/` 已整体移除，海报统一走 Lorem Picsum（图片来自 Unsplash，
/// 免费可商用）的确定性 seed URL：同一个企划每次渲染都是同一张图，
/// 不同企划之间能区分开。底层仍保留一组确定性渐变 + 首字水印作为
/// 网络加载失败时的兜底。接入自有 CDN 后把 [imageUrl] 传进来即可覆盖。
///
/// ## 尺寸约定
///
/// 各处的宽高由调用方给，常用四组：
/// - 首页精选卡片：`105 × 140`，圆角 2dp
/// - 列表卡片：`76 × 101`，圆角 8dp
/// - 支持记录（订单）卡片：`58 × 76`，圆角 4dp
/// - 企划详情头图：`92 × 124`
class PsPoster extends StatelessWidget {
  const PsPoster({
    super.key,
    required this.seed,
    required this.width,
    required this.height,
    this.radius = 4,
    this.imageUrl,
    this.overlay,
    this.dimmed = false,
  });

  /// 派生渐变与首字水印用的种子（传企划标题）。
  final String seed;

  /// 海报尺寸。传 [double.infinity] 表示“铺满父级”（父级需有界约束，
  /// 如 `AspectRatio`），首字水印会按实测高度计算。
  final double width;
  final double height;
  final double radius;

  /// 真实海报地址。非空且加载成功时覆盖占位。
  final String? imageUrl;

  /// 叠在海报之上的角标（折扣、标签、城市）。
  final Widget? overlay;

  /// 名额已满/下架时压暗。
  final bool dimmed;

  /// 六组派生渐变（洋红/紫/蓝/琥珀/青/朱），与 `BasePalette` 的强调色同族。
  static const List<List<Color>> _gradients = <List<Color>>[
    <Color>[Color(0xFFFF8FC0), Color(0xFFFF317B)],
    <Color>[Color(0xFFB08BFF), Color(0xFF6C4BE0)],
    <Color>[Color(0xFF7FB6FF), Color(0xFF2F6FE4)],
    <Color>[Color(0xFFFFC46B), Color(0xFFE8873A)],
    <Color>[Color(0xFF6FD6C4), Color(0xFF2AA08C)],
    <Color>[Color(0xFFFF9A8B), Color(0xFFE4573F)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[_seedHash(seed) % _gradients.length];

    // 铺满场景下 height 本身就是 infinity，直接进 TextStyle.fontSize 会炸
    // PlatformDispatcher.scaleFontSize 的 isFinite 断言（debug 下每帧一次，
    // 还会连带触发 Center 的 'child!.hasSize'）。SizedBox 里的 infinity 会被
    // enforce 到父级约束（就是“铺满”），但字号得用实测高度算。
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double measuredHeight = height.isFinite
            ? height
            : constraints.maxHeight;
        final double watermarkSize =
            (measuredHeight.isFinite ? measuredHeight : 120) * 0.34;

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradient,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _initial(seed, context.l10n.psPoster_136),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: watermarkSize,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.34),
                      ),
                    ),
                  ),
                ),
                Image.network(
                  imageUrl != null && imageUrl!.isNotEmpty
                      ? imageUrl!
                      : PsImages.poster(seed),
                  fit: BoxFit.cover,
                  // 加载失败就退回渐变，不留破图。
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
                if (dimmed) const ColoredBox(color: Color(0x66000000)),
                ?overlay,
              ],
            ),
          ),
        );
      },
    );
  }

  static int _seedHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return hash;
  }

  static String _initial(String value, String fallback) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    // 标题常以书名号/引号开头（《星轨》），取第一个"字"更好看。
    final match = RegExp(r'[\u4e00-\u9fa5A-Za-z0-9]').firstMatch(trimmed);
    return match?.group(0) ?? trimmed.substring(0, 1);
  }
}

/// 海报上的小角标：9sp 白字、`#80000000` 底、圆角 4dp。
class PsPosterTag extends StatelessWidget {
  const PsPosterTag({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? const Color(0x80000000),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 海报底部城市条：24dp 高、底部黑色渐变、
/// 定位图标 8dp + 9sp 白字。
class PsPosterCityBar extends StatelessWidget {
  const PsPosterCityBar({super.key, required this.city});

  final String city;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x00000000), Color(0xB3000000)],
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(LucideIcons.mapPin, size: 8, color: Colors.white),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              city,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 折扣角标：品牌红底、9sp 白字，左上/右上 2dp、右下 8dp 圆角。
class PsDiscountCorner extends StatelessWidget {
  const PsDiscountCorner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

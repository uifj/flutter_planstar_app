import 'dart:async';

import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';

/// 首页运营 banner（`view_home_banner.xml`）。
///
/// 80dp 高、左右 12dp、圆角 12dp、上边距 8dp——这几个数直接来自原 layout
/// 的 `CardView`（`cardCornerRadius=12`、`layout_height=80`、`marginHorizontal=12`）。
///
/// 原图是 CDN 运营图（`BannerBean.imageUrl`），仓库里没有对应素材，
/// 所以这里用**品牌渐变的运营位**承载同样的信息：标题 + 副标题 + 角标。
/// 接真实接口后把 `_slides` 换成 `bannerList` 即可，尺寸与轮播逻辑不用动。
class HomeBannerFloor extends StatefulWidget {
  const HomeBannerFloor({super.key, this.onTap});

  final void Function(BannerSlide slide)? onTap;

  @override
  State<HomeBannerFloor> createState() => _HomeBannerFloorState();
}

/// 一个运营位。
class BannerSlide {
  const BannerSlide({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.colors,
    this.showId,
  });

  final String title;
  final String subtitle;
  final String badge;

  /// 渐变两端色。
  final (Color, Color) colors;

  /// 点击后跳转的演出 id（`null` = 纯运营位，没有落地页）。
  final String? showId;
}

class _HomeBannerFloorState extends State<HomeBannerFloor> {
  static const List<BannerSlide> _slides = <BannerSlide>[
    BannerSlide(
      title: '双 11 演出狂欢',
      subtitle: '满 500 减 100 · 全场通用',
      badge: '限时',
      colors: (Color(0xFFFF6AB9), Color(0xFFFE3870)),
    ),
    BannerSlide(
      title: '新人首单立减 50',
      subtitle: '注册即领 · 无门槛使用',
      badge: '新人',
      colors: (Color(0xFFFFB36B), Color(0xFFE8873A)),
    ),
    BannerSlide(
      title: '《剧院魅影》中文版',
      subtitle: '限时 9 折 · 上海文化广场',
      badge: '热卖',
      colors: (Color(0xFF9B7BFF), Color(0xFF6C4BE0)),
      showId: '2001',
    ),
    BannerSlide(
      title: '企划星安心入场保障',
      subtitle: '无票必赔 · 最高退一赔一',
      badge: '保障',
      colors: (Color(0xFF6FD6C4), Color(0xFF2AA08C)),
    ),
  ];

  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 80,
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onTap?.call(slide),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: <Color>[slide.colors.$1, slide.colors.$2],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    slide.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slide.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.2,
                                      color: Color(0xE6FFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                slide.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 10,
                bottom: 8,
                child: Row(
                  children: <Widget>[
                    for (var i = 0; i < _slides.length; i++)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index
                              ? colors.bgCard
                              : colors.bgCard.withValues(alpha: 0.45),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

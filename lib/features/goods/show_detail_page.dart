import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_empty_state.dart';
import '../../shared/ui/ps_poster.dart';
import '../../shared/ui/ps_price.dart';
import '../../shared/ui/ps_tag.dart';
import '../catalog/application/catalog_providers.dart';
import '../catalog/domain/show_summary.dart';
import '../../shared/ui/ps_network_images.dart';
import '../../l10n/goods_localizations.dart';

/// 演出详情（`layout_show_detail.xml`）。
///
/// ## 结构
///
/// - 顶部沉浸式头图（`view_show_detail_header_picture.xml`）：海报 92×124、
///   标题 14sp 白字最多 3 行、评分、底部 20dp 白色圆角压住；
/// - 42dp 的锚点 tab（简介 / 票档 / 须知），点击滚动到对应段落；
/// - 内容：演出信息（时长 + 场馆 + 地址 + 导航）→ 安心入场保障条 →
///   票档 → 阵容 → 演出介绍 → 购票须知 → 服务保障；
/// - 底部 46dp 购买栏（`view_show_detail_purchase.xml`）：客服 / 想看 + 立即购买。
///
/// ## 与 Android 的差异
///
/// - 企划星详情页的 UI 实际跑在 Flutter 引擎里（`ShowDetailActivity` 只是一个
///   转发壳），`layout_show_detail.xml` 是它的原生降级版。这里以原生 layout
///   为基准复刻，因为它是仓库里唯一可核对的规格。
/// - 没有实现「代抢 / 拼团 / 选座 / 求票浮标」四个分支：它们各自需要独立的下单
///   链路（`orderType=5` / 选座图 / 求票表单），本项目只做了普通购票。
class ShowDetailPage extends ConsumerStatefulWidget {
  const ShowDetailPage({super.key, required this.showId});

  final String showId;

  @override
  ConsumerState<ShowDetailPage> createState() => _ShowDetailPageState();
}

class _ShowDetailPageState extends ConsumerState<ShowDetailPage> {
  List<String> get _tabs => <String>[GoodsLocalizations.of(context).showDetailPage_44, GoodsLocalizations.of(context).showDetailPage_44_2, GoodsLocalizations.of(context).showDetailPage_44_3];

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _introKey = GlobalKey();
  final GlobalKey _tiersKey = GlobalKey();
  final GlobalKey _noticeKey = GlobalKey();
  int _tab = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpTo(int index) {
    setState(() => _tab = index);
    final key = switch (index) {
      0 => _introKey,
      1 => _tiersKey,
      _ => _noticeKey,
    };
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final show = ref.watch(showByIdProvider(widget.showId));

    if (show == null) {
      return AdaptiveScaffold(
        appBar: const AdaptiveAppBar(title: '演出详情'),
        body: PsEmptyState(
          title: GoodsLocalizations.of(context).showDetailPage_84,
          description: GoodsLocalizations.of(context).showDetailPage_85(widget.showId),
          icon: LucideIcons.calendarX,
          actionLabel: GoodsLocalizations.of(context).showDetailPage_87,
          onAction: () => context.go('/'),
        ),
      );
    }

    final topPadding = MediaQuery.paddingOf(context).top;

    return AdaptiveScaffold(
      backgroundColor: colors.bgCard,
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DetailHeader(
                    show: show,
                    topPadding: topPadding,
                    onBack: () => context.pop(),
                    onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(GoodsLocalizations.of(context).showDetailPage_110)),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _AnchorTabs(
                    tabs: _tabs,
                    selected: _tab,
                    onSelect: _jumpTo,
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    _InfoSection(key: _introKey, show: show),
                    _GuaranteeBanner(onTap: () => _toast(context, GoodsLocalizations.of(context).showDetailPage_125)),
                    _TierSection(
                      key: _tiersKey,
                      show: show,
                      onBuy: () => _buy(context),
                    ),
                    if (show.lineup.isNotEmpty) _LineupSection(show: show),
                    _IntroSection(show: show),
                    _NoticeSection(key: _noticeKey, show: show),
                    _ServiceGuaranteeSection(),
                    const SizedBox(height: 24),
                  ]),
                ),
              ],
            ),
          ),
          _PurchaseBar(
            show: show,
            onService: () => _toast(context, GoodsLocalizations.of(context).showDetailPage_143),
            onWish: () => _toast(context, GoodsLocalizations.of(context).showDetailPage_144),
            onBuy: () => _buy(context),
          ),
        ],
      ),
    );
  }

  void _buy(BuildContext context) {
    if (ref.watch(showByIdProvider(widget.showId))?.soldOut ?? false) {
      _toast(context, GoodsLocalizations.of(context).showDetailPage_154);
      return;
    }
    // 详情页 → 选票页 → 确认订单。
    // 选票页负责"选哪场、哪个票档、几张"——这些参数必须由用户选出来，
    // 不能在详情页假设默认值。
    context.push('/show/${widget.showId}/choose-ticket');
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 顶部头图（`view_show_detail_header_picture.xml`）。
class _DetailHeader extends SliverPersistentHeaderDelegate {
  _DetailHeader({
    required this.show,
    required this.topPadding,
    required this.onBack,
    required this.onShare,
  });

  final ShowSummary show;
  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  double get maxExtent => topPadding + 230;

  @override
  double get minExtent => topPadding + 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = ((shrinkOffset) / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // 背景：海报放大 + 40% 透明压暗（`iv_bg` alpha=0.4 + `ivBgMask` #66000000）。
        PsPoster(seed: show.title, width: double.infinity, height: double.infinity, radius: 0),
        const ColoredBox(color: Color(0x8C000000)),
        // 内容：海报 + 标题 + 评分 + 价格。
        Positioned(
          left: 15,
          right: 15,
          top: topPadding + 44,
          child: Opacity(
            opacity: (1 - t * 1.5).clamp(0.0, 1.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                PsPoster(seed: show.title, width: 92, height: 124, radius: 4),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        show.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Text(
                            show.rating > 0 ? show.rating.toStringAsFixed(1) : GoodsLocalizations.of(context).showDetailPage_228,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFB238),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (show.ratingCount > 0)
                            Text(
                              GoodsLocalizations.of(context).showDetailPage_238(show.ratingCount),
                              style: const TextStyle(fontSize: 11, color: Color(0xCCFFFFFF)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: <Widget>[
                          for (final tag in show.tags)
                            PsTag(
                              label: tag,
                              tone: PsTagTone.outline,
                              color: Colors.white,
                              fontSize: 9,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: PsPrice(amount: show.priceFrom, size: 18, suffix: GoodsLocalizations.of(context).showDetailPage_264),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 底部 20dp 白色圆角压住头图（`roundedCornerBackground`）。
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 20,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        // 返回 / 分享。
        Positioned(
          left: 4,
          top: topPadding + 2,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(LucideIcons.chevronLeft, size: 18, color: Colors.white),
          ),
        ),
        Positioned(
          right: 4,
          top: topPadding + 2,
          child: IconButton(
            onPressed: onShare,
            icon: const Icon(LucideIcons.share, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _DetailHeader oldDelegate) =>
      oldDelegate.show.id != show.id || oldDelegate.topPadding != topPadding;
}

/// 42dp 锚点 tab。
class _AnchorTabs extends SliverPersistentHeaderDelegate {
  _AnchorTabs({required this.tabs, required this.selected, required this.onSelect});

  final List<String> tabs;
  final int selected;
  final void Function(int index) onSelect;

  @override
  double get maxExtent => 42;

  @override
  double get minExtent => 42;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      child: Row(
        children: <Widget>[
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      tabs[i],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: i == selected ? FontWeight.w700 : FontWeight.w400,
                        color: i == selected ? colors.brand : colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: i == selected ? colors.brand : Colors.transparent,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AnchorTabs oldDelegate) =>
      oldDelegate.selected != selected;
}

/// 演出信息（`view_show_detail_header_other.xml`）。
class _InfoSection extends StatelessWidget {
  const _InfoSection({super.key, required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${show.firstSessionLabel} · ${show.duration}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                show.saleStatusLabel,
                style: TextStyle(fontSize: 12, color: colors.price),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(LucideIcons.mapPin, size: 16, color: colors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      show.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      show.venueAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.navigation, size: 22, color: colors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

/// 安心入场保障条（`btnTicketSource`，34dp）。
class _GuaranteeBanner extends StatelessWidget {
  const _GuaranteeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAE9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Icon(LucideIcons.badgeCheck, size: 20, color: colors.price),
              const SizedBox(width: 4),
              Text(
                GoodsLocalizations.of(context).showDetailPage_473,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.price,
                ),
              ),
              Container(
                width: 1,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: colors.border,
              ),
              Expanded(
                child: Text(
                  GoodsLocalizations.of(context).showDetailPage_488,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 14, color: colors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

/// 票档（详情页的「选择票档」段）。
class _TierSection extends StatelessWidget {
  const _TierSection({super.key, required this.show, required this.onBuy});

  final ShowSummary show;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            GoodsLocalizations.of(context).showDetailPage_519,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final tier in show.tiers)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: tier.soldOut ? null : onBuy,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.bgSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            tier.name,
                            style: TextStyle(fontSize: 14, color: colors.textPrimary),
                          ),
                          if (tier.note != null) ...<Widget>[
                            const SizedBox(height: 2),
                            Text(
                              tier.note!,
                              style: TextStyle(fontSize: 11, color: colors.textTertiary),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (tier.soldOut)
                      Text(
                        GoodsLocalizations.of(context).showDetailPage_560,
                        style: TextStyle(fontSize: 13, color: colors.textDisabled),
                      )
                    else
                      PsPrice(amount: tier.price, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 阵容（`view_show_detail_lineup.xml`）。
class _LineupSection extends StatelessWidget {
  const _LineupSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            GoodsLocalizations.of(context).showDetailPage_590,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: show.lineup.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 60,
                  child: Column(
                    children: <Widget>[
                      ClipOval(
                        child: Image.network(
                          PsImages.defaultAvatar,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 56,
                            height: 56,
                            color: colors.brandSubtle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        show.lineup[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 演出介绍（`view_show_detail_intro.xml`）。
class _IntroSection extends StatelessWidget {
  const _IntroSection({required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    if (show.intro.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '演出详情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            show.intro,
            style: TextStyle(fontSize: 14, height: 1.7, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// 购票须知（`dialog_show_detail_more_purchase_notice`）。
class _NoticeSection extends StatelessWidget {
  const _NoticeSection({super.key, required this.show});

  final ShowSummary show;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final notices = show.purchaseNotice.isEmpty
        ? <String>[GoodsLocalizations.of(context).showDetailPage_685, GoodsLocalizations.of(context).showDetailPage_685_2]
        : show.purchaseNotice;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            GoodsLocalizations.of(context).showDetailPage_693,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          for (final notice in notices)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('· ', style: TextStyle(fontSize: 14, color: colors.textTertiary)),
                  Expanded(
                    child: Text(
                      notice,
                      style: TextStyle(fontSize: 13, height: 1.6, color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 服务保障（`view_show_detail_guarantee.xml`）。
class _ServiceGuaranteeSection extends StatelessWidget {
  static const List<(IconData, String)> _items = <(IconData, String)>[
    (LucideIcons.creditCard, '先看后付'),
    (LucideIcons.shieldCheck, '无票赔付'),
    (LucideIcons.ticket, '出票保真'),
    (LucideIcons.truck, '配送保障'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      color: colors.bgPage,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 40, height: 1, color: colors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  GoodsLocalizations.of(context).showDetailPage_748,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              Container(width: 40, height: 1, color: colors.border),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              for (final (icon, label) in _items)
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Icon(icon, size: 30, color: colors.textTertiary),
                      const SizedBox(height: 10),
                      Text(
                        label,
                        style: TextStyle(fontSize: 12, color: colors.textTertiary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 底部购买栏（`view_show_detail_purchase.xml`）。
class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({
    required this.show,
    required this.onService,
    required this.onWish,
    required this.onBuy,
  });

  final ShowSummary show;
  final VoidCallback onService;
  final VoidCallback onWish;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      color: colors.bgCard,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0x14000000), Color(0x00000000)],
              ),
            ),
          ),
          SizedBox(
            height: 66,
            child: Row(
              children: <Widget>[
                _BarAction(icon: LucideIcons.headset, label: GoodsLocalizations.of(context).showDetailPage_820, onTap: onService),
                _BarAction(
                  icon: LucideIcons.heart,
                  label: GoodsLocalizations.of(context).showDetailPage_823,
                  color: colors.price,
                  onTap: onWish,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                    child: GestureDetector(
                      onTap: onBuy,
                      child: Container(
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: show.soldOut ? colors.brandDisabled : colors.price,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          show.soldOut ? GoodsLocalizations.of(context).showDetailPage_840 : GoodsLocalizations.of(context).showDetailPage_840_2,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 26, color: color ?? colors.textPrimary),
            Text(
              label,
              style: TextStyle(fontSize: 12, height: 1.1, color: color ?? colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

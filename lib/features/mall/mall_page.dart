import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core/domain.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/session.dart';
import '../../l10n/l10n.dart';
import '../../shared/ui/ps_empty_state.dart';
import '../marketing/wallet_providers.dart';
import 'application/mall_providers.dart';
import 'model/goods.dart';

/// 星币商城。
class MallPage extends ConsumerWidget {
  const MallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final goodsAsync = ref.watch(mallGoodsProvider);
    final balance = ref.watch(walletBalanceProvider);

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(title: context.l10n.mallPage_1),
      body: goodsAsync.when(
        data: (List<Goods> goods) {
          if (goods.isEmpty) {
            return PsEmptyState(
              title: context.l10n.mallPage_14,
              description: context.l10n.mallPage_15,
              icon: LucideIcons.gift,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(walletProvider);
              ref.invalidate(mallGoodsProvider);
              await ref.read(mallGoodsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                _BalanceBanner(balance: balance),
                for (final Goods item in goods)
                  _GoodsCard(goods: item, balance: balance),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => PsEmptyState(
          title: psErrorMessage(error),
          actionLabel: context.l10n.mallPage_16,
          onAction: () => ref.invalidate(mallGoodsProvider),
        ),
      ),
    );
  }
}

/// 顶部星币余额。
class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.balance});

  final Money balance;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[colors.brand, colors.brand.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Text(
            context.l10n.mallPage_2,
            style: TextStyle(
              fontSize: 13,
              color: colors.onBrand.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          Text(
            balance.format(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.onBrand,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个商品卡。
class _GoodsCard extends ConsumerWidget {
  const _GoodsCard({required this.goods, required this.balance});

  final Goods goods;
  final Money balance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final description = goods.brief.isNotEmpty
        ? goods.brief
        : goods.description;

    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            goods.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          if (description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ],
          for (final GoodsSku sku in goods.skus)
            _SkuRow(goods: goods, sku: sku, balance: balance),
        ],
      ),
    );
  }
}

/// 商品规格行：价格 / 限量 / 剩余 / 兑换按钮。
class _SkuRow extends ConsumerWidget {
  const _SkuRow({
    required this.goods,
    required this.sku,
    required this.balance,
  });

  final Goods goods;
  final GoodsSku sku;
  final Money balance;

  bool get _affordable => balance.minorUnits >= sku.priceCoins * 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final submitting = ref.watch(mallControllerProvider);
    final soldOut = sku.soldOut;
    final canRedeem = !soldOut && _affordable && !submitting;
    final String price = sku.price.format();
    final String buttonLabel = soldOut
        ? context.l10n.mallPage_7
        : context.l10n.mallPage_6;

    Future<void> handleTap() async {
      if (!ref.read(sessionProvider).isLoggedIn) {
        context.push('/login?from=%2Fmall');
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(context.l10n.mallPage_9),
          content: Text(context.l10n.mallPage_10(sku.name, price)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.mallPage_11),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.mallPage_12),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final error = await ref
          .read(mallControllerProvider.notifier)
          .redeem(goods, sku);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? context.l10n.mallPage_13)),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.bgPage,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  sku.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              FilledButton(
                onPressed: canRedeem ? handleTap : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buttonLabel, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: <Widget>[
              Text(
                context.l10n.mallPage_3(price),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.brand,
                ),
              ),
              Text(
                context.l10n.mallPage_4('${sku.totalStock}'),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
              Text(
                context.l10n.mallPage_5('${sku.stock}'),
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ),
          if (!soldOut && !_affordable) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              context.l10n.mallPage_8,
              style: TextStyle(fontSize: 12, color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}

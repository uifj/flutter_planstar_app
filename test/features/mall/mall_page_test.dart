import 'package:core/domain.dart';
import 'package:core/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/app/session.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/features/mall/application/mall_providers.dart';
import 'package:planstar/features/mall/data/mall_api.dart';
import 'package:planstar/features/mall/mall_page.dart';
import 'package:planstar/features/mall/model/goods.dart';
import 'package:planstar/features/marketing/wallet_providers.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';

void main() {
  const Size kSurface = Size(390, 1200);

  const Goods fixture = Goods(
    goodsId: 1,
    name: '企划星UP主的祝福视频',
    brief: '为你定制一段专属祝福视频',
    description: '由企划星UP主录制的专属祝福视频。',
    cover: '',
    skus: <GoodsSku>[
      GoodsSku(
        skuId: 1,
        name: '30秒祝福视频',
        priceCoins: 1000,
        stock: 500,
        sold: 0,
      ),
      GoodsSku(
        skuId: 2,
        name: '60秒祝福视频',
        priceCoins: 2000,
        stock: 0,
        sold: 500,
      ),
    ],
  );

  Future<ProviderContainer> pumpMall(
    WidgetTester tester, {
    required List<Goods> goods,
    required Money balance,
    MallApi? api,
    bool loggedIn = true,
  }) async {
    tester.view.physicalSize = kSurface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: <Override>[
        useDemoProvider.overrideWithValue(false),
        mallGoodsProvider.overrideWith((Ref ref) async => goods),
        walletBalanceProvider.overrideWithValue(balance),
        sessionProvider.overrideWithValue(
          Session(isLoggedIn: loggedIn, nickname: '票友小张'),
        ),
        if (api != null) mallApiProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation: '/mall',
      routes: <RouteBase>[
        GoRoute(path: '/mall', builder: (_, _) => const MallPage()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('login-page')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          locale: const Locale('zh'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('展示商品名称、两个规格价格、限量与售罄状态', (WidgetTester tester) async {
    await pumpMall(
      tester,
      goods: const <Goods>[fixture],
      balance: Money.fromMinorUnits(150000),
    );

    expect(find.text('星币商城'), findsOneWidget);
    expect(find.text('企划星UP主的祝福视频'), findsOneWidget);
    expect(find.text('为你定制一段专属祝福视频'), findsOneWidget);
    expect(find.text('30秒祝福视频'), findsOneWidget);
    expect(find.text('60秒祝福视频'), findsOneWidget);
    expect(find.text('价格 星币 1,000'), findsOneWidget);
    expect(find.text('价格 星币 2,000'), findsOneWidget);
    expect(find.text('限量 500 份'), findsNWidgets(2));
    expect(find.text('剩余 500 份'), findsOneWidget);
    expect(find.text('剩余 0 份'), findsOneWidget);

    final soldOut = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '已售罄'),
    );
    expect(soldOut.onPressed, isNull);
  });

  testWidgets('余额不足：兑换按钮禁用并给出提示', (WidgetTester tester) async {
    const Goods expensive = Goods(
      goodsId: 2,
      name: '限量祝福视频',
      brief: '余额不足示例',
      description: '',
      cover: '',
      skus: <GoodsSku>[
        GoodsSku(
          skuId: 3,
          name: '90秒祝福视频',
          priceCoins: 2000,
          stock: 10,
          sold: 490,
        ),
      ],
    );
    await pumpMall(
      tester,
      goods: const <Goods>[expensive],
      balance: Money.fromMinorUnits(150000),
    );

    expect(find.text('星币余额不足'), findsOneWidget);
    final redeem = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '兑换'),
    );
    expect(redeem.onPressed, isNull);
  });

  testWidgets('点击兑换弹二次确认，确认后调用接口并提示成功', (WidgetTester tester) async {
    final api = _FakeMallApi();
    await pumpMall(
      tester,
      goods: const <Goods>[fixture],
      balance: Money.fromMinorUnits(150000),
      api: api,
    );

    await tester.tap(find.widgetWithText(FilledButton, '兑换'));
    await tester.pumpAndSettle();

    expect(find.text('确认兑换'), findsOneWidget);
    expect(find.text('兑换「30秒祝福视频」将消耗 星币 1,000'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '确认'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.goodsId, 1);
    expect(api.skuId, 1);
    expect(find.text('兑换成功'), findsOneWidget);
  });
}

final class _FakeMallApi implements MallApi {
  int? goodsId;
  int? skuId;

  @override
  Future<Result<List<Goods>>> fetchGoods() async =>
      const Success<List<Goods>>(<Goods>[]);

  @override
  Future<Result<Goods>> fetchGoodsDetail(int id) async =>
      throw StateError('商城列表页不该请求商品详情');

  @override
  Future<Result<RedeemResult>> redeem({
    required int goodsId,
    required int skuId,
  }) async {
    this.goodsId = goodsId;
    this.skuId = skuId;
    return Success<RedeemResult>(
      RedeemResult(
        orderNo: 'R20261107001',
        balance: Money.fromMinorUnits(50000),
        stock: 499,
        sold: 1,
      ),
    );
  }
}

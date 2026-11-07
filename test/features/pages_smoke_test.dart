import 'package:flutter/material.dart';
import 'package:planstar/app/app.dart' show appLocalizationsDelegates;
import 'package:planstar/app/network/network_providers.dart';
import 'package:planstar/app/theme.dart';
import 'package:planstar/l10n/generated/app_localizations.dart';
import 'package:planstar/features/catalog/ui/show_list_page.dart';
import 'package:planstar/features/discover/discover_page.dart';
import 'package:planstar/features/discover/feed_detail_page.dart';
import 'package:planstar/features/goods/show_detail_page.dart';
import 'package:planstar/features/goods/venue_page.dart';
import 'package:planstar/features/home/city_list_page.dart';
import 'package:planstar/features/home/home_page.dart';
import 'package:planstar/features/message/chat_page.dart';
import 'package:planstar/features/message/message_page.dart';
import 'package:planstar/features/order/order_detail_page.dart';
import 'package:planstar/features/order/order_list_page.dart';
import 'package:planstar/features/search/search_page.dart';
import 'package:planstar/features/search/search_result_page.dart';
import 'package:planstar/features/user/address_page.dart';
import 'package:planstar/features/user/settings_page.dart';
import 'package:planstar/features/user/user_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// 页面冒烟：每个页面在**两档窄屏**下各渲染一次。
///
/// 这层测试只回答一个问题——"这页会不会在首帧就抛异常 / 溢出"。
/// 它不比对文案、不比对像素：布局每改一次都要跟着改的断言，最后一定没人维护
/// （同 `test/app_shell_test.dart` 的口径）。
///
/// 之所以值得存在：`flutter analyze` 抓不到 `RenderFlex overflowed`、
/// 抓不到 `Provider` 没被 override、抓不到 `SliverPersistentHeaderDelegate`
/// 的 extent 自相矛盾。本次重写里真实抓到过 4 处溢出：
/// `ShowCardFloor` 的「价格 + 折扣标签」（76dp 卡片）、
/// `OrderListCard` 底部的「实付 + 状态按钮」行。
void main() {
  /// 360dp 是来源设计稿基线，320dp 是仍在支持的窄屏下限。
  const List<Size> kSurfaces = <Size>[Size(360, 640), Size(320, 568)];

  /// 页面里只要有一处 `context.push` / `context.go` 就需要真实 Router。
  Future<void> pumpPage(WidgetTester tester, Widget page, Size surface) async {
    tester.view.physicalSize = surface * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final GoRouter router = GoRouter(
      initialLocation: '/page',
      routes: <RouteBase>[
        GoRoute(path: '/page', builder: (_, _) => page),
        GoRoute(
          path: '/order/confirm',
          builder: (_, _) => const Scaffold(body: Text('confirm')),
        ),
        GoRoute(
          path: '/show/:showId',
          builder: (_, _) => const Scaffold(body: Text('detail')),
        ),
        // 二级页可能被"首帧就跳走"的逻辑推到这些地址（例如会话页标记已读后
        // 回列表）。全部登记成占位页，让冒烟测试只关心渲染，不关心导航。
        GoRoute(
          path: '/search',
          builder: (_, _) => const Scaffold(body: Text('search')),
        ),
        GoRoute(
          path: '/shows',
          builder: (_, _) => const Scaffold(body: Text('shows')),
        ),
        GoRoute(
          path: '/order/detail',
          builder: (_, _) => const Scaffold(body: Text('orderDetail')),
        ),
        GoRoute(
          path: '/venue/:name',
          builder: (_, _) => const Scaffold(body: Text('venue')),
        ),
        GoRoute(
          path: '/feed/:id',
          builder: (_, _) => const Scaffold(body: Text('feed')),
        ),
        GoRoute(
          path: '/message/thread/:id',
          builder: (_, _) => const Scaffold(body: Text('chat')),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: Text('settings')),
        ),
        GoRoute(
          path: '/address',
          builder: (_, _) => const Scaffold(body: Text('address')),
        ),
        GoRoute(
          path: '/cities',
          builder: (_, _) => const Scaffold(body: Text('cities')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[useDemoProvider.overrideWithValue(true)],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light(),
          // 页面文案走各 feature 的 l10n；测试壳必须挂同一份 delegate，
          // 否则 `XxxLocalizations.of(context)!` 会在首帧抛 Null check。
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expectClean(
    WidgetTester tester,
    Widget page, {
    required String label,
  }) async {
    for (final Size surface in kSurfaces) {
      await pumpPage(tester, page, surface);
      expect(
        tester.takeException(),
        isNull,
        reason: '$label 在 ${surface.width.toInt()}dp 宽下渲染异常（多为 RenderFlex 溢出）',
      );
    }
  }

  testWidgets('首页', (WidgetTester tester) async {
    await expectClean(tester, const HomePage(), label: '首页');
  });

  testWidgets('发现', (WidgetTester tester) async {
    await expectClean(tester, const DiscoverPage(), label: '发现');
  });

  testWidgets('消息', (WidgetTester tester) async {
    await expectClean(tester, const MessagePage(), label: '消息');
  });

  testWidgets('订单列表', (WidgetTester tester) async {
    await expectClean(tester, const OrderListPage(), label: '订单列表');
  });

  testWidgets('我的', (WidgetTester tester) async {
    await expectClean(tester, const UserPage(), label: '我的');
  });

  testWidgets('演出详情', (WidgetTester tester) async {
    await expectClean(
      tester,
      const ShowDetailPage(showId: '1001'),
      label: '演出详情',
    );
  });

  testWidgets('演出详情：不存在的编号走兜底而不是白屏', (WidgetTester tester) async {
    await pumpPage(
      tester,
      const ShowDetailPage(showId: 'nope'),
      kSurfaces.first,
    );

    expect(find.text('企划不存在或已下架'), findsOneWidget);
    expect(find.text('返回首页'), findsOneWidget);
  });

  // ── 二级页 ──────────────────────────────────────────────────────────────
  //
  // 这些页面都是"从某个入口点进去"的，之前没有任何测试覆盖。它们比一级页
  // 更容易溢出：宽度被外层卡片吃掉一部分（例如 `ShowCardRow` 里的价格 +
  // 折扣标签），或者底部有固定操作栏（订单详情、地址页）。

  testWidgets('演出列表', (WidgetTester tester) async {
    await expectClean(tester, const ShowListPage(), label: '演出列表');
  });

  testWidgets('演出列表：按分类进入', (WidgetTester tester) async {
    await expectClean(
      tester,
      const ShowListPage(categoryId: 1, title: '演唱会'),
      label: '演出列表（分类）',
    );
  });

  testWidgets('搜索页', (WidgetTester tester) async {
    await expectClean(tester, const SearchPage(), label: '搜索页');
  });

  testWidgets('搜索结果', (WidgetTester tester) async {
    await expectClean(
      tester,
      const SearchResultPage(query: '演唱会'),
      label: '搜索结果',
    );
  });

  testWidgets('搜索结果：无结果走空态', (WidgetTester tester) async {
    await pumpPage(
      tester,
      const SearchResultPage(query: '这个词肯定搜不到'),
      kSurfaces.first,
    );

    expect(find.textContaining('没有找到'), findsWidgets);
  });

  testWidgets('订单详情', (WidgetTester tester) async {
    await expectClean(
      tester,
      const OrderDetailPage(orderNumber: ''),
      label: '订单详情',
    );
  });

  testWidgets('订单详情：订单号查不到走兜底而不是白屏', (WidgetTester tester) async {
    await pumpPage(
      tester,
      const OrderDetailPage(orderNumber: 'PN19700101000000'),
      kSurfaces.first,
    );

    expect(find.text('支持记录不存在'), findsOneWidget);
  });

  testWidgets('场馆详情', (WidgetTester tester) async {
    await expectClean(
      tester,
      const VenuePage(venueName: '梅赛德斯-奔驰文化中心'),
      label: '场馆详情',
    );
  });

  testWidgets('场馆详情：不存在的场馆走兜底', (WidgetTester tester) async {
    await pumpPage(
      tester,
      const VenuePage(venueName: '不存在的场馆'),
      kSurfaces.first,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('动态详情', (WidgetTester tester) async {
    await expectClean(
      tester,
      const FeedDetailPage(postId: 'f1'),
      label: '动态详情',
    );
  });

  testWidgets('动态详情：空评论区也能正常渲染', (WidgetTester tester) async {
    // `buildDemoComments` 只给 f1/f2/f3/f5 造了评论，其余是空列表——
    // 空评论区是真实存在的一屏，必须能渲染。
    await expectClean(
      tester,
      const FeedDetailPage(postId: 'f4'),
      label: '动态详情（无评论）',
    );
  });

  testWidgets('会话详情', (WidgetTester tester) async {
    await expectClean(tester, const ChatPage(threadId: 't1'), label: '会话详情');
  });

  testWidgets('设置页', (WidgetTester tester) async {
    await expectClean(tester, const SettingsPage(), label: '设置页');
  });

  testWidgets('收货地址', (WidgetTester tester) async {
    await expectClean(tester, const AddressPage(), label: '收货地址');
  });

  testWidgets('城市列表', (WidgetTester tester) async {
    await expectClean(tester, const CityListPage(), label: '城市列表');
  });
}

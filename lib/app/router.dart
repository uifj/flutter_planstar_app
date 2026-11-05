import 'package:core_domain/core_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/app/splash_page.dart';
import '../features/auth/login_page.dart';
import '../features/catalog/ui/category_home_page.dart';
import '../features/catalog/ui/show_list_page.dart';
import '../features/discover/discover_page.dart';
import '../features/discover/feed_detail_page.dart';
import '../features/goods/choose_ticket_page.dart';
import '../features/goods/seatmap/seat_selection_page.dart';
import '../features/goods/show_detail_page.dart';
import '../features/goods/venue_page.dart';
import '../features/home/city_list_page.dart';
import '../features/home/home_page.dart';
import '../features/group_buy/group_buy_detail_page.dart';
import '../features/group_buy/group_buy_page.dart';
import '../features/marketing/coupon_page.dart';
import '../features/marketing/exchange_coupon_page.dart';
import '../features/marketing/giftcard/add_gift_card_page.dart';
import '../features/marketing/giftcard/gift_card_page.dart';
import '../features/marketing/wallet_page.dart';
import '../features/message/chat_page.dart';
import '../features/message/message_page.dart';
import '../features/order/order_confirm_page.dart';
import '../features/order/order_detail_page.dart';
import '../features/order/order_list_page.dart';
import '../features/order/pay_success_page.dart';
import '../features/order/payment/pay_page.dart';
import '../features/order/refund/refund_page.dart';
import '../features/proxy_buy/proxy_buy_page.dart';
import '../features/search/search_page.dart';
import '../features/search/search_result_page.dart';
import '../features/user/address_page.dart';
import '../features/user/edit_profile_page.dart';
import '../features/user/feedback_page.dart';
import '../features/user/settings_page.dart';
import '../features/user/user_page.dart';
import '../shell/root_shell.dart';
import 'planstar_links.dart';
import 'session.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 需要登录才能进入的 location 前缀（登录门禁）。
const List<String> _authGatedPrefixes = <String>[
  '/order',
  '/coupons',
  '/wallet',
  '/giftcards',
  '/proxy-buy',
  '/group-buy',
];

/// GoRouter 作为 Riverpod Provider 暴露：redirect 里用 ref.read 读登录态，
/// 会话变化时由 listen 触发刷新（见下方 refreshListenable）。
final routerProvider = Provider<GoRouter>((ref) {
  // 会话变化 → 触发路由重新评估 redirect（例如登录后自动放行门禁页）。
  final refresh = _SessionRefresh(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final uri = state.uri;

      // 1) 外部 scheme 归一：planstar://host?query → 已登记的 GoRoute path。
      if (uri.scheme == 'planstar') {
        return PlanstarLinks.resolve(uri) ?? '/';
      }

      // 2) 登录门禁：未登录访问受保护页 → 去 /login 并带上来源。
      //
      // `restoring` 期间必须放行：冷启动时本地会话还没读完，此时 `isLoggedIn`
      // 恒为 false。不放行的话，带登录态的用户从推送/深链进 `/order` 会在
      // 第一帧被踢到登录页，读完会话后又因为"已登录却停在 /login"被弹回首页，
      // 两次重定向把原始深链彻底丢掉。
      final session = ref.read(sessionProvider);
      final loggedIn = session.isLoggedIn;
      final loc = state.matchedLocation;
      if (session.restoring) {
        return null;
      }
      final gated = _authGatedPrefixes.any(loc.startsWith);
      if (gated && !loggedIn) {
        return '/login?from=${Uri.encodeComponent(uri.toString())}';
      }

      // 3) 已登录却停在 /login → 回到来源页。
      //
      // `from` 由 `Uri.queryParameters` 取，**已经是解码后的值**，
      // 不能再 `decodeComponent`：来源 location 里若含 `%20` 之类的
      // 二次编码，多解一次会把 query 解坏。
      if (loggedIn && loc == '/login') {
        final back = state.uri.queryParameters['from'];
        return (back == null || back.isEmpty) ? '/' : back;
      }

      return null;
    },
    routes: [
      // 启动页 / 隐私协议门。
      // 冷启动时从 /splash 开始：检查隐私协议同意状态，
      // 已同意 → 2 秒后进首页 /；未同意 → 弹隐私弹窗。
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            RootShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                name: 'discover',
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/message',
                name: 'message',
                builder: (context, state) => const MessagePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/order',
                name: 'order',
                builder: (context, state) => const OrderListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                name: 'me',
                builder: (context, state) => const UserPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) =>
            LoginPage(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/show/:showId',
        name: 'showDetail',
        builder: (context, state) =>
            ShowDetailPage(showId: state.pathParameters['showId']!),
      ),
      // 选票页。详情页「立即购买」跳这里，选好场次/票档/数量后再进确认订单。
      GoRoute(
        path: '/show/:showId/choose-ticket',
        name: 'chooseTicket',
        builder: (context, state) =>
            ChooseTicketPage(showId: state.pathParameters['showId']!),
      ),
      // 选座页。选票页里的「选座」入口跳这里。
      // 对齐企划星 `SelectTicketSeatMapActivity` / `ChooseTicketSeatTableFragment`。
      GoRoute(
        path: '/show/:showId/seat-selection',
        name: 'seatSelection',
        builder: (context, state) =>
            SeatSelectionPage(showId: state.pathParameters['showId']!),
      ),
      // 场馆详情。场馆没有 numeric id（见 `venueByNameProvider` 的说明），
      // 所以路径参数是场馆名；GoRouter 会自动做 URL 解码。
      GoRoute(
        path: '/venue/:name',
        name: 'venue',
        builder: (context, state) =>
            VenuePage(venueName: state.pathParameters['name'] ?? ''),
      ),
      // 分类首页。从首页的分类快捷入口进入，是分类专属的落地页。
      GoRoute(
        path: '/category/:categoryId',
        name: 'categoryHome',
        builder: (context, state) => CategoryHomePage(
          initialCategoryId: int.tryParse(
            state.pathParameters['categoryId'] ?? '',
        ),
        ),
      ),
      // 演出列表（分类 / 全部）。`category` 是可选的一级分类 id，
      // `title` 只在从「分类楼层」进来时带，避免列表页再查一次分类名。
      GoRoute(
        path: '/shows',
        name: 'showList',
        builder: (context, state) => ShowListPage(
          categoryId: int.tryParse(state.uri.queryParameters['category'] ?? ''),
          title: state.uri.queryParameters['title'],
        ),
      ),
      // 搜索结果。放在 `/search` 之前：GoRouter 按声明顺序匹配，
      // 虽然两者路径不冲突，但把"更具体的先声明"作为约定，避免以后加
      // `/search/:tab` 时踩到顺序问题。
      GoRoute(
        path: '/search/result',
        name: 'searchResult',
        builder: (context, state) =>
            SearchResultPage(query: state.uri.queryParameters['q'] ?? ''),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) =>
            SearchPage(initialQuery: state.uri.queryParameters['q']),
      ),
      // 动态详情。放在 shell 之外：企划星的动态详情是独立 Activity，
      // 进详情后底栏消失、返回回到原 tab——这是内容型页面的常规层级。
      GoRoute(
        path: '/feed/:id',
        name: 'feedDetail',
        builder: (context, state) =>
            FeedDetailPage(postId: state.pathParameters['id'] ?? ''),
      ),
      // 会话详情。同样在 shell 之外：聊天页需要全屏（输入栏贴底、
      // 底栏会让它悬空）。`/message` 本身仍在 shell 里。
      GoRoute(
        path: '/message/thread/:id',
        name: 'chat',
        builder: (context, state) =>
            ChatPage(threadId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/order/confirm',
        name: 'orderConfirm',
        // showId 走 query 而不是路径参数：企划星的确认页是靠 scheme 参数进来的
        // （`goodsId` / `count` / `orderType`），不是路径层级。
        builder: (context, state) => OrderConfirmPage(
          showId: state.uri.queryParameters['showId'] ?? '10086',
        ),
      ),
      // 订单详情。用订单号而不是自增 id 当参数：订单号是用户能看到的、
      // 客服能查的、深链能带的唯一稳定标识。
      GoRoute(
        path: '/order/detail',
        name: 'orderDetail',
        builder: (context, state) => OrderDetailPage(
          orderNumber: state.uri.queryParameters['number'] ?? '',
        ),
      ),
      // 支付页。从确认订单提交后进入，是确认订单与支付成功之间的中间页。
      // 对齐企划星 `PayActivity`：收银台 → 选渠道 → 调 SDK → 成功/失败。
      GoRoute(
        path: '/order/pay',
        name: 'pay',
        builder: (context, state) {
          final minorUnits =
              int.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0;
          return PayPage(
            orderNumber: state.uri.queryParameters['number'] ?? '',
            amount: Money.fromMinorUnits(minorUnits),
            showTitle: state.uri.queryParameters['title'] ?? '',
          );
        },
      ),
      // 支付成功页。从支付流程结束后来到这里。
      // 金额走 query 参数（分），由路由层转成 Money。
      GoRoute(
        path: '/order/pay-success',
        name: 'paySuccess',
        builder: (context, state) {
          final minorUnits =
              int.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0;
          return PaySuccessPage(
            orderNumber: state.uri.queryParameters['number'] ?? '',
            amount: Money.fromMinorUnits(minorUnits),
            showTitle: state.uri.queryParameters['title'],
          );
        },
      ),
      // 退款申请页。从订单详情页「申请退款」按钮进入。
      // 对齐企划星 `OrderRefundWebActivity`（H5）→ 这里做原生表单。
      GoRoute(
        path: '/order/refund',
        name: 'refund',
        builder: (context, state) {
          final minorUnits =
              int.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0;
          return RefundPage(
            orderNumber: state.uri.queryParameters['number'] ?? '',
            orderAmount: Money.fromMinorUnits(minorUnits),
          );
        },
      ),
      // 设置页。从「我的」右上角齿轮进入，是二级页，放在 shell 之外
      // （全屏、有返回箭头）。
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // 收货地址。入口有两处：「我的 → 地址管理」和「确认订单 → 选择地址」，
      // 所以是独立路由而不是某个页面的私有弹窗。
      GoRoute(
        path: '/address',
        name: 'address',
        builder: (context, state) => const AddressPage(),
      ),
      // 完整城市列表。首页城市面板底部的「查看全部城市」进这里。
      GoRoute(
        path: '/cities',
        name: 'cities',
        builder: (context, state) => const CityListPage(),
      ),
      // 编辑资料。从「我的」头部头像点击进入。
      GoRoute(
        path: '/me/edit-profile',
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      // 意见反馈。从「设置 → 意见反馈」进入。
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      // 优惠券列表。从「我的 → 优惠券」进入。
      // 对齐企划星 `CouponActivity`：三 Tab（可用 / 已使用 / 已过期）+ 兑换入口。
      GoRoute(
        path: '/coupons',
        name: 'coupons',
        builder: (context, state) => const CouponPage(),
      ),
      // 兑换码输入页。从优惠券列表页右上角「+」进入。
      // 对齐企划星 `ExchangeCouponActivity`。
      GoRoute(
        path: '/coupons/exchange',
        name: 'exchangeCoupon',
        builder: (context, state) => const ExchangeCouponPage(),
      ),
      // 钱包页。从「我的 → 我的钱包」进入。
      // 对齐企划星 `MyWalletActivity`：余额 + 交易记录。
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        builder: (context, state) => const WalletPage(),
      ),
      // 礼品卡列表页。从「我的 → 礼品卡」进入。
      // 对齐企划星 `GiftCardActivity`：可用/不可用列表 + 绑定入口。
      GoRoute(
        path: '/giftcards',
        name: 'giftCards',
        builder: (context, state) => const GiftCardPage(),
      ),
      // 绑定礼品卡页。从礼品卡列表 AppBar「+」进入。
      // 对齐企划星 `AddGiftCardActivity`：输入卡号绑定。
      GoRoute(
        path: '/giftcards/add',
        name: 'addGiftCard',
        builder: (context, state) => const AddGiftCardPage(),
      ),
      // 代抢服务页。
      // 对齐企划星 `ProxyBuyChooseTicketActivity` + `ProxyBuyConfirmActivity`。
      GoRoute(
        path: '/proxy-buy',
        name: 'proxyBuy',
        builder: (context, state) => const ProxyBuyPage(),
      ),
      // 拼团列表页。
      // 企划星没有独立列表页（入口在演出详情 banner），这里作为聚合入口。
      GoRoute(
        path: '/group-buy',
        name: 'groupBuy',
        builder: (context, state) => const GroupBuyPage(),
      ),
      // 拼团详情页。
      // 对齐企划星 WebView `groupBooking.html?pinTuanId={id}`。
      GoRoute(
        path: '/group-buy/:id',
        name: 'groupBuyDetail',
        builder: (context, state) => GroupBuyDetailPage(
          groupId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
    ],
  );
});

/// 把 Riverpod 的 sessionProvider 桥接成 GoRouter 需要的 Listenable。
class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(Ref ref) {
    _sub = ref.listen<Session>(
      sessionProvider,
      (_, _) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<Session> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

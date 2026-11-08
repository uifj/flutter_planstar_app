/// 前端调用的企划星 API 路径唯一清单。
///
/// 约定：
/// - 路径**不带**前导 `/`，由 `ApiClient` 的 `baseUrl` 负责拼接；
/// - 动态路径用静态方法生成，避免字符串拼接散落在各 API 文件；
/// - 新增端点时必须同步更新 `all` 与 `test/api_paths_test.dart`。
abstract final class ApiPaths {
  // ── catalog ──────────────────────────────────────────────────────────
  static const String homeBanners = 'v1/home/banners';

  // ── project ──────────────────────────────────────────────────────────
  static const String projectsHot = 'v1/projects/hot';
  static const String projects = 'v1/projects';
  static const String rankings = 'v1/rankings';

  static String projectDetail(String id) => 'v1/projects/$id';

  // ── feed ─────────────────────────────────────────────────────────────
  static const String feedHot = 'v4/feed/hot';
  static const String feed = 'v1/feed';
  static const String feedComments = 'v1/userReply';

  static String tweetDetail(String id) => 'v1/tweets/$id';

  // ── project idea ─────────────────────────────────────────────────────
  static const String projectIdeasFeed = 'v1/projectIdeas/feed';

  static String projectIdeaDetail(int id) => 'v1/projectIdeas/$id';
  static String projectIdeaVote(int id) => 'v1/projectIdeas/$id/vote';

  // ── message ──────────────────────────────────────────────────────────
  static const String messages = 'v1/messages';
  static const String messagesUnreadCount = 'v1/messages/unreadCount';
  static const String messagesRead = 'v1/messages/read';

  // ── chat ─────────────────────────────────────────────────────────────
  static const String chatThreads = 'v1/chat/threads';

  static String chatMessages(String threadId) =>
      'v1/chat/threads/$threadId/messages';

  static String chatRead(String threadId) => 'v1/chat/threads/$threadId/read';

  // ── order ────────────────────────────────────────────────────────────
  static const String orderList = 'v1/order/list';
  static const String orderDetail = 'v1/order/detail';
  static const String orderConfirm = 'v1/unifiedOrder/confirm';
  static const String orderMake = 'v3/unifiedOrder/makeOrder';

  static String orderRefund(String orderId) => 'v1/order/$orderId/refund';

  // ── pay ──────────────────────────────────────────────────────────────
  static const String unifiedPay = 'v1/unifiedPay/pay';
  static const String unifiedPayDetail = 'v1/unifiedPay/payDetail';

  // ── proxy_buy ────────────────────────────────────────────────────────
  static const String proxyBuyOrders = 'v1/proxyBuyOrder/myOrders';

  // ── group_buy ────────────────────────────────────────────────────────
  static const String groupBuyOrders = 'v1/pinTuanOrder/myOrders';
  static const String groupBuyJoin = 'v1/pinTuanOrder/make';

  static String groupBuyCampaign(int id) => 'v1/pinTuanCampaign/$id';

  // ── user ─────────────────────────────────────────────────────────────
  static const String userProfile = 'v1/user';
  static const String userSignIn = 'v1/user/signIn';
  static const String addresses = 'v1/myaddress';

  static String addressDelete(String id) => 'v1/myaddress/$id';
  static String addressDefault(String id) => 'v1/myaddress/default/$id';

  // ── money account ────────────────────────────────────────────────────
  static const String moneyAccount = 'v1/moneyaccount';
  static const String moneyAccountSequences = 'v1/moneyaccount/sequences';

  // ── shop ─────────────────────────────────────────────────────────────
  static const String shopGoods = 'v1/shop/goods';

  static String shopGoodsDetail(int id) => 'v1/shop/goods/$id';

  static String shopGoodsRedeem(int goodsId, int skuId) =>
      'v1/shop/goods/$goodsId/skus/$skuId/redeem';

  // ── auth ─────────────────────────────────────────────────────────────
  static const String captcha = 'v1/user/captcha';
  static const String sendLoginCode = 'v3/user/sendLoginCode';
  static const String login = 'v1/user/login';

  /// 所有实际使用的路径（动态段用示例 id `1` 展开），供契约自检。
  static List<String> get all => <String>[
    homeBanners,
    projectsHot,
    projects,
    projectDetail('1'),
    rankings,
    feedHot,
    feed,
    feedComments,
    tweetDetail('1'),
    projectIdeasFeed,
    projectIdeaDetail(1),
    projectIdeaVote(1),
    messages,
    messagesUnreadCount,
    messagesRead,
    chatThreads,
    chatMessages('1'),
    chatRead('1'),
    orderList,
    orderDetail,
    orderConfirm,
    orderMake,
    orderRefund('1'),
    unifiedPay,
    unifiedPayDetail,
    proxyBuyOrders,
    groupBuyOrders,
    groupBuyJoin,
    groupBuyCampaign(1),
    userProfile,
    userSignIn,
    addresses,
    addressDelete('1'),
    addressDefault('1'),
    moneyAccount,
    moneyAccountSequences,
    shopGoods,
    shopGoodsDetail(1),
    shopGoodsRedeem(1, 1),
    captcha,
    sendLoginCode,
    login,
  ];
}

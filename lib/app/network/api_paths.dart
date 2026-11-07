/// 前端调用的企划星 API 路径唯一清单。
///
/// 约定：
/// - 路径**不带**前导 `/`，由 `ApiClient` 的 `baseUrl` 负责拼接；
/// - 动态路径用静态方法生成，避免字符串拼接散落在各 API 文件；
/// - 新增端点时必须同步更新 `all` 与 `test/api_paths_test.dart`。
abstract final class ApiPaths {
  // ── catalog ──────────────────────────────────────────────────────────
  static const String homeBanners = 'v1/home/banners';
  static const String activitiesHot = 'v1/activities/hot';
  static const String activities = 'v1/activities';

  static String activityDetail(String id) => 'v3/activities/$id';

  // ── feed ─────────────────────────────────────────────────────────────
  static const String feedHot = 'v4/feed/hot';
  static const String feed = 'v1/feed';
  static const String feedComments = 'v1/userReply';

  static String tweetDetail(String id) => 'v1/tweets/$id';

  // ── message ──────────────────────────────────────────────────────────
  static const String messages = 'v1/messages';
  static const String messagesUnreadCount = 'v1/messages/unreadCount';
  static const String messagesRead = 'v1/messages/read';

  // ── order ────────────────────────────────────────────────────────────
  static const String orderList = 'v1/order/list';
  static const String orderDetail = 'v1/order/detail';
  static const String orderConfirm = 'v1/unifiedOrder/confirm';
  static const String orderMake = 'v3/unifiedOrder/makeOrder';

  // ── user ─────────────────────────────────────────────────────────────
  static const String userProfile = 'v1/user';
  static const String addresses = 'v1/myaddress';

  static String addressDelete(String id) => 'v1/myaddress/$id';
  static String addressDefault(String id) => 'v1/myaddress/default/$id';

  // ── auth ─────────────────────────────────────────────────────────────
  static const String captcha = 'v1/user/captcha';
  static const String sendLoginCode = 'v3/user/sendLoginCode';
  static const String login = 'v1/user/login';

  /// 所有实际使用的路径（动态段用示例 id `1` 展开），供契约自检。
  static List<String> get all => <String>[
    homeBanners,
    activitiesHot,
    activities,
    activityDetail('1'),
    feedHot,
    feed,
    feedComments,
    tweetDetail('1'),
    messages,
    messagesUnreadCount,
    messagesRead,
    orderList,
    orderDetail,
    orderConfirm,
    orderMake,
    userProfile,
    addresses,
    addressDelete('1'),
    addressDefault('1'),
    captcha,
    sendLoginCode,
    login,
  ];
}

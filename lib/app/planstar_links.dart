/// planstar:// 深链 → GoRoute path 的归一表。
///
/// 这里只登记已接线的目标路由（4 个 shell tab + 少量 push 路由），
/// 其余 host 未命中时回退首页，避免抛出未匹配异常。
/// 后续新增页面时在 [hostToPath] 中补映射即可，
/// 解析器本身无需改动。
class PlanstarLinks {
  const PlanstarLinks._();

  /// host → 已定义的 GoRoute path（不含需要路径参数的详情路由，见 [resolve]）。
  static const Map<String, String> hostToPath = <String, String>{
    // 首页 / 发现
    'home': '/',
    'discover': '/discover',
    'discover_hot': '/discover',
    'discover_follow': '/discover',
    'discover_tickets': '/discover',
    'category_home': '/discover',
    'floorylist': '/discover',
    'hot_tour_list': '/discover',
    // 消息
    'message': '/message',
    'notify_list': '/message',
    'notify_detail': '/message',
    'interact_message': '/message',
    'chat': '/message',
    'customer_service': '/message',
    // 订单
    'account_orderlist': '/order',
    'order_confirm': '/order/confirm',
    'order_proxy_buy_confirm': '/order/confirm',
    // 我的
    'account_home': '/me',
    'account_follow': '/me',
    'setting': '/me',
    'wallet_home': '/me',
    // 搜索（暂归发现 Tab）
    'search': '/discover',
    'search_activity': '/discover',
  };

  /// 把一个外部 URI（`planstar://host?query`）翻译成内部 GoRoute location。
  /// 无法识别时返回 null，由调用方决定回退策略。
  static String? resolve(Uri uri) {
    final host = _hostOf(uri);
    if (host == null) return null;

    // 需要路径参数的详情路由：id 从 query 取。
    final q = uri.queryParameters;
    if (host == 'activity_detail' || host == 'goods_detail' || host == 'show') {
      final id = q['showId'] ?? q['id'] ?? q['goodsId'];
      if (id != null && id.isNotEmpty) return '/show/$id';
    }

    final base = hostToPath[host];
    if (base == null) return null;
    return uri.query.isEmpty ? base : '$base?${uri.query}';
  }

  /// 自定义 scheme 时 host 在 `uri.host`；也兼容 `planstar:/home` 这类
  /// 把名字放在首段路径的写法。
  static String? _hostOf(Uri uri) {
    if (uri.host.isNotEmpty) return uri.host;
    if (uri.pathSegments.isNotEmpty) return uri.pathSegments.first;
    return null;
  }
}

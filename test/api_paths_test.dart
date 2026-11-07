import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/network/api_paths.dart';

void main() {
  // 与 `ApiPaths` 一一对应的契约清单；动态段用示例 id `1` 展开。
  const Set<String> expected = <String>{
    'v1/home/banners',
    'v1/projects/hot',
    'v1/projects',
    'v1/projects/1',
    'v1/rankings',
    'v4/feed/hot',
    'v1/feed',
    'v1/userReply',
    'v1/tweets/1',
    'v1/messages',
    'v1/messages/unreadCount',
    'v1/messages/read',
    'v1/chat/threads',
    'v1/chat/threads/1/messages',
    'v1/chat/threads/1/read',
    'v1/order/list',
    'v1/order/detail',
    'v1/unifiedOrder/confirm',
    'v3/unifiedOrder/makeOrder',
    'v1/order/1/refund',
    'v1/unifiedPay/pay',
    'v1/unifiedPay/payDetail',
    'v1/proxyBuyOrder/myOrders',
    'v1/pinTuanOrder/myOrders',
    'v1/pinTuanOrder/make',
    'v1/pinTuanCampaign/1',
    'v1/user',
    'v1/myaddress',
    'v1/myaddress/1',
    'v1/myaddress/default/1',
    'v1/user/captcha',
    'v3/user/sendLoginCode',
    'v1/user/login',
  };

  test('路径清单与契约完全一致（不多不少、无重复）', () {
    final actual = ApiPaths.all.toSet();
    expect(actual.length, ApiPaths.all.length, reason: '清单存在重复路径');
    expect(
      actual.difference(expected),
      isEmpty,
      reason: '清单中多出契约外路径：${actual.difference(expected)}',
    );
    expect(
      expected.difference(actual),
      isEmpty,
      reason: '清单缺少契约路径：${expected.difference(actual)}',
    );
  });

  test('所有路径均为 v1-v4 + 字母/数字/下划线/斜杠', () {
    final pattern = RegExp(r'^v[1-4]/[A-Za-z0-9_/-]+$');
    for (final path in ApiPaths.all) {
      expect(path, matches(pattern), reason: '路径格式不合法：$path');
    }
  });

  test('路径不带前导斜杠（由 baseUrl 拼接）', () {
    for (final path in ApiPaths.all) {
      expect(path.startsWith('/'), isFalse, reason: '路径不应带前导斜杠：$path');
    }
  });
}

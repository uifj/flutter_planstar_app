import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/planstar_links.dart';

void main() {
  group('PlanstarLinks.resolve', () {
    test('home → /', () {
      expect(PlanstarLinks.resolve(Uri.parse('planstar://home')), '/');
    });

    test('activity_detail?showId=888 → /show/888', () {
      expect(
        PlanstarLinks.resolve(
          Uri.parse('planstar://activity_detail?showId=888'),
        ),
        '/show/888',
      );
    });

    test('account_orderlist → /order', () {
      expect(
        PlanstarLinks.resolve(Uri.parse('planstar://account_orderlist')),
        '/order',
      );
    });

    test('未登记的 host → null（由调用方回退）', () {
      expect(
        PlanstarLinks.resolve(Uri.parse('planstar://no_such_host')),
        isNull,
      );
    });

    test('保留 query 透传', () {
      expect(
        PlanstarLinks.resolve(Uri.parse('planstar://discover?tab=hot')),
        '/discover?tab=hot',
      );
    });
  });
}

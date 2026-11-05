import 'package:flutter_test/flutter_test.dart';
import 'package:planstar/app/network/api_config.dart';
import 'package:planstar/app/network/device_identity.dart';

/// API 编译期默认配置的测试。
///
/// 本地 `assets/` 已整体移除，配置不再从 `api_config.json` 运行时读取，
/// 全部收敛到 [ApiConfig] 的编译期常量 + `--dart-define` 覆盖。
void main() {
  test('生产 base URL / 客户端类型 / UA', () {
    final config = ApiConfig.resolve();
    expect(config.baseUrl, ApiConfig.prodBaseUrl);
    // Dio 直接拼字符串：少这个斜杠会把 path 粘到域名上。
    expect(config.baseUrl.endsWith('/'), isTrue);
    expect(config.clientType, 11);
    expect(config.environment, ApiEnvironment.prod);
    expect(
      config.userAgent,
      'PlanstarApi (com.planstar.app/9.9.39 Xiaomi developer-default Android/14)',
    );
  });

  test('日志默认关闭', () {
    expect(ApiConfig.resolve().enableLogging, isFalse);
  });

  test('超时是有限值（不是 0 / 不是无限等）', () {
    final config = ApiConfig.resolve();
    expect(config.connectTimeout.inMilliseconds, greaterThan(0));
    expect(config.receiveTimeout.inMilliseconds, greaterThan(0));
    expect(config.sendTimeout.inMilliseconds, greaterThan(0));
  });

  group('dvid', () {
    test('37 字符：UUID 再追加一次第 4 位', () {
      final dvid = generateDvid();
      expect(dvid.length, 37);
      expect(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
              r'[0-9a-f]{12}[0-9a-f]$')
          .hasMatch(dvid), isTrue, reason: dvid);
    });

    test('每次生成都不一样（否则所有设备共用一个 id）', () {
      final ids = <String>{for (var i = 0; i < 20; i++) generateDvid()};
      expect(ids.length, 20);
    });
  });
}

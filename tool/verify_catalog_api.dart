// 演出库接口联调验证脚本（默认域名来自 `ApiConfig.resolve()`，可用 `--base=` 覆盖）。
//
// 和 `tool/verify_login_api.dart` 同一思路：用**生产代码里同一份**
// `PlanstarCatalogApi` 打真接口，验证请求形状、字段解析与分页/城市过滤行为，
// 而不是另抄一份 curl。
//
// 用法：
//
// ```bash
// dart run tool/verify_catalog_api.dart
// dart run tool/verify_catalog_api.dart --base=http://127.0.0.1:8098/
// ```
//
// 退出码：全部符合预期 → 0；有任何一条不符合 → 1（可直接进 CI 的 smoke）。
library;

import 'dart:io';

import 'package:core/network.dart';
import 'package:core/result.dart';
import 'package:dio/dio.dart';
import 'package:planstar/app/network/api_config.dart';
import 'package:planstar/app/network/device_identity.dart';
import 'package:planstar/app/network/ps_network_interceptor.dart';
import 'package:planstar/app/network/ps_request_context.dart';
import 'package:planstar/features/catalog/data/planstar_catalog_api.dart';
import 'package:planstar/features/catalog/domain/show_summary.dart';

final class CheckResult {
  const CheckResult({
    required this.name,
    required this.passed,
    required this.detail,
    this.observation = false,
  });

  final String name;
  final bool passed;
  final String detail;
  final bool observation;

  bool get failed => !passed && !observation;
}

Future<void> main(List<String> args) async {
  final Map<String, String> options = _parseArgs(args);
  final ApiConfig config = ApiConfig.resolve();
  final String baseUrl = options['base'] ?? config.baseUrl;

  final context = PsRequestContext(dvid: generateDvid());
  final dio = buildDio(
    baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    interceptors: <Interceptor>[
      PsNetworkInterceptor(context: context, userAgent: config.userAgent),
    ],
  );
  final api = PlanstarCatalogApi(client: ApiClient(dio));

  stdout.writeln('== 演出库接口联调 ==');
  stdout.writeln('base: $baseUrl');
  stdout.writeln('');

  final results = <CheckResult>[];
  final page1 = await _fetch(api, pageIndex: 1, pageSize: 5);
  results.add(_checkPage1(page1));
  if (page1 != null && page1.isNotEmpty) {
    results.add(await _checkPage2(api, page1));
    results.add(await _checkDetail(api, page1.first));
  }
  results.add(await _checkCity(api));
  results.add(await _checkHot(api));
  results.add(await _checkBanners(api));

  for (final CheckResult r in results) {
    final String tag = r.failed ? 'FAIL' : (r.observation ? 'OBS ' : 'PASS');
    stdout.writeln('[$tag] ${r.name}\n       ${r.detail}');
  }
  final int failed = results.where((CheckResult r) => r.failed).length;
  stdout.writeln('');
  stdout.writeln(failed == 0 ? '全部通过（${results.length} 项）' : '$failed 项不符合预期');
  exit(failed == 0 ? 0 : 1);
}

// ---------------------------------------------------------------------------
// 检查项
// ---------------------------------------------------------------------------

Future<List<ShowSummary>?> _fetch(
  PlanstarCatalogApi api, {
  int pageIndex = 1,
  int pageSize = 20,
  String? city,
}) async {
  final Result<List<ShowSummary>> result = await api.fetchShows(
    pageIndex: pageIndex,
    pageSize: pageSize,
    city: city,
  );
  return result.fold(onFailure: (Failure _) => null, onSuccess: (v) => v);
}

CheckResult _checkPage1(List<ShowSummary>? shows) {
  const name = '列表首页 GET v1/activities';
  if (shows == null) {
    return const CheckResult(name: name, passed: false, detail: '请求失败（见网络日志）');
  }
  if (shows.length != 5) {
    return CheckResult(
      name: name,
      passed: false,
      detail: 'pageSize=5 但返回 ${shows.length} 条',
    );
  }
  final ShowSummary first = shows.first;
  final bool complete =
      first.id.isNotEmpty &&
      first.title.isNotEmpty &&
      first.city.isNotEmpty &&
      first.venue.isNotEmpty;
  return CheckResult(
    name: name,
    passed: complete,
    detail: complete
        ? '5 条；首条 ${first.id} / ${first.title} / ${first.city} / ${first.priceFrom}'
        : '字段缺失：id=${first.id} title=${first.title} city=${first.city} venue=${first.venue}',
  );
}

Future<CheckResult> _checkPage2(
  PlanstarCatalogApi api,
  List<ShowSummary> page1,
) async {
  const name = '分页 page=2 与 page=1 不重叠';
  final page2 = await _fetch(api, pageIndex: 2, pageSize: 5);
  if (page2 == null) {
    return const CheckResult(name: name, passed: false, detail: '请求失败');
  }
  final firstIds = page1.map((ShowSummary s) => s.id).toSet();
  final overlap = page2.where((ShowSummary s) => firstIds.contains(s.id)).length;
  return CheckResult(
    name: name,
    passed: page2.isEmpty || overlap == 0,
    detail: 'page2=${page2.length} 条，重叠 $overlap 条',
  );
}

Future<CheckResult> _checkDetail(PlanstarCatalogApi api, ShowSummary show) async {
  final name = '详情 GET v3/activities/{id}';
  final Result<ShowSummary?> result = await api.fetchShowDetail(show.id);
  return result.fold(
    onFailure: (Failure f) => CheckResult(
      name: name,
      passed: false,
      detail: '失败：${f.type.name} / ${f.message}',
    ),
    onSuccess: (ShowSummary? detail) {
      if (detail == null) {
        return CheckResult(name: name, passed: false, detail: '返回 null');
      }
      final bool match = detail.id == show.id && detail.title.isNotEmpty;
      return CheckResult(
        name: name,
        passed: match,
        detail: match
            ? 'id=${detail.id}，票档 ${detail.tiers.length} 个，场次 ${detail.sessions.length} 个'
            : 'id 不一致：请求 ${show.id}，返回 ${detail.id}',
      );
    },
  );
}

Future<CheckResult> _checkCity(PlanstarCatalogApi api) async {
  const name = '城市过滤 GET v1/activities?city=上海';
  const city = '上海';
  final shows = await _fetch(api, pageSize: 50, city: city);
  if (shows == null) {
    return const CheckResult(name: name, passed: false, detail: '请求失败');
  }
  final other = shows.where((ShowSummary s) => !s.city.contains(city)).length;
  return CheckResult(
    name: name,
    passed: other == 0,
    detail: '${shows.length} 条，非「$city」$other 条',
  );
}

Future<CheckResult> _checkHot(PlanstarCatalogApi api) async {
  const name = '热门 GET v1/activities/hot';
  final Result<List<ShowSummary>> result = await api.fetchHotShows(pageSize: 5);
  return result.fold(
    onFailure: (Failure f) => CheckResult(
      name: name,
      passed: false,
      detail: '失败：${f.type.name} / ${f.message}',
    ),
    onSuccess: (List<ShowSummary> shows) => CheckResult(
      name: name,
      passed: shows.isNotEmpty,
      detail: '${shows.length} 条${shows.isEmpty ? '（空）' : '，首条 ${shows.first.title}'}',
    ),
  );
}

Future<CheckResult> _checkBanners(PlanstarCatalogApi api) async {
  const name = '首页 Banner GET v1/home/banners';
  final Result<List<BannerDto>> result = await api.fetchBanners();
  return result.fold(
    onFailure: (Failure f) => CheckResult(
      name: name,
      passed: false,
      observation: true,
      detail: '失败：${f.type.name} / ${f.message}',
    ),
    onSuccess: (List<BannerDto> banners) => CheckResult(
      name: name,
      passed: true,
      observation: banners.isEmpty,
      detail: '${banners.length} 条${banners.isEmpty ? '（运营未配置，观测项）' : ''}',
    ),
  );
}

// ---------------------------------------------------------------------------
// 工具
// ---------------------------------------------------------------------------

Map<String, String> _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (final String arg in args) {
    if (!arg.startsWith('--')) continue;
    final int eq = arg.indexOf('=');
    if (eq < 0) {
      map[arg.substring(2)] = 'true';
    } else {
      map[arg.substring(2, eq)] = arg.substring(eq + 1);
    }
  }
  return map;
}

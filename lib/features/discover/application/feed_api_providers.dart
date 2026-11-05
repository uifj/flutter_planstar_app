import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_feed_api.dart';

/// 动态 API 客户端。
final planstarFeedApiProvider = Provider<PlanstarFeedApi>(
  (ref) => PlanstarFeedApi(client: ref.watch(apiClientProvider)),
);

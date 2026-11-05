import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_order_api.dart';

/// 订单 API 客户端。
final planstarOrderApiProvider = Provider<PlanstarOrderApi>(
  (ref) => PlanstarOrderApi(client: ref.watch(apiClientProvider)),
);

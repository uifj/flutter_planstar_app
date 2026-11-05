import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_message_api.dart';

/// 消息 API 客户端。
final planstarMessageApiProvider = Provider<PlanstarMessageApi>(
  (ref) => PlanstarMessageApi(client: ref.watch(apiClientProvider)),
);

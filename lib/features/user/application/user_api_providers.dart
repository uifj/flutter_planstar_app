import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_user_api.dart';

/// 用户 API 客户端。
final planstarUserApiProvider = Provider<PlanstarUserApi>(
  (ref) => PlanstarUserApi(client: ref.watch(apiClientProvider)),
);

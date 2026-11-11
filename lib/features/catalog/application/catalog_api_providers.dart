import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/network/network_providers.dart';
import '../data/planstar_catalog_api.dart';

/// 企划库 API 客户端。
final planstarCatalogApiProvider = Provider<PlanstarCatalogApi>(
  (ref) => PlanstarCatalogApi(client: ref.watch(apiClientProvider)),
);

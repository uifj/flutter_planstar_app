// 应用 l10n 的唯一 import 入口（手写文件，不要删）。
//
// 页面里只需：
//
// ```dart
// import '../../l10n/l10n.dart';
//
// Text(context.l10n.appTitle);
// ```
//
// - ARB 源文件在 `lib/l10n/arb/`，生成产物在 `lib/l10n/generated/`；
// - 改完 ARB 必须运行 `dart tool/gen_l10n.dart`（CI 用 `--check` 拦截漏生成）；
// - 本文件保持手写，业务侧 import 路径不随产物目录迁移而改变；
// - 新增 feature 时，除了 `tool/gen_l10n.dart` 的 `targets`，还要在下面补一行
//   export。
//
// - `context.l10n` 由 [AppL10nBuildContext] 提供，返回扁平门面
//   [AppL10n]，不需要再写 `OrderLocalizations.of(context)` 这类长前缀；
// - [AppL10n] 按 feature 的生成类懒取文案，key 全局唯一由脚本校验；
// - 同时 re-export 各生成类，`AppLocalizations.delegate` /
//   `supportedLocales` 等静态成员照常可用。
library;

export 'generated/app_l10n.dart';
export 'generated/app_localizations.dart';
export 'generated/auth_localizations.dart';
export 'generated/catalog_localizations.dart';
export 'generated/discover_localizations.dart';
export 'generated/goods_localizations.dart';
export 'generated/group_buy_localizations.dart';
export 'generated/home_localizations.dart';
export 'generated/marketing_localizations.dart';
export 'generated/message_localizations.dart';
export 'generated/order_localizations.dart';
export 'generated/proxy_buy_localizations.dart';
export 'generated/search_localizations.dart';
export 'generated/user_localizations.dart';

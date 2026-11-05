/// 跨 feature 复用的展示组件。
///
/// 这一层**只做展示**：不 import 任何 `features/`，不读 provider，不碰领域模型。
/// 需要领域数据的地方由 `features/*` 自己适配（例如 `features/catalog/ui/show_cards.dart`
/// 就是"演出卡片"这个业务组件，它组合这里的基础件）。
///
/// 判断标准：一个组件能不能被"另一个完全不相干的业务"复用？
/// 能 → 放这里；只能被演出相关页面用 → 放 `features/catalog/ui`。
library;

export 'ps_badge.dart';
export 'ps_cell.dart';
export 'ps_empty_state.dart';
export 'ps_poster.dart';
export 'ps_price.dart';
export 'ps_search_bar.dart';
export 'ps_section_header.dart';
export 'ps_shortcut_grid.dart';
export 'ps_tag.dart';

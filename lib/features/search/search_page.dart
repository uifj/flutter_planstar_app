import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/ui/ps_tag.dart';
import '../catalog/domain/show_summary.dart';
import 'application/search_providers.dart';
import 'domain/search_models.dart';
import 'search_l10n.dart';
import '../../l10n/l10n.dart';

/// 搜索页（企划星 `SearchActivity` + `SearchHintFragment` / `SearchSuggestFrgment`）。
///
/// ## 三个状态
///
/// 1. **输入为空** → 搜索历史 + 热搜榜（原页的两块）；
/// 2. **正在输入** → 联想列表（演出标题/艺人）+ 顶部「搜索『xx』」；
/// 3. **提交** → 把词记进历史并跳到结果页。
///
/// ## 与 Android 的差异
///
/// - 原页的热搜是 `MarqueeView` 轮播 + 三列网格；这里用单列带排名的列表，
///   因为排名（1/2/3 高亮）比网格更能表达"热搜"的语义。
/// - 原页点联想词直接进详情页，点「搜索」才进结果页。这里保留了这个区分——
///   它是搜索体验里最容易做错的一处：联想词是"我确定要看这个"，
///   而「搜索」是"我想看更多"。
/// - **不做拼音/分词联想**（见 `search_providers.dart` 的说明）。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.initialQuery});

  /// 从别的页面带进来的初始词（例如首页搜索栏点了热搜）。
  final String? initialQuery;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery ?? '',
  );
  final FocusNode _focusNode = FocusNode();

  /// 当前输入（受控，用于切换"历史/联想"两个状态）。
  late String _input = widget.initialQuery ?? '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bool typing = _input.trim().isNotEmpty;

    return AdaptiveScaffold(
      backgroundColor: colors.bgPage,
      appBar: AdaptiveAppBar(titleWidget: _buildField(colors)),
      body: typing
          ? _buildSuggestions(context)
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                _buildHistory(context),
                const SizedBox(height: 8),
                _buildHot(context),
              ],
            ),
    );
  }

  /// 顶部的输入框（`view_search_input.xml`）。
  Widget _buildField(AppColors colors) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: colors.bgSubtle,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 10),
          Icon(LucideIcons.search, size: 16, color: colors.textTertiary),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.initialQuery == null,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 13, color: colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: context.l10n.searchPage_98,
                hintStyle: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              onChanged: (String value) => setState(() => _input = value),
              onSubmitted: _submit,
            ),
          ),
          if (_input.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _controller.clear();
                setState(() => _input = '');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  LucideIcons.circleX,
                  size: 15,
                  color: colors.textDisabled,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 搜索历史。
  Widget _buildHistory(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<String> history = ref.watch(searchHistoryProvider);
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionBar(
          title: context.l10n.searchPage_132,
          action: context.l10n.searchPage_133,
          onAction: () => ref.read(searchHistoryProvider.notifier).clear(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String word in history)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _submit(word),
                  // 长按删除：企划星是"点右上角编辑再删"，这里省掉一个状态。
                  onLongPress: () {
                    ref.read(searchHistoryProvider.notifier).remove(word);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.searchPage_150(word)),
                      ),
                    );
                  },
                  child: PsTag(
                    label: word,
                    tone: PsTagTone.soft,
                    color: colors.textSecondary,
                    fontSize: 12,
                    radius: 15,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Text(
            context.l10n.searchPage_171,
            style: TextStyle(fontSize: 11, color: colors.textDisabled),
          ),
        ),
      ],
    );
  }

  /// 热搜榜（`item_search_hot.xml`）。
  Widget _buildHot(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<HotKeyword> keywords = ref.watch(hotKeywordsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionBar(title: context.l10n.searchPage_187),
        for (final (int index, HotKeyword keyword) in keywords.indexed)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _submit(keyword.word),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        // 前三名用品牌色，其余用灰色——这是热搜榜唯一的视觉层级。
                        color: index < 3 ? colors.brand : colors.textDisabled,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      keyword.word,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    ),
                  ),
                  if (keyword.hot) ...<Widget>[
                    PsTag(
                      label: context.l10n.searchPage_219,
                      tone: PsTagTone.solid,
                      color: colors.price,
                      fontSize: 9,
                      radius: 2,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    keyword.hitLabelOf(context),
                    style: TextStyle(fontSize: 11, color: colors.textDisabled),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 联想列表。
  Widget _buildSuggestions(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final List<ShowSummary> suggestions = ref
        .watch(searchResultsProvider(_input))
        .shows
        .take(6)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _submit(_input),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: <Widget>[
                Icon(LucideIcons.search, size: 16, color: colors.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(text: context.l10n.searchPage_262),
                        TextSpan(
                          text: '「${_input.trim()}」',
                          style: TextStyle(
                            color: colors.brand,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 1, color: colors.divider),
        for (final ShowSummary show in suggestions)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // 联想词直接进详情（"我确定要看这个"），与 Android 行为一致。
            onTap: () => context.push('/show/${show.id}'),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: <Widget>[
                  Icon(LucideIcons.drama, size: 16, color: colors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          show.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${show.artist} · ${show.venueLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.arrowUpLeft,
                    size: 13,
                    color: colors.textDisabled,
                  ),
                ],
              ),
            ),
          ),
        if (suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
            child: Text(
              context.l10n.searchPage_325,
              style: TextStyle(fontSize: 12, color: colors.textTertiary),
            ),
          ),
      ],
    );
  }

  /// 提交搜索：记历史 + 进结果页。
  void _submit(String word) {
    final String trimmed = word.trim();
    if (trimmed.isEmpty) return;
    ref.read(searchHistoryProvider.notifier).add(trimmed);
    _focusNode.unfocus();
    context.push('/search/result?q=${Uri.encodeComponent(trimmed)}');
  }
}

/// 分区标题（左侧标题 + 可选右侧动作）。
class _SectionBar extends StatelessWidget {
  const _SectionBar({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          if (action != null && onAction != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  action!,
                  style: TextStyle(fontSize: 12, color: colors.textTertiary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

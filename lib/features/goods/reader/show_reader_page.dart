import 'package:flutter/material.dart';
import 'package:flutter_book_reader/flutter_book_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/show_summary.dart';
import 'show_book_source.dart';

/// 企划阅读页：用 `flutter_book_reader` 把企划详情当电子书读。
///
/// 进入方式有两条：
/// - 详情页「阅读企划」按钮 `context.push('/show/:id/read', extra: show)`，
///   [initialShow] 带的是**已加载的完整详情**，进入即可分页，不再重复请求；
/// - 直接命中路由（深链 / 冷启动），此时等 `showDetailProvider` 拉到数据再建阅读器。
///
/// 为什么必须等数据齐了才构建 [BookReader]：
/// 阅读器只在初始化时读取 [ShowBookSource] 的清单与章节，数据后到再换 source
/// 不会重新加载，会出现「目录 8 章、正文全空」的假象。所以加载期间先给进度圈。
class ShowReaderPage extends ConsumerStatefulWidget {
  const ShowReaderPage({super.key, required this.showId, this.initialShow});

  final String showId;
  final ShowSummary? initialShow;

  @override
  ConsumerState<ShowReaderPage> createState() => _ShowReaderPageState();
}

class _ShowReaderPageState extends ConsumerState<ShowReaderPage> {
  final InMemoryReaderProgressStore _progressStore =
      InMemoryReaderProgressStore();
  ReaderConfig? _config;
  ShowBookSource? _source;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_config != null) return;
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    _config = ReaderConfig()
      // 与 App 其它页面同一套中文字体；不传则回落到系统字体，正文观感会变。
      ..setFontFamily(appFontFamily)
      // 默认米黄纸色 + 品牌色强调，夜间主题等仍可在阅读器菜单里切换。
      ..setTheme(ReaderTheme.yellow.copyWith(accentColor: colors.brand))
      // 仿真翻页是电子书阅读器的默认预期；上下滚动可在菜单「翻页方式」里切换。
      ..setFlipType(FlipType.simulation);
  }

  @override
  void dispose() {
    _config?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ShowSummary? show = _resolveShow();
    if (show == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    _source ??= ShowBookSource(
      show: show,
      l10n: context.l10n,
      coverColor: colors.brand,
    );
    return BookReader(
      source: _source!,
      config: _config,
      progressStore: _progressStore,
      labels: ReaderLabels.forLanguageCode(
        Localizations.localeOf(context).languageCode,
      ),
      onClose: () => context.pop(),
    );
  }

  ShowSummary? _resolveShow() {
    final initial = widget.initialShow;
    if (initial != null) return initial;
    final detail = ref.watch(showDetailProvider(widget.showId)).valueOrNull;
    return detail ?? ref.watch(showByIdProvider(widget.showId));
  }
}

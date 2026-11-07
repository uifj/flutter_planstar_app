/// 搜索文本归一化：大小写、标点、分词与拼音索引。
///
/// 拼音使用纯 Dart 包 `lpinyin`（全拼 + 首字母），不需要平台通道。
/// 它按词典的首选读音转换，多音字/生僻字可能不是用户期望的读音
/// （例如「重」在「重庆」里由词组词典处理，但孤立的人名仍可能读错）。
/// 因此拼音只作为**额外的命中通道**，原文 `contains` 始终保留；
/// 拼音查不到时，中文输入仍能按原文命中。
library;

import 'package:lpinyin/lpinyin.dart';

/// 多字段拼接时的分隔符：避免「上一个字段的尾部 + 下一个字段的首部」
/// 拼出一个本不存在的命中。
const String _fieldSeparator = '\u0001';

/// 查询分词符：空白与常见中英文标点。
final RegExp _querySeparators = RegExp(
  r'''[\s,，、;；:：/\\|+._\-·。！？!?()（）\[\]【】{}<>《》"'“”‘’~～@#$%^&*]+''',
);

/// 拼音索引里只保留小写字母与数字。
final RegExp _pinyinNoise = RegExp(r'[^a-z0-9]');

/// 归一化单个搜索词：小写 + 去标点（保留汉字与字母数字）。
String normalizeSearchToken(String raw) =>
    raw.toLowerCase().replaceAll(_querySeparators, '');

/// 把原始查询按空白/标点切成多个词，并逐个归一化。
///
/// 空词会被丢弃；多个词之间是 **AND** 关系（每个词都要命中）。
List<String> tokenizeSearchQuery(String rawQuery) => rawQuery
    .toLowerCase()
    .split(_querySeparators)
    .map(normalizeSearchToken)
    .where((String token) => token.isNotEmpty)
    .toList(growable: false);

/// 汉字转拼音全拼（小写、无分隔），如「游戏」→ `youxi`。
String pinyinOf(String text) => _safePinyin(text);

/// 汉字转拼音首字母（小写、无分隔），如「游戏」→ `yx`。
String pinyinInitialsOf(String text) => _safeInitials(text);

String _safePinyin(String text) {
  if (text.isEmpty) return '';
  try {
    return PinyinHelper.getPinyin(
      text,
      separator: '',
    ).toLowerCase().replaceAll(_pinyinNoise, '');
  } catch (_) {
    // 生僻字不在词典里时退回原文匹配，不让一条数据拖垮整个搜索。
    return '';
  }
}

String _safeInitials(String text) {
  if (text.isEmpty) return '';
  try {
    return PinyinHelper.getShortPinyin(
      text,
    ).toLowerCase().replaceAll(_pinyinNoise, '');
  } catch (_) {
    return '';
  }
}

/// 一条记录（演出 / 动态）的可检索索引。
///
/// 同时保存三个通道：
/// - [text]：各字段原文（小写），保留原有 `contains` 行为；
/// - [pinyin]：各字段的全拼（小写、无分隔），支持 `youxi`；
/// - [initials]：各字段的首字母，支持 `yx`。
final class SearchTextIndex {
  const SearchTextIndex._(this._text, this._pinyin, this._initials);

  /// 由若干字段构造索引。空字段会被跳过。
  factory SearchTextIndex.fromFields(Iterable<String> fields) {
    final List<String> text = <String>[];
    final List<String> pinyin = <String>[];
    final List<String> initials = <String>[];

    for (final String field in fields) {
      final String value = field.trim();
      if (value.isEmpty) continue;
      text.add(value.toLowerCase());

      final String full = _safePinyin(value);
      if (full.isNotEmpty) pinyin.add(full);

      final String short = _safeInitials(value);
      if (short.isNotEmpty) initials.add(short);
    }

    return SearchTextIndex._(
      text.join(_fieldSeparator),
      pinyin.join(_fieldSeparator),
      initials.join(_fieldSeparator),
    );
  }

  final String _text;
  final String _pinyin;
  final String _initials;

  /// 单个词是否命中（原文 / 全拼 / 首字母任一通道）。
  bool matchesToken(String rawToken) {
    final String token = normalizeSearchToken(rawToken);
    if (token.isEmpty) return true;
    if (_text.contains(token) ||
        _pinyin.contains(token) ||
        _initials.contains(token)) {
      return true;
    }

    // 输入是汉字时，再拿它的拼音/首字母试一次（例如输入「游戏」也应命中
    // 只存了拼音索引的字段）。
    final String tokenPinyin = _safePinyin(token);
    if (tokenPinyin.isNotEmpty &&
        tokenPinyin != token &&
        _pinyin.contains(tokenPinyin)) {
      return true;
    }
    final String tokenInitials = _safeInitials(token);
    if (tokenInitials.isNotEmpty &&
        tokenInitials != token &&
        _initials.contains(tokenInitials)) {
      return true;
    }
    return false;
  }

  /// 多个词全部命中才算命中（AND 语义）。
  bool matchesAll(Iterable<String> tokens) =>
      tokens.every((String token) => matchesToken(token));
}

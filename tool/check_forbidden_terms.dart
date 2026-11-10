// 演出票务语义静态门禁。
//
// 企划星的产品口径是「企划 / 审批（通过·驳回）/ 回报档位 / 支持」，历史演出票务文案不应再出现在
// 用户可见文案里。本脚本扫描：
//   - `lib/**/*.dart` 的字符串字面量（注释不算）；
//   - `lib/l10n/arb/**/*.arb` 的文案值（`@key` 元数据 / description 不算）。
//
// 命中先查 `tool/forbidden_terms_whitelist.json`：
//   { "path": "lib/l10n/arb/features/order/order_zh.arb", "term": "场次",
//     "reason": "线下回报场次，必须保留" }
// `path` 支持 `*` 通配（`*` 可跨目录，等价于 `.*`）。
//
// 例外规则：`场次` / `座位` 只允许出现在线下回报上下文。命中所在行（或字符串）
// 含有「线下」时视为合规，无需白名单。
//
// 用法：
//   dart tool/check_forbidden_terms.dart          人类可读输出
//   dart tool/check_forbidden_terms.dart --json   CI 消费用
//
// 退出码：0 = 通过；1 = 存在白名单外命中或配置错误。
import 'dart:convert';
import 'dart:io';

/// 无条件禁止的词。
const List<String> forbiddenTerms = <String>[
  '演出',
  '观演',
  '票档',
  '抢票',
  '代抢',
  '开票',
  '门票',
  '剧院',
  '演唱会',
  '艺人',
];

/// 只允许出现在线下回报上下文的词。
const List<String> offlineOnlyTerms = <String>['场次', '座位'];

/// 线下回报上下文标记。
const String offlineMarker = '线下';

/// 白名单文件（相对工程根）。
const String whitelistPath = 'tool/forbidden_terms_whitelist.json';

/// 一条命中。
final class Hit {
  const Hit({
    required this.path,
    required this.line,
    required this.term,
    required this.snippet,
  });

  final String path;
  final int line;
  final String term;
  final String snippet;

  Map<String, Object> toJson() => <String, Object>{
    'path': path,
    'line': line,
    'term': term,
    'snippet': snippet,
  };

  @override
  String toString() => '$path:$line: $term: $snippet';
}

/// 一条白名单。
final class WhitelistEntry {
  WhitelistEntry({
    required this.path,
    required this.term,
    required this.reason,
  });

  final String path;
  final String term;
  final String reason;

  late final RegExp _pattern = RegExp(
    '^${RegExp.escape(path).replaceAll(r'\*', '.*').replaceAll(r'\?', '.')}\$',
  );

  bool matches(String file, String hitTerm) =>
      term == hitTerm && _pattern.hasMatch(file);
}

Future<void> main(List<String> args) async {
  final bool asJson = args.contains('--json');
  final List<WhitelistEntry> whitelist = _loadWhitelist();

  final List<File> files = _collectFiles();
  final List<Hit> hits = <Hit>[];
  var contextExemptions = 0;

  for (final file in files) {
    final relative = _relative(file.path);
    final List<Hit> found = file.path.endsWith('.arb')
        ? _scanArb(relative, file.readAsStringSync())
        : _scanDart(relative, file.readAsStringSync());

    for (final hit in found) {
      if (offlineOnlyTerms.contains(hit.term) &&
          hit.snippet.contains(offlineMarker)) {
        contextExemptions++;
        continue;
      }
      if (whitelist.any((entry) => entry.matches(hit.path, hit.term))) {
        continue;
      }
      hits.add(hit);
    }
  }

  hits.sort((a, b) {
    final pathOrder = a.path.compareTo(b.path);
    return pathOrder != 0 ? pathOrder : a.line.compareTo(b.line);
  });

  if (asJson) {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(<String, Object>{
        'scannedFiles': files.length,
        'violations': hits.map((hit) => hit.toJson()).toList(),
        'whitelistEntries': whitelist.length,
        'contextExemptions': contextExemptions,
        'ok': hits.isEmpty,
      }),
    );
  } else {
    for (final hit in hits) {
      stdout.writeln(hit);
    }
    stdout.writeln(
      '扫描 ${files.length} 个文件；白名单 ${whitelist.length} 条；'
      '线下上下文豁免 $contextExemptions 处；命中 ${hits.length} 处。',
    );
    if (hits.isEmpty) {
      stdout.writeln('✓ 未发现演出票务语义');
    } else {
      stderr.writeln('✗ 发现 ${hits.length} 处演出票务语义，请改写为企划口径');
    }
  }

  if (hits.isNotEmpty) {
    exit(1);
  }
}

/// 收集待扫描文件：Dart 源码 + ARB 文案。
List<File> _collectFiles() {
  final List<File> files = <File>[];
  final Directory lib = Directory('lib');
  if (!lib.existsSync()) {
    stderr.writeln('✗ 找不到 lib/（请在 flutter_piaoniu_app 工程根运行）');
    exit(1);
  }
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll(Platform.pathSeparator, '/');
    if (path.endsWith('.dart') || path.endsWith('.arb')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));
  return files;
}

/// 读取白名单；文件缺失视为空，格式错误直接失败。
List<WhitelistEntry> _loadWhitelist() {
  final File file = File(whitelistPath);
  if (!file.existsSync()) {
    return <WhitelistEntry>[];
  }
  final Object? decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List<Object?>) {
    stderr.writeln('✗ $whitelistPath 必须是数组');
    exit(1);
  }
  return decoded.map((item) {
    if (item is! Map<String, Object?> ||
        item['path'] is! String ||
        item['term'] is! String ||
        item['reason'] is! String) {
      stderr.writeln('✗ $whitelistPath 条目缺少 path/term/reason：$item');
      exit(1);
    }
    return WhitelistEntry(
      path: item['path']! as String,
      term: item['term']! as String,
      reason: item['reason']! as String,
    );
  }).toList(growable: false);
}

/// 扫描 ARB：只检查文案值，跳过 `@key` 元数据（含 description）。
List<Hit> _scanArb(String path, String source) {
  final List<Hit> hits = <Hit>[];
  final List<String> lines = source.split('\n');
  var inMetadata = false;
  var metadataDepth = 0;

  for (var index = 0; index < lines.length; index++) {
    final String line = lines[index];
    if (inMetadata) {
      metadataDepth += _braceDepth(line);
      if (metadataDepth <= 0) {
        inMetadata = false;
      }
      continue;
    }

    final Match? key = RegExp(r'^\s*"(@@?[^"]*)"\s*:').firstMatch(line);
    if (key != null) {
      // 元数据对象（`"@key": { ... }`）整体跳过；`@@locale` 等单值行直接跳过。
      final int depth = _braceDepth(line.substring(key.end));
      if (depth > 0) {
        inMetadata = true;
        metadataDepth = depth;
      }
      continue;
    }

    hits.addAll(_matchLine(path, index + 1, line));
  }
  return hits;
}

/// 统计一行中字符串外的花括号净深度。
int _braceDepth(String line) {
  var depth = 0;
  var inString = false;
  var escaped = false;
  for (var i = 0; i < line.length; i++) {
    final String char = line[i];
    if (inString) {
      if (escaped) {
        escaped = false;
      } else if (char == r'\') {
        escaped = true;
      } else if (char == '"') {
        inString = false;
      }
      continue;
    }
    if (char == '"') {
      inString = true;
    } else if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
    }
  }
  return depth;
}

/// 扫描 Dart：跳过行注释、块注释，只检查字符串字面量。
List<Hit> _scanDart(String path, String source) {
  final List<Hit> hits = <Hit>[];
  var index = 0;
  var line = 1;

  while (index < source.length) {
    final String char = source[index];
    if (char == '\n') {
      line++;
      index++;
      continue;
    }
    if (char == '/' && index + 1 < source.length) {
      final String next = source[index + 1];
      if (next == '/') {
        index = source.indexOf('\n', index);
        if (index < 0) break;
        continue;
      }
      if (next == '*') {
        final int end = source.indexOf('*/', index + 2);
        if (end < 0) break;
        line += '\n'.allMatches(source.substring(index, end)).length;
        index = end + 2;
        continue;
      }
    }
    if (char == '"' || char == "'") {
      final int startLine = line;
      final _Literal literal = _readString(source, index, line);
      hits.addAll(_matchText(path, startLine, literal.value));
      line = literal.endLine;
      index = literal.end;
      continue;
    }
    index++;
  }
  return hits;
}

/// 读取一个 Dart 字符串字面量（普通/原始/三引号）。
final class _Literal {
  const _Literal({
    required this.value,
    required this.end,
    required this.endLine,
  });

  final String value;
  final int end;
  final int endLine;
}

_Literal _readString(String source, int start, int startLine) {
  final String quote = source[start];
  final bool triple =
      start + 2 < source.length &&
      source[start + 1] == quote &&
      source[start + 2] == quote;
  final String terminator = triple ? quote * 3 : quote;
  var index = start + terminator.length;
  var line = startLine;
  final StringBuffer buffer = StringBuffer();
  var escaped = false;

  while (index < source.length) {
    if (source.startsWith(terminator, index)) {
      return _Literal(
        value: buffer.toString(),
        end: index + terminator.length,
        endLine: line,
      );
    }
    final String char = source[index];
    if (char == '\n') {
      line++;
    }
    if (!escaped && char == r'\') {
      escaped = true;
      index++;
      continue;
    }
    escaped = false;
    buffer.write(char);
    index++;
  }
  return _Literal(value: buffer.toString(), end: index, endLine: line);
}

/// 在单行文本里匹配禁词。
List<Hit> _matchLine(String path, int lineNumber, String line) {
  return _matchText(path, lineNumber, line);
}

/// 在文本里匹配禁词；`snippet` 会压缩空白并截断。
List<Hit> _matchText(String path, int lineNumber, String text) {
  final List<Hit> hits = <Hit>[];
  final String snippet = _snippet(text);
  for (final term in <String>[...forbiddenTerms, ...offlineOnlyTerms]) {
    if (text.contains(term)) {
      hits.add(
        Hit(path: path, line: lineNumber, term: term, snippet: snippet),
      );
    }
  }
  return hits;
}

String _snippet(String text) {
  final String compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  const int maxLength = 120;
  return compact.length <= maxLength
      ? compact
      : '${compact.substring(0, maxLength)}…';
}

String _relative(String path) =>
    path.replaceAll(Platform.pathSeparator, '/');

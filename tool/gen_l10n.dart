// 统一的 l10n 生成入口：应用级 + 每个 feature 各一套 ARB。
//
// 为什么需要这个脚本，而不是直接用 `flutter gen-l10n`：
//
// `flutter gen-l10n` 只读**当前工作目录**的 `l10n.yaml`，而且一旦发现它存在，
// 就会**忽略全部命令行参数**（输出 "Because l10n.yaml exists, the options
// defined there will be used instead."）。也就是说，一个 Flutter 工程里
// 无法用常规方式维护多套 l10n 配置。
//
// 三种可选解法：
//   1. 每个 feature 拆成独立 pub package（各自有 l10n.yaml）—— 最干净，但要
//      连业务代码一起搬，`features/order/` 正在被并行开发，搬迁风险高；
//   2. 把所有文案塞回一个巨型 ARB —— 就是 §3.4 要治的病；
//   3. 生成时临时把根 `l10n.yaml` 挪开，用命令行参数逐套生成 —— 本脚本。
//
// 这里选 3，并把它固化成一个可重复执行、失败会报错的入口，避免变成
// "某个人的机器上知道要先改个文件名" 的口头知识。
//
// 用法：
//   dart tool/gen_l10n.dart           生成到 `lib/l10n/generated/`（默认）
//   dart tool/gen_l10n.dart --check   生成到临时目录并与已入库产物逐文件比对
//
// 失败条件（exit code 1）：
//   - 某套 ARB 生成失败；
//   - 某套 ARB 有未翻译的 key（缺 en 或 zh）；
//   - `--check` 下临时产物与已入库的 `lib/l10n/generated/` 不一致。
//
// 注意：`flutter build` / `flutter run` 在 `generate: true` 下会自动重新生成
// **应用级** l10n（读 l10n.yaml），但不会管 feature 级。feature 级必须跑本脚本，
// 因此生成产物**需要入库**（否则新克隆的仓库编译不过）。
import 'dart:convert';
import 'dart:io';

/// 一套 l10n 配置。
final class L10nTarget {
  /// 创建配置。
  const L10nTarget({
    required this.label,
    required this.arbDir,
    required this.template,
    required this.outputFile,
    required this.className,
  });

  /// 人类可读名称（日志用）。
  final String label;

  /// ARB 目录（相对工程根）。
  final String arbDir;

  /// 模板 ARB 文件名（zh 为源语言）。
  final String template;

  /// 生成的 dart 文件名。
  final String outputFile;

  /// 生成的类名。
  final String className;

  /// 门面内部字段名：`OrderLocalizations` → `order`。
  String get field {
    const String suffix = 'Localizations';
    final String base = className.endsWith(suffix)
        ? className.substring(0, className.length - suffix.length)
        : className;
    return base.isEmpty ? 'app' : base[0].toLowerCase() + base.substring(1);
  }
}

/// 生成类里的一条文案成员（getter 或带参方法）。
final class _Message {
  const _Message({
    required this.name,
    required this.params,
    required this.parameterNames,
    required this.owner,
  });

  /// 文案 key，同时是生成的方法名。
  final String name;

  /// 形参列表原文（`null` 表示无参 getter）。
  final String? params;

  /// 形参名（按位置顺序）。
  final List<String> parameterNames;

  /// 归属的生成类。
  final L10nTarget owner;
}

/// ARB 源文件根目录：应用级在根，feature 级在 `features/` 下。
const String arbRoot = 'lib/l10n/arb';

/// feature 级 ARB 根目录。
const String featureArbRoot = '$arbRoot/features';

/// 生成 Dart 文件的目录（统一一处，源与产物分开）。
const String generatedDir = 'lib/l10n/generated';

/// 全部目标。新增 feature 时在这里加一行即可。
const List<L10nTarget> targets = <L10nTarget>[
  L10nTarget(
    label: 'app（跨 feature 共用）',
    arbDir: arbRoot,
    template: 'app_zh.arb',
    outputFile: 'app_localizations.dart',
    className: 'AppLocalizations',
  ),
  L10nTarget(
    label: 'features/auth',
    arbDir: '$featureArbRoot/auth',
    template: 'auth_zh.arb',
    outputFile: 'auth_localizations.dart',
    className: 'AuthLocalizations',
  ),
  L10nTarget(
    label: 'features/catalog',
    arbDir: '$featureArbRoot/catalog',
    template: 'catalog_zh.arb',
    outputFile: 'catalog_localizations.dart',
    className: 'CatalogLocalizations',
  ),
  L10nTarget(
    label: 'features/discover',
    arbDir: '$featureArbRoot/discover',
    template: 'discover_zh.arb',
    outputFile: 'discover_localizations.dart',
    className: 'DiscoverLocalizations',
  ),
  L10nTarget(
    label: 'features/goods',
    arbDir: '$featureArbRoot/goods',
    template: 'goods_zh.arb',
    outputFile: 'goods_localizations.dart',
    className: 'GoodsLocalizations',
  ),
  L10nTarget(
    label: 'features/group_buy',
    arbDir: '$featureArbRoot/group_buy',
    template: 'group_buy_zh.arb',
    outputFile: 'group_buy_localizations.dart',
    className: 'GroupBuyLocalizations',
  ),
  L10nTarget(
    label: 'features/home',
    arbDir: '$featureArbRoot/home',
    template: 'home_zh.arb',
    outputFile: 'home_localizations.dart',
    className: 'HomeLocalizations',
  ),
  L10nTarget(
    label: 'features/marketing',
    arbDir: '$featureArbRoot/marketing',
    template: 'marketing_zh.arb',
    outputFile: 'marketing_localizations.dart',
    className: 'MarketingLocalizations',
  ),
  L10nTarget(
    label: 'features/message',
    arbDir: '$featureArbRoot/message',
    template: 'message_zh.arb',
    outputFile: 'message_localizations.dart',
    className: 'MessageLocalizations',
  ),
  L10nTarget(
    label: 'features/order',
    arbDir: '$featureArbRoot/order',
    template: 'order_zh.arb',
    outputFile: 'order_localizations.dart',
    className: 'OrderLocalizations',
  ),
  L10nTarget(
    label: 'features/proxy_buy',
    arbDir: '$featureArbRoot/proxy_buy',
    template: 'proxy_buy_zh.arb',
    outputFile: 'proxy_buy_localizations.dart',
    className: 'ProxyBuyLocalizations',
  ),
  L10nTarget(
    label: 'features/search',
    arbDir: '$featureArbRoot/search',
    template: 'search_zh.arb',
    outputFile: 'search_localizations.dart',
    className: 'SearchLocalizations',
  ),
  L10nTarget(
    label: 'features/user',
    arbDir: '$featureArbRoot/user',
    template: 'user_zh.arb',
    outputFile: 'user_localizations.dart',
    className: 'UserLocalizations',
  ),
];

const String _l10nYaml = 'l10n.yaml';
const String _l10nYamlBackup = 'l10n.yaml.gen-bak';
const String _untranslatedDir = 'build/untranslated';

/// `--check` 的临时输出目录（位于 build/ 下，不参与入库）。
const String _checkDir = 'build/l10n_check/generated';

Future<void> main(List<String> args) async {
  final bool check = args.contains('--check');
  // `--facade-only` 只重建 AppL10n 门面：改注释/门面逻辑时不必等
  // 13 套 gen-l10n 全部重跑。
  final bool facadeOnly = args.contains('--facade-only');

  if (check && facadeOnly) {
    stderr.writeln('✗ --check 与 --facade-only 不能同时使用');
    exit(1);
  }

  final String outputRoot = check ? _checkDir : generatedDir;
  if (check) {
    final stale = Directory(_checkDir);
    if (stale.existsSync()) {
      stale.deleteSync(recursive: true);
    }
  }
  Directory(outputRoot).createSync(recursive: true);

  var failed = 0;
  final problems = <String>[];

  if (facadeOnly) {
    stdout.writeln('→ 跳过 gen-l10n，只重建 AppL10n 门面');
  } else {
    final l10nYaml = File(_l10nYaml);
    if (!l10nYaml.existsSync()) {
      stderr.writeln('✗ 找不到 $l10nYaml（应在工程根运行本脚本）');
      exit(1);
    }

    // 先把 l10n.yaml 挪开：否则 gen-l10n 会忽略我们传的命令行参数。
    final backup = l10nYaml.renameSync(_l10nYamlBackup);
    try {
      Directory(_untranslatedDir).createSync(recursive: true);

      for (final target in targets) {
        stdout.writeln('→ ${target.label}  (${target.arbDir})');
        final untranslatedPath = '$_untranslatedDir/${target.className}.json';

        final result = await Process.run(
          Platform.isWindows ? 'flutter.bat' : 'flutter',
          <String>[
            'gen-l10n',
            '--arb-dir=${target.arbDir}',
            '--output-dir=$outputRoot',
            '--template-arb-file=${target.template}',
            '--output-localization-file=${target.outputFile}',
            '--output-class=${target.className}',
            '--no-nullable-getter',
            '--untranslated-messages-file=$untranslatedPath',
          ],
          runInShell: true,
        );

        if (result.exitCode != 0) {
          failed++;
          problems.add(
            '${target.label} 生成失败：\n${result.stderr}${result.stdout}',
          );
          continue;
        }

        // 未翻译检查：只要 JSON 非空就说明有 key 缺某个语种。
        final untranslated = File(untranslatedPath);
        if (untranslated.existsSync()) {
          final decoded = jsonDecode(untranslated.readAsStringSync());
          if (decoded is Map<Object?, Object?> && decoded.isNotEmpty) {
            failed++;
            problems.add('${target.label} 有未翻译 key：$decoded');
          }
        }
      }
    } finally {
      // 无论成败都要还原，否则下次 `flutter pub get` 会找不到 l10n.yaml。
      if (backup.existsSync()) {
        backup.renameSync(_l10nYaml);
      }
    }
  }

  if (failed > 0) {
    stderr.writeln('\n✗ $failed 个目标有问题：');
    for (final problem in problems) {
      stderr.writeln('  - $problem');
    }
    exit(1);
  }

  try {
    _writeFacade(_collectMessages(outputRoot), outputRoot);
  } on StateError catch (error) {
    stderr.writeln('✗ 构建 AppL10n 门面失败：${error.message}');
    exit(1);
  }

  if (check) {
    final diffs = _diffGenerated(outputRoot, generatedDir);
    if (diffs.isNotEmpty) {
      stderr.writeln(
        '\n✗ 生成产物与已入库的 $generatedDir 不一致（${diffs.length} 处）：',
      );
      for (final diff in diffs) {
        stderr.writeln('  - $diff');
      }
      stderr.writeln('\n请运行 dart tool/gen_l10n.dart 并提交 $generatedDir');
      exit(1);
    }
    stdout.writeln('✓ 生成产物与 $generatedDir 完全一致');
    return;
  }

  stdout.writeln('\n✓ ${targets.length} 套 l10n 全部生成完成，无未翻译 key');
}

/// 逐文件比较临时产物与已入库产物，返回差异描述（空表示一致）。
List<String> _diffGenerated(String actualDir, String expectedDir) {
  final Set<String> actual = _relativeFiles(actualDir);
  final Set<String> expected = _relativeFiles(expectedDir);
  final List<String> diffs = <String>[];

  for (final name in actual.difference(expected).toList()..sort()) {
    diffs.add('未入库：$name');
  }
  for (final name in expected.difference(actual).toList()..sort()) {
    diffs.add('缺失：$name');
  }
  for (final name in actual.intersection(expected).toList()..sort()) {
    if (!_sameBytes(
      File('$actualDir/$name').readAsBytesSync(),
      File('$expectedDir/$name').readAsBytesSync(),
    )) {
      diffs.add('内容不一致：$name');
    }
  }
  return diffs;
}

/// 列出目录下全部文件的相对路径（统一用 `/` 分隔）。
Set<String> _relativeFiles(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) {
    return <String>{};
  }
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .map(
        (file) => file.path
            .substring(root.path.length + 1)
            .replaceAll(Platform.pathSeparator, '/'),
      )
      .toSet();
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var index = 0; index < a.length; index++) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

/// 从各生成类里收集全部文案成员，并保证 key 全局唯一。
List<_Message> _collectMessages(String outputRoot) {
  final Map<String, _Message> byKey = <String, _Message>{};
  for (final target in targets) {
    final file = File('$outputRoot/${target.outputFile}');
    if (!file.existsSync()) {
      throw StateError('找不到 ${file.path}，请先运行 dart tool/gen_l10n.dart');
    }
    for (final message in _parseMessages(file, target)) {
      final existing = byKey[message.name];
      if (existing != null) {
        throw StateError(
          '文案 key `${message.name}` 在 ${existing.owner.label} 与 '
          '${message.owner.label} 重复；AppL10n 是扁平命名空间，key 必须全局唯一',
        );
      }
      byKey[message.name] = message;
    }
  }
  return byKey.values.toList(growable: false);
}

/// 解析生成类里 `abstract class <ClassName>` 的成员声明。
///
/// 只认 `String get xxx;` / `String xxx(参数);` 两种形态——这正是 gen-l10n
/// 输出的文案成员，`localeName` 是字段、`of/delegate` 是静态成员，都不会误收。
Iterable<_Message> _parseMessages(File file, L10nTarget target) sync* {
  final source = file.readAsStringSync();
  final marker = 'abstract class ${target.className} {';
  final classStart = source.indexOf(marker);
  if (classStart < 0) {
    throw StateError('${file.path} 中没有 `$marker`');
  }

  final int bodyStart = classStart + marker.length;
  var depth = 1;
  var index = bodyStart;
  while (index < source.length && depth > 0) {
    final code = source.codeUnitAt(index);
    if (code == 0x7B) depth++;
    if (code == 0x7D) depth--;
    index++;
  }
  if (depth != 0) {
    throw StateError('${file.path} 的 ${target.className} 括号不匹配');
  }
  final body = source.substring(bodyStart, index - 1);

  // 注释里可能带分号，先逐行去掉注释，再按 `;` 切分声明。
  final cleaned = body
      .split('\n')
      .where((line) => !line.trimLeft().startsWith('//'))
      .join('\n');

  for (final raw in cleaned.split(';')) {
    final declaration = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!declaration.startsWith('String ')) {
      continue;
    }
    final match = RegExp(
      r'^String (?:get )?([A-Za-z_][A-Za-z0-9_]*)(?:\((.*)\))?$',
    ).firstMatch(declaration);
    if (match == null) {
      continue;
    }

    final params = match.group(2);
    final names = <String>[];
    if (params != null && params.trim().isNotEmpty) {
      for (final part in params.split(',')) {
        final name = RegExp(
          r'([A-Za-z_][A-Za-z0-9_]*)\s*$',
        ).firstMatch(part.trim());
        if (name == null) {
          throw StateError('${file.path} 无法解析参数：$part');
        }
        names.add(name.group(1)!);
      }
    }

    yield _Message(
      name: match.group(1)!,
      params: params,
      parameterNames: names,
      owner: target,
    );
  }
}

/// 生成 `<outputRoot>/app_l10n.dart`：把全部 feature 的文案拍平到同一命名空间。
void _writeFacade(List<_Message> messages, String outputRoot) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// 生成入口：dart tool/gen_l10n.dart（--facade-only 可只重建本文件）。')
    ..writeln('//')
    ..writeln('// 为什么要有这一层：')
    ..writeln('//')
    ..writeln('// 每套 ARB / 生成类按 feature 拆分，源码维护清晰；但调用侧如果每处都写')
    ..writeln('// `OrderLocalizations.of(context).xxx`，类名前缀很长，还要额外 import。')
    ..writeln('// `AppL10n` 把全部 feature 文案拍平成一条命名空间，页面里只需')
    ..writeln('// `context.l10n.xxx`——key 全局唯一由脚本校验。')
    ..writeln('//')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln("import 'package:flutter/widgets.dart';")
    ..writeln();

  for (final target in targets) {
    buffer.writeln("import '${target.outputFile}';");
  }

  buffer
    ..writeln()
    ..writeln('/// 全应用文案的扁平门面。')
    ..writeln('///')
    ..writeln('/// 用法：`Text(context.l10n.appTitle)`。同一个 build 里多次取用')
    ..writeln('/// 时先取一次：`final l10n = context.l10n;`。')
    ..writeln('final class AppL10n {')
    ..writeln('  AppL10n(this._context);')
    ..writeln()
    ..writeln('  final BuildContext _context;')
    ..writeln()
    ..writeln('  static AppL10n of(BuildContext context) => AppL10n(context);')
    ..writeln();

  // 每个 feature 一个懒解析字段：第一次取到该 feature 的文案才调用
  // `Localizations.of`，避免构造门面时把 13 套全部查一遍。
  for (final target in targets) {
    buffer
      ..writeln('  ${target.className}? _${target.field};')
      ..writeln('  ${target.className} get _${target.field}L10n =>')
      ..writeln('      _${target.field} ??= ${target.className}.of(_context);')
      ..writeln();
  }

  for (final message in messages) {
    final owner = '_${message.owner.field}L10n';
    final params = message.params;
    if (params == null) {
      buffer.writeln('  String get ${message.name} => $owner.${message.name};');
    } else {
      final args = message.parameterNames.join(', ');
      buffer.writeln(
        '  String ${message.name}($params) => '
        '$owner.${message.name}($args);',
      );
    }
  }

  buffer
    ..writeln('}')
    ..writeln()
    ..writeln('/// `context.l10n` 入口。')
    ..writeln('extension AppL10nBuildContext on BuildContext {')
    ..writeln('  /// 当前语言的全部文案。')
    ..writeln('  AppL10n get l10n => AppL10n(this);')
    ..writeln('}');

  final facadePath = '$outputRoot/app_l10n.dart';
  File(facadePath).writeAsStringSync(buffer.toString());
  stdout.writeln('✓ $facadePath（${messages.length} 条文案）');
}

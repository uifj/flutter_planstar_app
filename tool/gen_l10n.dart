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
//   dart tool/gen_l10n.dart
//
// 失败条件（exit code 1）：
//   - 某套 ARB 生成失败；
//   - 某套 ARB 有未翻译的 key（缺 en 或 zh）。
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
    this.outputDir = 'lib/l10n',
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

  /// 生成 Dart 文件的目录（默认 lib/l10n，保持所有 l10n 产物集中）。
  final String outputDir;

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

/// 全部目标。新增 feature 时在这里加一行即可。
const List<L10nTarget> targets = <L10nTarget>[
  L10nTarget(
    label: 'app（跨 feature 共用）',
    arbDir: 'lib/l10n',
    template: 'app_zh.arb',
    outputFile: 'app_localizations.dart',
    className: 'AppLocalizations',
  ),
  L10nTarget(
    label: 'features/auth',
    arbDir: 'lib/l10n/features/auth',
    template: 'auth_zh.arb',
    outputFile: 'auth_localizations.dart',
    className: 'AuthLocalizations',
  ),
  L10nTarget(
    label: 'features/catalog',
    arbDir: 'lib/l10n/features/catalog',
    template: 'catalog_zh.arb',
    outputFile: 'catalog_localizations.dart',
    className: 'CatalogLocalizations',
  ),
  L10nTarget(
    label: 'features/discover',
    arbDir: 'lib/l10n/features/discover',
    template: 'discover_zh.arb',
    outputFile: 'discover_localizations.dart',
    className: 'DiscoverLocalizations',
  ),
  L10nTarget(
    label: 'features/goods',
    arbDir: 'lib/l10n/features/goods',
    template: 'goods_zh.arb',
    outputFile: 'goods_localizations.dart',
    className: 'GoodsLocalizations',
  ),
  L10nTarget(
    label: 'features/group_buy',
    arbDir: 'lib/l10n/features/group_buy',
    template: 'group_buy_zh.arb',
    outputFile: 'group_buy_localizations.dart',
    className: 'GroupBuyLocalizations',
  ),
  L10nTarget(
    label: 'features/home',
    arbDir: 'lib/l10n/features/home',
    template: 'home_zh.arb',
    outputFile: 'home_localizations.dart',
    className: 'HomeLocalizations',
  ),
  L10nTarget(
    label: 'features/marketing',
    arbDir: 'lib/l10n/features/marketing',
    template: 'marketing_zh.arb',
    outputFile: 'marketing_localizations.dart',
    className: 'MarketingLocalizations',
  ),
  L10nTarget(
    label: 'features/message',
    arbDir: 'lib/l10n/features/message',
    template: 'message_zh.arb',
    outputFile: 'message_localizations.dart',
    className: 'MessageLocalizations',
  ),
  L10nTarget(
    label: 'features/order',
    arbDir: 'lib/l10n/features/order',
    template: 'order_zh.arb',
    outputFile: 'order_localizations.dart',
    className: 'OrderLocalizations',
  ),
  L10nTarget(
    label: 'features/proxy_buy',
    arbDir: 'lib/l10n/features/proxy_buy',
    template: 'proxy_buy_zh.arb',
    outputFile: 'proxy_buy_localizations.dart',
    className: 'ProxyBuyLocalizations',
  ),
  L10nTarget(
    label: 'features/search',
    arbDir: 'lib/l10n/features/search',
    template: 'search_zh.arb',
    outputFile: 'search_localizations.dart',
    className: 'SearchLocalizations',
  ),
  L10nTarget(
    label: 'features/user',
    arbDir: 'lib/l10n/features/user',
    template: 'user_zh.arb',
    outputFile: 'user_localizations.dart',
    className: 'UserLocalizations',
  ),
];

const String _l10nYaml = 'l10n.yaml';
const String _l10nYamlBackup = 'l10n.yaml.gen-bak';
const String _untranslatedDir = 'build/untranslated';

Future<void> main(List<String> args) async {
  // `--facade-only` 只重建 lib/l10n/app_l10n.dart：改注释/门面逻辑时不必等
  // 13 套 gen-l10n 全部重跑。
  final bool facadeOnly = args.contains('--facade-only');
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
            '--output-dir=${target.outputDir}',
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
    _writeFacade(_collectMessages());
  } on StateError catch (error) {
    stderr.writeln('✗ 构建 AppL10n 门面失败：${error.message}');
    exit(1);
  }

  stdout.writeln('\n✓ ${targets.length} 套 l10n 全部生成完成，无未翻译 key');
}

/// 从各生成类里收集全部文案成员，并保证 key 全局唯一。
List<_Message> _collectMessages() {
  final Map<String, _Message> byKey = <String, _Message>{};
  for (final target in targets) {
    final file = File('${target.outputDir}/${target.outputFile}');
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

/// 生成 `lib/l10n/app_l10n.dart`：把全部 feature 的文案拍平到同一命名空间。
void _writeFacade(List<_Message> messages) {
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

  File('lib/l10n/app_l10n.dart').writeAsStringSync(buffer.toString());
  stdout.writeln('✓ lib/l10n/app_l10n.dart（${messages.length} 条文案）');

  // 同一个脚本再写 barrel：新增 feature 时只改 `targets`，不用再手工补 import。
  final barrel = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// 生成入口：dart tool/gen_l10n.dart。')
    ..writeln('//')
    ..writeln('/// 应用 l10n 的唯一 import 入口。')
    ..writeln('///')
    ..writeln('/// 页面里只需：')
    ..writeln('///')
    ..writeln('/// ```dart')
    ..writeln("/// import '../../l10n/l10n.dart';")
    ..writeln('///')
    ..writeln('/// Text(context.l10n.appTitle);')
    ..writeln('/// ```')
    ..writeln('///')
    ..writeln('/// - `context.l10n` 由 [AppL10nBuildContext] 提供，返回扁平门面')
    ..writeln('///   [AppL10n]，不需要再写 `OrderLocalizations.of(context)` 这类长前缀；')
    ..writeln('/// - [AppL10n] 按 feature 的生成类懒取文案，key 全局唯一由脚本校验；')
    ..writeln('/// - 同时 re-export 各生成类，`AppLocalizations.delegate` /')
    ..writeln('///   `supportedLocales` 等静态成员照常可用。')
    ..writeln('library;')
    ..writeln()
    ..writeln("export 'app_l10n.dart';");

  for (final target in targets) {
    barrel.writeln("export '${target.outputFile}';");
  }

  File('lib/l10n/l10n.dart').writeAsStringSync(barrel.toString());
  stdout.writeln('✓ lib/l10n/l10n.dart（${targets.length} 个生成类）');
}

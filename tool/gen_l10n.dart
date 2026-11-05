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
    arbDir: 'lib/features/auth/l10n',
    template: 'auth_zh.arb',
    outputFile: 'auth_localizations.dart',
    className: 'AuthLocalizations',
  ),
  L10nTarget(
    label: 'features/discover',
    arbDir: 'lib/features/discover/l10n',
    template: 'discover_zh.arb',
    outputFile: 'discover_localizations.dart',
    className: 'DiscoverLocalizations',
  ),
  L10nTarget(
    label: 'features/goods',
    arbDir: 'lib/features/goods/l10n',
    template: 'goods_zh.arb',
    outputFile: 'goods_localizations.dart',
    className: 'GoodsLocalizations',
  ),
  L10nTarget(
    label: 'features/home',
    arbDir: 'lib/features/home/l10n',
    template: 'home_zh.arb',
    outputFile: 'home_localizations.dart',
    className: 'HomeLocalizations',
  ),
  L10nTarget(
    label: 'features/message',
    arbDir: 'lib/features/message/l10n',
    template: 'message_zh.arb',
    outputFile: 'message_localizations.dart',
    className: 'MessageLocalizations',
  ),
  L10nTarget(
    label: 'features/order',
    arbDir: 'lib/features/order/l10n',
    template: 'order_zh.arb',
    outputFile: 'order_localizations.dart',
    className: 'OrderLocalizations',
  ),
  L10nTarget(
    label: 'features/user',
    arbDir: 'lib/features/user/l10n',
    template: 'user_zh.arb',
    outputFile: 'user_localizations.dart',
    className: 'UserLocalizations',
  ),
];

const String _l10nYaml = 'l10n.yaml';
const String _l10nYamlBackup = 'l10n.yaml.gen-bak';
const String _untranslatedDir = 'build/untranslated';

Future<void> main(List<String> args) async {
  final l10nYaml = File(_l10nYaml);
  if (!l10nYaml.existsSync()) {
    stderr.writeln('✗ 找不到 $l10nYaml（应在工程根运行本脚本）');
    exit(1);
  }

  // 先把 l10n.yaml 挪开：否则 gen-l10n 会忽略我们传的命令行参数。
  final backup = l10nYaml.renameSync(_l10nYamlBackup);
  var failed = 0;
  final problems = <String>[];

  try {
    Directory(_untranslatedDir).createSync(recursive: true);

    for (final target in targets) {
      stdout.writeln('→ ${target.label}  (${target.arbDir})');
      final untranslatedPath =
          '$_untranslatedDir/${target.className}.json';

      final result = await Process.run(
        Platform.isWindows ? 'flutter.bat' : 'flutter',
        <String>[
          'gen-l10n',
          '--arb-dir=${target.arbDir}',
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
        problems.add('${target.label} 生成失败：\n${result.stderr}${result.stdout}');
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

  if (failed > 0) {
    stderr.writeln('\n✗ $failed 个目标有问题：');
    for (final problem in problems) {
      stderr.writeln('  - $problem');
    }
    exit(1);
  }
  stdout.writeln('\n✓ ${targets.length} 套 l10n 全部生成完成，无未翻译 key');
}

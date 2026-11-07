import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 架构约束：`useDemoProvider` 只允许在 `lib/app/network` 内部出现。
///
/// 业务层统一读 `dataSourcePolicyProvider`（见 `data_source_policy.dart`），
/// 避免每加一个数据源又散落一处 demo 判断。
void main() {
  test('lib/app/network 之外不得引用 useDemoProvider', () {
    final Directory projectRoot = Directory.current;
    final String rootPath = projectRoot.absolute.path.replaceAll('\\', '/');
    final Directory libDir = Directory('$rootPath/lib');
    expect(
      libDir.existsSync(),
      isTrue,
      reason: '测试需要在项目根目录运行，找不到 ${libDir.path}',
    );

    const String forbidden = 'useDemoProvider';
    final List<String> violations = <String>[];

    final Iterable<File> dartFiles = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'));

    for (final File file in dartFiles) {
      final String relative = file.absolute.path
          .replaceAll('\\', '/')
          .substring(rootPath.length + 1);
      if (relative.startsWith('lib/app/network/')) continue;

      final List<String> lines = file.readAsLinesSync();
      for (var index = 0; index < lines.length; index++) {
        if (lines[index].contains(forbidden)) {
          violations.add('$relative:${index + 1}: ${lines[index].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          '以下文件直接引用了 `$forbidden`，请改用 `dataSourcePolicyProvider`：\n'
          '${violations.join('\n')}',
    );
  });
}

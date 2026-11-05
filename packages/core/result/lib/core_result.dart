/// 领域原语：`Failure` / `FailureType` / `Result<T>`。
///
/// 设计来源：`planstar/packages/infras/stone_core/lib/network/result.dart`
/// （见 `wiki_zh/30-flutter-adoptable-designs.md` §2.1）。
///
/// 相对来源的三处**刻意改动**：
/// 1. `Result` 改为 `sealed`，`switch` 可穷举——来源用 `isSuccess` 布尔判断，
///    新增子类时调用点不会报错（30-06）。
/// 2. `Failure` 补 `copyWith`（重试时换 message 不必新建对象）与 `isRetryable`。
/// 3. `Failure` **不** `implements Exception`——它是返回值，不是可抛对象。
///    这条是契约的一部分：网络层永不抛，调用方不必 try/catch。
library;

export 'src/failure.dart';
export 'src/result.dart';

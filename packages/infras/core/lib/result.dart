/// 领域原语：`Failure` / `FailureType` / `Result<T>`。
///
/// `Result` 是 `sealed`，`switch` 可穷举；`Failure` **不** `implements Exception`
/// ——它是返回值，不是可抛对象。这条是契约的一部分：网络层永不抛，调用方
/// 不必 try/catch。
library;

export 'src/result/failure.dart';
export 'src/result/result.dart';

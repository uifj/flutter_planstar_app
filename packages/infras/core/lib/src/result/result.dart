/// `Result<T>`：要么成功值、要么 [Failure]。
///
/// **sealed** 是关键设计——调用点可以这样写，且新增子类时编译器会报错：
///
/// ```dart
/// switch (result) {
///   case Success(:final data): render(data);
///   case Fail(:final failure): showError(failure.message);
/// }
/// ```
library;

import 'failure.dart';

/// 一次操作的结果。
sealed class Result<T> {
  const Result();

  /// 成功。等价于 `Success<T>(data)`。
  const factory Result.success(T data) = Success<T>;

  /// 失败。等价于 `Fail<T>(failure)`。
  const factory Result.failure(Failure failure) = Fail<T>;

  /// 是否成功。
  bool get isSuccess => this is Success<T>;

  /// 是否失败。
  bool get isFailure => this is Fail<T>;

  /// 失败描述；成功时为 `null`。
  Failure? get failure => switch (this) {
        Success<T>() => null,
        Fail<T>(:final failure) => failure,
      };

  /// 成功值。失败态访问会抛 [StateError]——请先用 `switch` 或 [fold]。
  T get requireData => switch (this) {
        Success<T>(:final data) => data,
        Fail<T>(:final failure) =>
          throw StateError('Result 是失败态，不能取 data：$failure'),
      };

  /// 二分折叠。
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Fail<T>(:final failure) => onFailure(failure),
      };

  /// 映射成功值；失败原样透传。
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(:final data) => Success<R>(transform(data)),
        Fail<T>(:final failure) => Fail<R>(failure),
      };

  /// 链式映射（`transform` 自己返回 [Result]，用于串联可能失败的一步）。
  Result<R> flatMap<R>(Result<R> Function(T data) transform) =>
      switch (this) {
        Success<T>(:final data) => transform(data),
        Fail<T>(:final failure) => Fail<R>(failure),
      };

  /// 取成功值，失败时用 [fallback] 兜底。
  T getOrElse(T Function(Failure failure) fallback) => switch (this) {
        Success<T>(:final data) => data,
        Fail<T>(:final failure) => fallback(failure),
      };

  /// 成功时执行副作用并原样返回（用于埋点/日志，不改变结果）。
  Result<T> tap(void Function(T data) effect) {
    if (this case Success<T>(:final data)) {
      effect(data);
    }
    return this;
  }

  /// 把可能抛异常的同步块收敛成 [Result]。
  ///
  /// 只用于**边界**（解析第三方回调、调用老代码）。业务内部不要用它兜住
  /// 自己的逻辑错误——那会把 bug 变成静默失败。
  static Result<T> guard<T>(T Function() body) {
    try {
      return Success<T>(body());
    } catch (error) {
      return Fail<T>(
        Failure(
          code: 'UNEXPECTED',
          message: error.toString(),
          type: FailureType.data,
          cause: error,
        ),
      );
    }
  }
}

/// 成功分支。
final class Success<T> extends Result<T> {
  const Success(this.data);

  /// 成功值。
  final T data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.data == data);

  @override
  int get hashCode => Object.hash(Success<T>, data);

  @override
  String toString() => 'Success($data)';
}

/// 失败分支。
final class Fail<T> extends Result<T> {
  const Fail(this.failure);

  /// 失败描述。
  @override
  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Fail<T> && other.failure == failure);

  @override
  int get hashCode => Object.hash(Fail<T>, failure);

  @override
  String toString() => 'Fail($failure)';
}

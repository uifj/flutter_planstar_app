import 'package:core/result.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    test('命名构造锁死不该有的字段', () {
      const network = Failure.network(message: '断网');
      expect(network.type, FailureType.network);
      expect(network.statusCode, isNull);
      expect(network.requestId, isNull);

      const unauthorized = Failure.unauthorized(message: '登录失效');
      expect(unauthorized.statusCode, 401);
      expect(unauthorized.cause, isNull);
    });

    test('isRetryable 只认超时与网络中断', () {
      expect(Failure.timeout(message: '').isRetryable, isTrue);
      expect(Failure.network(message: '').isRetryable, isTrue);
      // 5xx 不重试：可能重复下单
      expect(Failure.server(message: '', statusCode: 503).isRetryable, isFalse);
      expect(Failure.input(message: '').isRetryable, isFalse);
    });

    test('isAuthFailure 覆盖 401 与 authentication 类型', () {
      expect(Failure.unauthorized(message: '').isAuthFailure, isTrue);
      expect(
        const Failure(
          code: 'FORBIDDEN',
          message: '',
          type: FailureType.authentication,
          statusCode: 403,
        ).isAuthFailure,
        isTrue,
      );
      expect(Failure.server(message: '').isAuthFailure, isFalse);
    });

    test('copyWith 只替换传入字段', () {
      const origin = Failure.server(message: '原始', code: 'E1', statusCode: 500);
      final next = origin.copyWith(message: '重试后', statusCode: 502);
      expect(next.message, '重试后');
      expect(next.statusCode, 502);
      expect(next.code, 'E1');
      expect(next.type, FailureType.server);
    });

    test('Failure 不是 Exception——契约上不可抛', () {
      expect(const Failure.input(message: ''), isNot(isA<Exception>()));
    });
  });

  group('Result', () {
    test('fold 走对分支', () {
      const ok = Result<int>.success(2);
      const bad = Result<int>.failure(Failure.timeout(message: '超时'));

      expect(ok.fold(onFailure: (_) => -1, onSuccess: (d) => d * 10), 20);
      expect(bad.fold(onFailure: (f) => f.type.name, onSuccess: (_) => 'ok'),
          'timeout');
    });

    test('sealed 可穷举 switch，不需要 default', () {
      String describe(Result<int> r) => switch (r) {
            Success(:final data) => 'ok:$data',
            Fail(:final failure) => 'fail:${failure.code}',
          };

      expect(describe(const Result.success(1)), 'ok:1');
      expect(
        describe(const Result.failure(Failure.input(message: '', code: 'X'))),
        'fail:X',
      );
    });

    test('requireData 在失败态抛 StateError', () {
      const bad = Result<int>.failure(Failure.input(message: ''));
      expect(() => bad.requireData, throwsStateError);
    });

    test('map / flatMap 失败透传，不执行 transform', () {
      var called = false;
      const bad = Result<int>.failure(Failure.network(message: ''));

      final mapped = bad.map((d) {
        called = true;
        return d + 1;
      });
      expect(called, isFalse);
      expect(mapped.isFailure, isTrue);

      final chained = bad.flatMap((d) => const Result<String>.success('x'));
      expect(chained.isFailure, isTrue);
    });

    test('flatMap 串联两步都可能失败的流程', () {
      Result<int> parse(String s) {
        final v = int.tryParse(s);
        return v == null
            ? const Result.failure(Failure.input(message: '不是数字'))
            : Result.success(v);
      }

      Result<int> half(int v) => v.isEven
          ? Result.success(v ~/ 2)
          : const Result.failure(Failure.input(message: '奇数'));

      expect(parse('8').flatMap(half).requireData, 4);
      expect(parse('8').flatMap(half).isSuccess, isTrue);
      expect(parse('7').flatMap(half).failure!.message, '奇数');
      expect(parse('x').flatMap(half).failure!.message, '不是数字');
    });

    test('getOrElse / tap', () {
      const ok = Result<int>.success(5);
      const bad = Result<int>.failure(Failure.input(message: ''));

      expect(ok.getOrElse((_) => 0), 5);
      expect(bad.getOrElse((f) => -1), -1);

      var seen = 0;
      expect(ok.tap((d) => seen = d), ok);
      expect(seen, 5);
      bad.tap((_) => seen = -99);
      expect(seen, 5);
    });

    test('guard 收敛异常', () {
      expect(Result.guard(() => 1 + 1).requireData, 2);
      final failed = Result.guard<int>(() => throw StateError('boom'));
      expect(failed.isFailure, isTrue);
      expect(failed.failure!.code, 'UNEXPECTED');
      expect(failed.failure!.type, FailureType.data);
    });

    test('值相等（便于测试断言）', () {
      expect(const Result.success(1), const Result.success(1));
      expect(const Result.success(1), isNot(const Result.success(2)));
    });
  });
}

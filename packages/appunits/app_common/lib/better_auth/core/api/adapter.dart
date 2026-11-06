import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../better_auth_logger.dart';
import 'models/result/better_error.dart';
import 'models/result/result.dart';

class BetterAuthCallAdapter<T>
    extends CallAdapter<Future<HttpResponse<T>>, Future<Result<T>>> {
  @override
  Future<Result<T>> adapt(Future<HttpResponse<T>> Function() call) async {
    try {
      final httpResponse = await call();
      final data = httpResponse.data;
      return Result<T>.ok(data);
    } on DioException catch (e, s) {
      final res = e.response;
      final status = res?.statusCode;
      final body = res?.data;
      betterAuthLogger.info('Dio response headers: ${res?.headers}');
      betterAuthLogger.error(
        'DioException: $e',
        error: e,
        stackTrace: s,
      );
      betterAuthLogger.error('Status: $status, Body: $body');
      return Result.err(
        BetterError(
          code: res?.data?['code'] ?? "ERROR",
          message: res?.data?['message'] ?? e.message,
          stack: s.toString(),
        ),
      );
    } catch (e, s) {
      betterAuthLogger.error('Unknown Error: $e', error: e, stackTrace: s);
      return Result.err(
        BetterError(message: e.toString(), stack: s.toString()),
      );
    }
  }
}

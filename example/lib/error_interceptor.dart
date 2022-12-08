import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      final status = err.response!.data['status'] as int?;
      if (status == 404) {
        /// This line can cause ignore the next error step
        /// The swagger_interceptor can't record error if [SwaggerInterceptor] is behinde [ErrorInterceptor]
        throw UnsupportedError('Not found');
      }
    }
    super.onError(err, handler);
  }
}

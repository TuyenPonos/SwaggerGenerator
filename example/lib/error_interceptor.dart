import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final Map<String, dynamic> resp = response.data;
    final status = resp['status'] as int?;
    if (status != null && status != 0) {
      // Reject response if request success but status return an error
      return handler.reject(
        DioError(response: response, requestOptions: response.requestOptions),
        true,
      );
    }
    super.onResponse(response, handler);
  }

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

import 'package:dio/dio.dart';

import 'generator_controller.dart';

class SwaggerInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    SwaggerGenerator.instance.updateError(err);
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    SwaggerGenerator.instance.updateResponse(response);
    super.onResponse(response, handler);
  }
}

import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final Map<String, String> headers = Map.from(options.headers);
    headers['Authorization'] = 'Bearer access_token';
    super.onRequest(options, handler);
  }
}

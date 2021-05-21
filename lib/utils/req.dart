import 'package:dio/dio.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/utils/store.dart';

class _CookieInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String token = await Store.getString(LOGIN_TOKEN);
    print(options.uri);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }
}

Dio req() {
  BaseOptions options = BaseOptions(
    baseUrl: DEF_BASE_URL,
    connectTimeout: 8000,
    receiveTimeout: 4000,
  );
  Dio dio = Dio(options);
  dio.interceptors.add(_CookieInterceptors());
  return dio;
}

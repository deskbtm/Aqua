import 'package:dio/dio.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/utils/store.dart';

class _CookieInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    String token = await Store.getString(LOGIN_TOKEN);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options);
  }
}

Dio req() {
  Dio dio = Dio();
  dio.options.connectTimeout = 8000;
  dio.options.receiveTimeout = 4000;
  dio.interceptors.add(_CookieInterceptors());
  return dio;
}

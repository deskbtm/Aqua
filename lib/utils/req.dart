import 'package:dio/dio.dart';
import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/utils/store.dart';

class _CookieInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    String token = await Store.getString(LOGIN_TOKEN);
    print(options.uri);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options);
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

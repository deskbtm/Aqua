import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/external/webdav/src/client.dart';
import 'package:aqua/utils/store.dart';

class WebDavUtils {
  Client client;
  final _secureStorage = FlutterSecureStorage();

  Future<WebDavUtils> init() async {
    String addr = await Store.getString(WEBDAV_ADDR);
    String username = await Store.getString(WEBDAV_USERNAME);
    String pwd = await _secureStorage.read(key: WEBDAV_PWD);
    client = Client(addr, username, pwd);
    return this;
  }
}

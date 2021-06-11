import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/external/webdav/src/client.dart';
import 'package:aqua/utils/store.dart';
import 'package:path/path.dart' as pathLib;

class WebDavUtils {
  late Client? client;
  static final _secureStorage = FlutterSecureStorage();

  Future<WebDavUtils> getClient() async {
    String? addr = await Store.getString(WEBDAV_ADDR);
    String? username = await Store.getString(WEBDAV_USERNAME);
    String? pwd = await _secureStorage.read(key: WEBDAV_PWD);
    if (addr != null && username != null && pwd != null) {
      client = Client(addr, username, pwd);
    }
    return this;
  }

  Future<void> uploadToWebDAV(SelfFileEntity file) async {
    Client? client = (await getClient()).client;
    String path = file.entity.path;
    if (client != null) {
      await client.mkdir('/aqua');
      await Future.delayed(Duration(milliseconds: 500));
      await client.uploadFile(path, '/aqua/${pathLib.basename(path)}');
    } else {
      throw new Exception('webdav client got null');
    }
  }
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lan_file_more/constant/constant.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/store.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CommonModel extends ChangeNotifier {
  final secureStorage = FlutterSecureStorage();

  String _storageRootPath = '';
  String get storageRootPath => _storageRootPath;

  Future<void> setStorageRootPath(String path) async {
    _storageRootPath = path;
    notifyListeners();
  }

  String _staticUploadSavePath;
  String get staticUploadSavePath => _staticUploadSavePath;

  Future<void> setStaticUploadSavePath(String arg) async {
    _staticUploadSavePath = arg;
    await Store.setString(STATIC_UPLOAD_SAVEPATH, arg);
    notifyListeners();
  }

  String _filePort;
  String get filePort => _filePort;

  Future<void> setFilePort(String arg) async {
    _filePort = arg;
    await Store.setString(FILE_PORT, arg);
    notifyListeners();
  }

  // 购买
  bool _isPurchased;
  bool get isPurchased => _isPurchased;

  Future<void> setPurchase(bool arg) async {
    _isPurchased = arg;
    await secureStorage.write(key: PURCHASED, value: arg.toString());
    notifyListeners();
  }

  // app 初始化
  bool _isAppInit = true;
  bool get isAppInit => _isAppInit;

  Future<void> setAppInit(bool arg) async {
    _isAppInit = arg;
    await Store.setBool(APP_INIT, arg);
  }

  bool _enableClipboard = true;
  bool get enableClipboard => _enableClipboard;

  Future<void> setEnableClipboard(bool arg) async {
    _enableClipboard = arg;
    await Store.setBool(ENABLE_CLIPBOARD, arg);
    notifyListeners();
  }

  List<SelfFileEntity> _selectedFiles = [];
  List<SelfFileEntity> get selectedFiles => _selectedFiles;

  Future<void> addSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    if (!_selectedFiles.any((ele) => ele.entity.path == value.entity.path))
      _selectedFiles.add(value);
    if (update) notifyListeners();
  }

  Future<void> removeSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    _selectedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool hasSelectedFile(String path) {
    return _selectedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearSelectedFiles({bool update = false}) async {
    _selectedFiles = [];
    if (update) notifyListeners();
  }

  String _baseUrl;
  String get baseUrl => _baseUrl;

  Future<void> setBaseUrl(String arg) async {
    _baseUrl = arg;
    await Store.setString(BASE_URL_KEY, _baseUrl);
  }

  String _internalIp;
  String get internalIp => _internalIp;

  Future<void> setInternalIp(String arg) async {
    _internalIp = arg;
    notifyListeners();
  }

  String _currentConnectIp;
  String get currentConnectIp => _currentConnectIp;

  Future<void> setCurrentConnectIp(String arg, {notify = true}) async {
    _currentConnectIp = arg;
    if (notify) notifyListeners();
  }

  IO.Socket _socket;
  IO.Socket get socket => _socket;

  Future<void> setSocket(IO.Socket arg) async {
    _socket = arg;
    notifyListeners();
  }

  //  内网快递自动连接
  bool _autoConnectExpress;
  bool get autoConnectExpress => _autoConnectExpress;

  Future<void> setAutoConnectExpress(bool arg) async {
    _autoConnectExpress = arg;
    await Store.setBool(AUTO_CONNECT_EXPRESS, arg);
    notifyListeners();
  }

  /// 开启 与PC连接
  bool _enableConnect = true;
  bool get enableConnect => _enableConnect;

  Future<void> setEnableConnect(bool arg) async {
    _enableConnect = arg;
    await Store.setBool(ENABLE_CONNECT, arg);
    notifyListeners();
  }

  bool _enableAutoConnectCommonIp;
  bool get enableAutoConnectCommonIp => _enableAutoConnectCommonIp;

  Future<void> setEnableAutoConnectCommonIp(bool arg) async {
    await Store.setBool(AUTO_CONNECT_COMMON_IP, arg);

    _enableAutoConnectCommonIp = arg;
    notifyListeners();
  }

  // 常用IP
  Map _commonIps = Map();
  Map get commonIps => _commonIps;

  Future<void> addToCommonIps(String ip) async {
    var count = _commonIps[ip];
    if (count != null) {
      _commonIps[ip] = count + 1;
    } else {
      _commonIps[ip] = 1;
    }
    await Store.setString(COMMON_IPS, json.encode(_commonIps));
    notifyListeners();
  }

  Future<void> removeFromCommonIps(String ip) async {
    _commonIps.remove(ip);
    await Store.setString(COMMON_IPS, json.encode(_commonIps));
    notifyListeners();
  }

  String getMostCommonIp() {
    List<MapEntry<dynamic, dynamic>> al = _commonIps.entries.toList();
    int max = 0;
    String ip;
    for (var i = 0; i < al.length; i++) {
      if (al[i].value > max) {
        max = al[i].value;
        ip = al[i].key;
      }
    }
    return ip;
  }

  /// vscode 服务密码
  String _codeSrvPwd;
  String get codeSrvPwd => _codeSrvPwd;

  Future<void> setCodeSrvPwd(String arg) async {
    _codeSrvPwd = arg;
    if (arg == null) {
      await secureStorage.delete(key: CODE_SERVER_PWD);
    } else {
      await secureStorage.write(key: CODE_SERVER_PWD, value: arg);
    }
    // notifyListeners();
  }

  String _codeSrvPort;
  String get codeSrvPort => _codeSrvPort;

  Future<void> setCodeSrvPort(String arg) async {
    _codeSrvPort = arg;
    await Store.setString(CODE_SERVER_PORT, arg);
    notifyListeners();
  }

  bool _codeSrvTelemetry;
  bool get codeSrvTelemetry => _codeSrvTelemetry;

  Future<void> setCodeSrvTelemetry(bool arg) async {
    _codeSrvTelemetry = arg;
    await Store.setBool(CODE_SERVER_TELEMETRY, arg);
    notifyListeners();
  }

  String _linuxRepo;
  String get linuxRepo => _linuxRepo;

  Future<void> setLinuxRepo(String arg) async {
    _linuxRepo = arg;
    await Store.setString(LINUX_REPO, arg);
    notifyListeners();
  }

  ///WEBDAV
  String _webDavAddr;
  String get webDavAddr => _webDavAddr;

  Future<void> setWebDavAddr(String arg) async {
    _webDavAddr = arg;
    await Store.setString(WEBDAV_ADDR, arg);
    // notifyListeners();
  }

  String _webDavUsername;
  String get webDavUsername => _webDavUsername;

  Future<void> setWebDavUsername(String arg) async {
    _webDavUsername = arg;
    await Store.setString(WEBDAV_USERNAME, arg);
    // notifyListeners();
  }

  String _webDavPwd;
  String get webDavPwd => _webDavPwd;

  Future<void> setWebDavPwd(String arg) async {
    _webDavPwd = arg;
    await secureStorage.write(key: WEBDAV_PWD, value: arg);
    // notifyListeners();
  }

  Map _gWebData = {};
  Map get gWebData => _gWebData;

  Future<void> setGobalWebData(Map arg) async {
    _gWebData = arg;
    // notifyListeners();
  }

  String _username;
  String get username => _username;

  Future<void> setUsernameGlobal(String arg) async {
    _username = arg;
    await Store.setString(LOGIN_USERNMAE, arg);
    notifyListeners();
  }

  Future<void> logout() async {
    _username = null;
    _isPurchased = false;
    await Store.del(LOGIN_USERNMAE);
    await Store.del(LOGIN_TOKEN);
    await secureStorage.delete(key: PURCHASED);
    notifyListeners();
  }

  Future<void> initCommon() async {
    _filePort = (await Store.getString(FILE_PORT)) ?? '20201';

    _codeSrvPort = await Store.getString(CODE_SERVER_PORT) ?? '20202';
    _codeSrvPwd = await secureStorage.read(key: CODE_SERVER_PWD);
    _linuxRepo = (await Store.getString(LINUX_REPO)) ?? TSINGHUA_REPO;

    _codeSrvTelemetry = await Store.getBool(CODE_SERVER_TELEMETRY) ?? false;

    _webDavAddr = await Store.getString(WEBDAV_ADDR);
    _webDavUsername = await Store.getString(WEBDAV_USERNAME);
    _webDavPwd = await secureStorage.read(key: WEBDAV_PWD);
    _enableClipboard = (await Store.getBool(ENABLE_CLIPBOARD)) ?? true;
    _isPurchased = (await secureStorage.read(key: PURCHASED)) == 'true';
    _isAppInit = (await Store.getBool(APP_INIT)) ?? true;
    _baseUrl = (await Store.getString(BASE_URL_KEY)) ?? DEF_BASE_URL;
    _username = await Store.getString(LOGIN_USERNMAE);
    _autoConnectExpress = (await Store.getBool(AUTO_CONNECT_EXPRESS)) ?? true;
    _enableConnect = (await Store.getBool(ENABLE_CONNECT)) ?? true;

    String tmpCommonIps = await Store.getString(COMMON_IPS);
    _commonIps = tmpCommonIps == null ? Map() : json.decode(tmpCommonIps);

    _enableAutoConnectCommonIp =
        (await Store.getBool(AUTO_CONNECT_COMMON_IP)) ?? true;
    _storageRootPath = await MixUtils.getExternalRootPath();
    _staticUploadSavePath = (await Store.getString(STATIC_UPLOAD_SAVEPATH)) ??
        await MixUtils.getPrimaryStaticUploadSavePath(_storageRootPath);
  }
}

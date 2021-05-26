import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/store.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CommonModel extends ChangeNotifier {
  final secureStorage = FlutterSecureStorage();
  final context;

  late String _language;

  CommonModel(this.context);
  String get language => _language;

  Future<void> setLanguage(String val) async {
    _language = val;
    await Store.setString(LANGUAGE, val);
    notifyListeners();
  }

  /// 进入app的方式 正常打开'normal'
  /// 从其他APP打开方式'incoming'
  late Map _appIncoming;
  Map? get appIncoming => _appIncoming;

  Future<void> setAppIncoming(Map data) async {
    _appIncoming = data;
  }

  late bool _canPopToDesktop = true;
  bool get canPopToDesktop => _canPopToDesktop;

  void setCanPopToDesktop(bool val) {
    _canPopToDesktop = val;
  }

  ///[f]
  late String _storageRootPath = '';
  String get storageRootPath => _storageRootPath;

  Future<void> setStorageRootPath(String path) async {
    _storageRootPath = path;
    notifyListeners();
  }

  late String _staticUploadSavePath;
  String get staticUploadSavePath => _staticUploadSavePath;

  Future<void> setStaticUploadSavePath(String arg) async {
    _staticUploadSavePath = arg;
    await Store.setString(STATIC_UPLOAD_SAVEPATH, arg);
    notifyListeners();
  }

  late String _sysDownloadPath;
  String? get sysDownloadPath => _sysDownloadPath;

  Future<void> setSysDownloadPath(String arg) async {
    _sysDownloadPath = arg;
  }

  late String _filePort;
  String? get filePort => _filePort;

  Future<void> setFilePort(String arg) async {
    _filePort = arg;
    await Store.setString(FILE_PORT, arg);
    notifyListeners();
  }

  // 购买
  late bool _isPurchased = false;
  bool get isPurchased => _isPurchased;

  Future<void> setPurchase(bool arg) async {
    _isPurchased = arg;
    await secureStorage.write(key: PURCHASED, value: arg.toString());
    notifyListeners();
  }

  // app 初始化
  late bool _isAppNotInit = true;
  bool get isAppNotInit => _isAppNotInit;

  Future<void> setAppInit(bool arg) async {
    _isAppNotInit = arg;
    await Store.setBool(APP_INIT, arg);
  }

  // 菜单初始化
  late bool _isFileOptionPromptNotInit = true;
  bool get isFileOptionPromptNotInit => _isFileOptionPromptNotInit;

  Future<void> setFileOptionPromptInit(bool arg) async {
    _isFileOptionPromptNotInit = arg;
    await Store.setBool(FILE_OPTION_INIT, arg);
  }

  late bool _enableClipboard = true;
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
    if (!_selectedFiles.any((ele) => ele.entity.path == value.entity.path)) {
      _selectedFiles.add(value);
    }
    if (update) notifyListeners();
  }

  Future<void> removeSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    _selectedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool? hasSelectedFile(String path) {
    return _selectedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearSelectedFiles({bool update = false}) async {
    _selectedFiles = [];
    if (update) notifyListeners();
  }

  List<SelfFileEntity> _pickFiles = [];
  List<SelfFileEntity> get pickedFiles => _pickFiles;

  Future<void> addPickedFile(SelfFileEntity value,
      {bool update = false}) async {
    if (!_pickFiles.any((ele) => ele.entity.path == value.entity.path))
      _pickFiles.add(value);
    if (update) notifyListeners();
  }

  Future<void> removePickedFile(SelfFileEntity value,
      {bool update = false}) async {
    _pickFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool? hasPickFile(String path) {
    return _pickFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearPickedFiles({bool update = false}) async {
    _pickFiles = [];
    if (update) notifyListeners();
  }

  late String _internalIp;
  String? get internalIp => _internalIp;

  Future<void> setInternalIp(String arg) async {
    _internalIp = arg;
    notifyListeners();
  }

  late String _currentConnectIp;
  String? get currentConnectIp => _currentConnectIp;

  Future<void> setCurrentConnectIp(String arg, {notify = true}) async {
    _currentConnectIp = arg;
    if (notify) notifyListeners();
  }

  //  内网快递自动连接
  late bool _autoConnectExpress;
  bool? get autoConnectExpress => _autoConnectExpress;

  Future<void> setAutoConnectExpress(bool arg) async {
    _autoConnectExpress = arg;
    await Store.setBool(AUTO_CONNECT_EXPRESS, arg);
    notifyListeners();
  }

  /// 开启 与PC连接
  late bool _enableConnect = true;
  bool? get enableConnect => _enableConnect;

  Future<void> setEnableConnect(bool arg) async {
    _enableConnect = arg;
    await Store.setBool(ENABLE_CONNECT, arg);
    notifyListeners();
  }

  late bool _enableAutoConnectCommonIp;
  bool? get enableAutoConnectCommonIp => _enableAutoConnectCommonIp;

  Future<void> setEnableAutoConnectCommonIp(bool arg) async {
    await Store.setBool(AUTO_CONNECT_COMMON_IP, arg);

    _enableAutoConnectCommonIp = arg;
    notifyListeners();
  }

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

  String? getMostCommonIp() {
    List<MapEntry<dynamic, dynamic>> al = _commonIps.entries.toList();
    int max = 0;
    String? ip;
    for (var i = 0; i < al.length; i++) {
      if (al[i].value > max) {
        max = al[i].value;
        ip = al[i].key;
      }
    }
    return ip;
  }

  /// vscode 服务密码
  String? _codeSrvPwd;
  String? get codeSrvPwd => _codeSrvPwd;

  Future<void> setCodeSrvPwd(String? arg) async {
    _codeSrvPwd = arg;
    if (arg == null) {
      await secureStorage.delete(key: CODE_SERVER_PWD);
    } else {
      await secureStorage.write(key: CODE_SERVER_PWD, value: arg);
    }
  }

  late String _codeSrvPort;
  String? get codeSrvPort => _codeSrvPort;

  Future<void> setCodeSrvPort(String arg) async {
    _codeSrvPort = arg;
    await Store.setString(CODE_SERVER_PORT, arg);
    notifyListeners();
  }

  late bool _codeSrvTelemetry;
  bool? get codeSrvTelemetry => _codeSrvTelemetry;

  Future<void> setCodeSrvTelemetry(bool arg) async {
    _codeSrvTelemetry = arg;
    await Store.setBool(CODE_SERVER_TELEMETRY, arg);
    notifyListeners();
  }

  late String _linuxRepo;
  String? get alpineRepo => _linuxRepo;

  Future<void> setAplineRepo(String arg) async {
    _linuxRepo = arg;
    await Store.setString(LINUX_REPO, arg);
  }

  ///WEBDAV
  late String? _webDavAddr;
  String? get webDavAddr => _webDavAddr;

  Future<void> setWebDavAddr(String arg) async {
    _webDavAddr = arg;
    await Store.setString(WEBDAV_ADDR, arg);
  }

  late String? _webDavUsername;
  String? get webDavUsername => _webDavUsername;

  Future<void> setWebDavUsername(String arg) async {
    _webDavUsername = arg;
    await Store.setString(WEBDAV_USERNAME, arg);
  }

  String? _webDavPwd;
  String? get webDavPwd => _webDavPwd;

  Future<void> setWebDavPwd(String arg) async {
    _webDavPwd = arg;
    await secureStorage.write(key: WEBDAV_PWD, value: arg);
  }

  // 默认为{}
  late Map _gWebData = {};
  Map get gWebData => _gWebData;

  Future<void> setGobalWebData(Map arg) async {
    _gWebData = arg;
  }

  String? _username;
  String? get username => _username;

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
    try {
      _filePort = (await Store.getString(FILE_PORT)) ?? FILE_DEFAULT_PORT;

      _codeSrvPort = await Store.getString(CODE_SERVER_PORT) ?? '20202';
      _codeSrvPwd = await secureStorage.read(key: CODE_SERVER_PWD);
      _linuxRepo = (await Store.getString(LINUX_REPO)) ?? TSINGHUA_REPO;

      _codeSrvTelemetry = await Store.getBool(CODE_SERVER_TELEMETRY) ?? false;

      _webDavAddr = await Store.getString(WEBDAV_ADDR);
      _webDavUsername = await Store.getString(WEBDAV_USERNAME);
      _webDavPwd = await secureStorage.read(key: WEBDAV_PWD);
      _enableClipboard = (await Store.getBool(ENABLE_CLIPBOARD)) ?? true;
      _isPurchased = (await secureStorage.read(key: PURCHASED)) == 'true';
      _isAppNotInit = (await Store.getBool(APP_INIT)) ?? true;
      _isFileOptionPromptNotInit =
          (await Store.getBool(FILE_OPTION_INIT)) ?? true;
      _username = await Store.getString(LOGIN_USERNMAE);
      _autoConnectExpress = (await Store.getBool(AUTO_CONNECT_EXPRESS)) ?? true;
      _enableConnect = (await Store.getBool(ENABLE_CONNECT)) ?? true;

      String? tmpCommonIps = await Store.getString(COMMON_IPS);
      _commonIps = tmpCommonIps == null ? Map() : json.decode(tmpCommonIps);

      _enableAutoConnectCommonIp =
          (await Store.getBool(AUTO_CONNECT_COMMON_IP)) ?? true;
      _storageRootPath = await MixUtils.getExternalRootPath();
      _language = (await Store.getString(LANGUAGE)) ??
          Platform.localeName.split('_').elementAt(0);
      _staticUploadSavePath = (await Store.getString(STATIC_UPLOAD_SAVEPATH)) ??
          await MixUtils.getPrimaryStaticUploadSavePath(_storageRootPath!);
    } catch (e, s) {
      await Sentry.captureException(
        e,
        stackTrace: s,
      );
    }
  }
}

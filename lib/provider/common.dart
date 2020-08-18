import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_ip/get_ip.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/utils/store.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CommonProvider extends ChangeNotifier {
  final secureStorage = FlutterSecureStorage();

  bool _isShowHidden;
  bool get isShowHidden => _isShowHidden;

  String _sortType;
  String get sortType => _sortType;

  bool _sortReversed;
  bool get sortReversed => _sortReversed;

  String _expressPort = '20201';
  String get expressPort => _expressPort;

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;

  Future<void> setPurchase(bool arg) async {
    _isPurchased = arg;
    secureStorage.write(key: PURCHASED, value: arg.toString());
    notifyListeners();
  }

  ShowOnlyType _showOnlyType = ShowOnlyType.all;
  ShowOnlyType get showOnlyType => _showOnlyType;

  String _internalIp;
  String get internalIp => _internalIp;

  Set<String> _aliveIps = Set();
  Set<String> get aliveIps => _aliveIps;

  IO.Socket _socket;
  IO.Socket get socket => _socket;

  int _staticPort;
  int get staticPort => _staticPort;

  Future<void> setStaticPort(int arg) async {
    _staticPort = arg;
    notifyListeners();
  }

  Future<void> setInternalIp(String arg) async {
    _internalIp = arg;
    notifyListeners();
  }

  Future<void> setPort(String arg) async {
    _expressPort = arg;
    notifyListeners();
  }

  Future<void> setSocket(IO.Socket arg) async {
    _socket = arg;
    // notifyListeners();
  }

  Future<void> pushAliveIps(String arg, {notify = true}) async {
    _aliveIps.add(arg);
    if (notify) notifyListeners();
  }

  Future<void> removeAliveIps(String arg, {notify = true}) async {
    _aliveIps.remove(arg);
    if (notify) notifyListeners();
  }

  Future<void> setShowHidden(bool arg) async {
    _isShowHidden = arg;
    notifyListeners();
  }

  Future<void> setShowOnlyType(ShowOnlyType arg) async {
    _showOnlyType = arg;
    notifyListeners();
  }

  // String _tempZipExtract;
  // String get tempZipExtract => _tempZipExtract;

  // Future<void> setTempZipExtract(String arg) async {
  //   _tempZipExtract = arg;
  //   notifyListeners();
  // }

  // SelfFileEntity _copyTarget;
  // SelfFileEntity get copyTarget => _copyTarget;

  // Future<void> setCopyTarget(SelfFileEntity arg) async {
  //   _copyTarget = arg;
  //   // notifyListeners();
  // }

  // SelfFileEntity _moveTarget;
  // SelfFileEntity get moveTarget => _moveTarget;

  // Future<void> setMoveTarget(SelfFileEntity arg) async {
  //   _moveTarget = arg;
  // }

  // SelfFileEntity _archiveTarget;
  // SelfFileEntity get archiveTarget => _archiveTarget;

  // Future<void> setArchiveTarget(SelfFileEntity arg) async {
  //   _archiveTarget = arg;
  // }

  Future<void> setSortType(String arg) async {
    _sortType = arg;
    notifyListeners();
  }

  Future<void> setSortReversed(bool arg) async {
    _sortReversed = arg;
    notifyListeners();
  }

  Future<void> initCommon() async {
    _isShowHidden = (await Store.getBool(SHOW_FILE_HIDDEN)) ?? false;
    _sortType = (await Store.getString(FILE_SORT_TYPE)) ?? SORT_CASE;
    _sortReversed = (await Store.getString(SORT_REVERSED)) ?? false;
    _staticPort = (await Store.getString(SORT_REVERSED)) ?? 20201;

    // String tempPurchased = await secureStorage.read(key: PURCHASED);
    _isPurchased = bool.fromEnvironment(
        (await secureStorage.read(key: PURCHASED)) ?? 'false');

    _internalIp = await GetIp.ipAddress;
  }
}

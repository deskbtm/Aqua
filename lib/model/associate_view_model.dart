import 'dart:io';
import 'package:aqua/page/file_manager/fs_ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';

class AssociateViewModel extends ChangeNotifier {
  // 当前目录
  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory? dir, {update: false}) {
    _currentDir = dir;
    if (update) notifyListeners();
  }

  List<SelfFileEntity>? _majorList;
  List<SelfFileEntity>? get majorList => _majorList;

  Future<void> setMajorList(context, Directory dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir).then((list) {
      _majorList = list;
      if (update) notifyListeners();
    }).catchError((err) {
      throw Exception(err);
    });
  }

  List<SelfFileEntity>? _minorList;
  List<SelfFileEntity>? get minorList => _minorList;

  Future<void> setMinorList(context, Directory? dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir!).then((list) {
      _minorList = list;
      if (update) notifyListeners();
    }).catchError((err) {
      throw Exception(err);
    });
  }

  Future<void> setMinorListDirectly(context, List<SelfFileEntity>? list,
      {update = false}) async {
    _minorList = list;

    if (update) notifyListeners();
  }

  bool _isSelectAll = false;
  bool get isSelectAll => _isSelectAll;

  Future<void> setSelectAll({update = false}) async {
    _isSelectAll = !_isSelectAll;

    if (update) notifyListeners();
  }
}

AssociateViewModel associateViewModel = AssociateViewModel();

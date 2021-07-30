import 'dart:io';
import 'package:aqua/page/file_manager/fs_ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/utils/store.dart';
import 'package:path/path.dart' as pathLib;

/// 处理独立模式
///
/// 第一个文件文件的当前目录

class IndependentModel extends ChangeNotifier {
  // 当前目录
  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory? dir, {update: false}) {
    _currentDir = dir;
    if (update) notifyListeners();
  }

  List<SelfFileEntity>? _firstList;
  List<SelfFileEntity>? get firstList => _firstList;

  Future<void> setFirstList(context, Directory dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir).then((list) {
      _firstList = list;
      if (update) notifyListeners();
    });
  }

  List<SelfFileEntity>? _secondList;
  List<SelfFileEntity>? get secondList => _secondList;

  Future<void> setSecondList(context, Directory? dir, {update = false}) async {
    await FsUIUtils.readdir(context, dir!).then((list) {
      _secondList = list;
      if (update) notifyListeners();
    }).catchError((err) {
      throw Exception(err);
    });
  }

  Future<void> setSecondListDirectly(context, List<SelfFileEntity>? list,
      {update = false}) async {
    _secondList = list;

    if (update) notifyListeners();
  }

  Directory? _firstCurrentDir;
  Directory? get firstCurrentDir => _firstCurrentDir;

  void setFirstCurrentDir(Directory? dir, {update: false}) {
    _firstCurrentDir = dir;
    if (update) notifyListeners();
  }

  Directory? _secondCurrentDir;
  Directory? get secondCurrentDir => _secondCurrentDir;

  void setSecondCurrentDir(Directory? dir, {update: false}) {
    _secondCurrentDir = dir;
    if (update) notifyListeners();
  }
}

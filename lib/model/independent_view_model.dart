import 'dart:io';
import 'package:aqua/page/file_manager/fs_ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';

// 正在使用的窗口
enum IndependentActiveWindow { first, second }

/// 处理独立模式
///
/// 两个窗口各司其职

class IndependentViewModel extends ChangeNotifier {
  // 用于focused窗口的当前目录
  Directory? _currentDir;
  Directory? get currentDir => _currentDir;

  void setCurrentDir(Directory? dir, {update: false}) {
    _currentDir = dir;
    if (update) notifyListeners();
  }

  // 第一个窗口的当前目录
  Directory? _firstCurrentDir;
  Directory? get firstCurrentDir => _firstCurrentDir;

  void setFirstCurrentDir(Directory? dir, {update: false}) {
    _firstCurrentDir = dir;
    _currentDir = dir;
    if (update) notifyListeners();
  }

  // 当前正在使用的窗口
  IndependentActiveWindow _activeWindow = IndependentActiveWindow.first;
  IndependentActiveWindow get activeWindow => _activeWindow;

  void setActiveWindow(IndependentActiveWindow active, {update: false}) {
    _activeWindow = active;
    if (update) notifyListeners();
  }

  // 第二个窗口的当前目录
  Directory? _secondCurrentDir;
  Directory? get secondCurrentDir => _secondCurrentDir;

  void setSecondCurrentDir(Directory? dir, {update: false}) {
    _secondCurrentDir = dir;
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
}

IndependentViewModel independentViewModel = IndependentViewModel();

import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:flutter/material.dart';

class SelectFileModel extends ChangeNotifier {
  List<SelfFileEntity> _selectedFiles = [];
  List<SelfFileEntity> get selectedFiles => _selectedFiles;

  List<SelfFileEntity> _pickedFiles = [];
  List<SelfFileEntity> get pickedFiles => _pickedFiles;

  Future<void> addSelectedFile(SelfFileEntity value,
      {bool update = false}) async {
    bool included =
        _selectedFiles.any((ele) => ele.entity.path == value.entity.path);
    if (!included) {
      _selectedFiles.add(value);
      if (update) notifyListeners();
    }
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

  Future<void> addPickedFile(SelfFileEntity value,
      {bool update = false}) async {
    bool included =
        _pickedFiles.any((ele) => ele.entity.path == value.entity.path);
    if (!included) {
      _pickedFiles.add(value);
      if (update) notifyListeners();
    }
  }

  Future<void> removePickedFile(SelfFileEntity value,
      {bool update = false}) async {
    _pickedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    if (update) notifyListeners();
  }

  bool? hasPickedFile(String path) {
    return _pickedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearPickedFiles({bool update = false}) async {
    _pickedFiles = [];
    if (update) notifyListeners();
  }
}

/// [RightQuickBoard] , [FileManagerPage]等组件共享状态
SelectFileModel selectFileModel = SelectFileModel();

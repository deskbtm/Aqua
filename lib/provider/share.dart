import 'package:flutter/cupertino.dart';
import 'package:lan_express/page/file_manager/file_action.dart';

class ShareProvider extends ChangeNotifier {
  List<SelfFileEntity> _selectedFiles = [];
  List<SelfFileEntity> get selectedFiles => _selectedFiles;

  Future<void> addFile(SelfFileEntity value) async {
    if (!_selectedFiles.any((ele) => ele.entity.path == value.entity.path))
      _selectedFiles.add(value);

    notifyListeners();
  }

  Future<void> removeFile(SelfFileEntity value) async {
    _selectedFiles.removeWhere((ele) => ele.entity.path == value.entity.path);
    notifyListeners();
  }

  bool has(String path) {
    return _selectedFiles.any((ele) => ele.entity.path == path);
  }

  Future<void> clearSelectedFiles() async {
    _selectedFiles = [];
    notifyListeners();
  }
}

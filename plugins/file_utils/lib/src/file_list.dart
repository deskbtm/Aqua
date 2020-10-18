part of file_utils;

class FileList extends Object with ListMixin<String> {
  static final bool _isWindows = Platform.isWindows;

  final Directory directory;

  bool _caseSensitive;

  List<String> _files;

  void Function(String) _notify;

  String _pattern;

  /// Creates file list.
  ///
  /// Parameters:
  ///  [directory]
  ///   Directory whic will be listed.
  ///  [pattern]
  ///   Glob pattern of this file list.
  ///  [caseSensitive]
  ///   True, if the pattern is case sensitive; otherwise false.
  ///  [notify]
  ///   Function that is called whenever an item is added.
  FileList(this.directory, String pattern,
      {bool caseSensitive, void Function(String path) notify}) {
    if (directory == null) {
      throw ArgumentError('directory: $directory');
    }

    if (pattern == null) {
      throw ArgumentError('pattern: $pattern');
    }

    if (caseSensitive == null) {
      if (_isWindows) {
        caseSensitive = false;
      } else {
        caseSensitive = true;
      }
    }

    _caseSensitive = caseSensitive;
    _notify = notify;
    _pattern = FilePath.expand(pattern);
    _files = _getFiles();
  }

  /// Returns the length.
  @override
  int get length {
    return _files.length;
  }

  /// Sets the length;
  @override
  set length(int length) {
    throw UnsupportedError('length=');
  }

  @override
  String operator [](int index) {
    return _files[index];
  }

  @override
  void operator []=(int index, String value) {
    throw UnsupportedError('[]=');
  }

  bool _exists(String path) {
    if (!Directory(path).existsSync()) {
      if (!File(path).existsSync()) {
        if (!Link(path).existsSync()) {
          return false;
        }
      }
    }

    return true;
  }

  List<String> _getFiles() {
    final lister = GlobLister(_pattern,
        caseSensitive: _caseSensitive,
        exists: _exists,
        isDirectory: _isDirectory,
        isWindows: _isWindows,
        list: _list);
    return lister.list(directory.path, notify: _notify);
  }

  bool _isDirectory(String path) {
    return Directory(path).existsSync();
  }

  List<String> _list(String path, bool followLinks) {
    List<String> result;
    try {
      result = Directory(path)
          .listSync(followLinks: followLinks)
          .map((e) => e.path)
          .toList();
    } catch (e) {
      result = <String>[];
    }

    return result;
  }
}

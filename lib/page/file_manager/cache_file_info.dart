import 'package:flutter/cupertino.dart';

class CacheFileInfo {
  final String path;
  final String modified;
  final String size;
  final Widget leading;
  final String filename;

  CacheFileInfo({
    required this.filename,
    required this.path,
    required this.modified,
    required this.size,
    required this.leading,
  });
}

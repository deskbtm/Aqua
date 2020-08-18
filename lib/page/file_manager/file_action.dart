import 'dart:io';
import 'dart:typed_data';
import 'package:android_mix/android_mix.dart';
import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:path/path.dart' as pathLib;

enum ShowOnlyType { all, folder, file, link }

enum ArchiveType { zip, tar, zlib, gz, tgz, bz2, tbz2 }

class SelfFileEntity {
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final FileSystemEntityType type;
  final int mode;
  final int size;
  final FileSystemEntity entity;
  final String filename;
  final String ext;
  final String name;
  final String modeString;
  final String humanSize;
  final Uint8List apkIcon;
  final bool isDir;
  final bool isLink;
  final bool isFile;

  SelfFileEntity({
    this.name,
    this.apkIcon,
    this.isLink,
    this.isFile,
    this.ext,
    this.humanSize,
    this.changed,
    this.accessed,
    this.mode,
    this.size,
    @required this.isDir,
    @required this.filename,
    @required this.modified,
    @required this.type,
    @required this.entity,
    this.modeString,
  });
}

class SelfFileList {
  final List<SelfFileEntity> folderList;
  final List<SelfFileEntity> fileList;
  final List<SelfFileEntity> linkList;
  final List<SelfFileEntity> allList;
  final List<SelfFileEntity> imageList;
  final Directory cwd;

  SelfFileList({
    this.cwd,
    this.folderList,
    this.fileList,
    this.linkList,
    this.imageList,
    this.allList,
  });
}

class FileAction {
  final String externalStoragePath;

  FileAction({this.externalStoragePath});

  Future<SelfFileList> readdir(
    Directory currentDir, {
    bool autoSort = true,
    String sortType = SORT_CASE,
    bool showHidden = false,
    bool reversed = false,
  }) async {
    if (!await currentDir.exists()) {
      return null;
    }

    List<SelfFileEntity> folderList = [];
    List<SelfFileEntity> fileList = [];
    List<SelfFileEntity> linkList = [];
    List<SelfFileEntity> imageList = [];

    await for (var content in currentDir.list()) {
      if (await content.exists()) {
        FileStat stat = await content.stat();

        String filename = pathLib.basename(content.path);
        String ext = pathLib.extension(content.path).toLowerCase();
        Uint8List icon;

        if (ext == '.apk') {
          icon = (await AndroidMix.packager.getApkInfo(content.path))['icon'];
        }

        SelfFileEntity fileEntity = SelfFileEntity(
          changed: stat.changed,
          modified: stat.modified,
          accessed: stat.accessed,
          type: stat.type,
          mode: stat.mode,
          modeString: stat.modeString(),
          size: stat.size,
          entity: content,
          filename: filename,
          ext: ext,
          humanSize: MixUtils.humanStorageSize(stat.size.toDouble()),
          apkIcon: icon,
          isDir: stat.type == FileSystemEntityType.directory,
          isFile: stat.type == FileSystemEntityType.file,
          isLink: stat.type == FileSystemEntityType.link,
          name: pathLib.basenameWithoutExtension(filename),
        );

        if (showHidden && fileEntity.filename[0] == '.') {
          continue;
        }

        switch (stat.type) {
          case FileSystemEntityType.directory:
            folderList.add(fileEntity);
            break;
          case FileSystemEntityType.file:
            fileList.add(fileEntity);
            break;
          case FileSystemEntityType.link:
            linkList.add(fileEntity);
            break;
        }

        if (IMG_EXTS.contains(ext.toLowerCase())) {
          imageList.add(fileEntity);
        }
      }
    }

    switch (sortType) {
      case SORT_CASE:
        folderList = sortByCase(folderList, reversed: reversed);
        fileList = sortByCase(fileList, reversed: reversed);
        linkList = sortByCase(linkList, reversed: reversed);
        break;
      case SORT_SIZE:
        folderList = sortBySize(folderList, reversed: reversed);
        fileList = sortBySize(fileList, reversed: reversed);
        linkList = sortBySize(linkList, reversed: reversed);
        break;
      case SORT_MODIFIED:
        folderList = sortByModified(folderList, reversed: reversed);
        fileList = sortByModified(fileList, reversed: reversed);
        linkList = sortByModified(linkList, reversed: reversed);
        break;
      case SORT_TYPE:
        folderList = sortByType(folderList, reversed: reversed);
        fileList = sortByType(fileList, reversed: reversed);
        linkList = sortByType(linkList, reversed: reversed);
        break;
      default:
        folderList = sortByCase(folderList, reversed: reversed);
        fileList = sortByCase(fileList, reversed: reversed);
        linkList = sortByCase(linkList, reversed: reversed);
    }

    return SelfFileList(
      folderList: folderList,
      fileList: fileList,
      linkList: linkList,
      imageList: imageList,
      allList: [...?folderList, ...?fileList, ...?linkList],
      cwd: currentDir,
    );
  }

  List<SelfFileEntity> sortByCase(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) {
      String preBase = pathLib.basename(pre.entity.path).toLowerCase();
      String nextBase = pathLib.basename(next.entity.path).toLowerCase();
      return preBase.compareTo(nextBase);
    });
    return reversed ? list.reversed.toList() : list;
  }

  List<SelfFileEntity> sortBySize(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.size > next.size ? -1 : 1);
    return reversed ? list.reversed.toList() : list;
  }

  List<SelfFileEntity> sortByType(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.mode > next.mode ? -1 : 1);
    return reversed ? list.reversed.toList() : list;
  }

  List<SelfFileEntity> sortByModified(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.modified.millisecondsSinceEpoch >
            next.modified.millisecondsSinceEpoch
        ? -1
        : 1);
    return reversed ? list.reversed.toList() : list;
  }

  String filename(String path) => pathLib.basename(path);

  Future<void> delete() async {}

  // Future<void> copy(dynamic src, Directory dest,
  //     {@required Function onExist}) async {
  //   // if (await dest.exists()) {
  //   //   onExist();
  //   // }
  // }

  bool _doNothing(String from, String to) {
    if (pathLib.canonicalize(from) == pathLib.canonicalize(to)) {
      return true;
    }
    if (pathLib.isWithin(from, to)) {
      throw ArgumentError('Cannot copy from $from to $to');
    }
    return false;
  }

  Future<Null> copyDir(String from, String to) async {
    if (_doNothing(from, to)) {
      return;
    }
    await Directory(to).create(recursive: true);
    await for (final file in Directory(from).list(recursive: true)) {
      final copyTo = pathLib.join(to, pathLib.relative(file.path, from: from));
      if (file is Directory) {
        await Directory(copyTo).create(recursive: true);
      } else if (file is File) {
        await File(file.path).copy(copyTo);
      } else if (file is Link) {
        await Link(copyTo).create(await file.target(), recursive: true);
      }
    }
  }

  Future<Null> copy(
    SelfFileEntity from,
    String to,
  ) async {
    FileSystemEntity entity = from.entity;
    if (_doNothing(entity.path, to)) {
      return;
    }

    if (from.isDir) {
      await copyDir(entity.path, to);
    } else if (entity is File) {
      await File(entity.path).copy(to);
    } else if (entity is Link) {
      await Link(to).create(await entity.target(), recursive: true);
    }
  }

  String renameNewPath(String origin, String filename) {
    filename = trimSlash(filename);
    if (pathLib.extension(filename) == '') {
      return pathLib.join(
          pathLib.dirname(origin), filename + pathLib.extension(origin));
    } else {
      return pathLib.join(pathLib.dirname(origin), filename);
    }
  }

  Future<void> rename(
    SelfFileEntity file,
    String targetPath, {
    @required VoidCallback onExists,
  }) async {
    if (await File(targetPath).exists()) {
      onExists();
    } else {
      await file.entity.rename(targetPath);
    }
  }

  Future<void> preview() async {}
  Future<void> move() async {
    // FileUtils.
  }
  Future<void> checkDetail() async {}
  Future<void> share() async {}
  Future<void> shareLan() async {}

  Future<void> unArchive(String from, String to) async {
    List<int> bytes = new File(from).readAsBytesSync();
    Archive archive = new ZipDecoder().decodeBytes(bytes);

    await for (ArchiveFile file in Stream.fromIterable(archive)) {
      String filename = file.name;
      print(filename);
      List<int> data = file.content;
      if (file.isFile) {
        File(to + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else if (file.isSymbolicLink) {
        Link(to + filename);
      } else {
        Directory(to + filename)..createSync(recursive: true);
      }
    }
  }

  Future<void> archive() async {}

  Future<void> createFile(String currentDir, String name,
      {@required VoidCallback onExists, bool recursive = false}) async {
    name = trimSlash(name);
    File newFile = File(pathLib.join(currentDir, name));
    if (await newFile.exists()) {
      onExists();
    } else {
      await newFile.create(recursive: recursive);
    }
  }

  String trimSlash(String name) {
    return name.trim().replaceAll(RegExp(r"^(\/+)|(\/+)$"), '');
  }

  static String genPathWhenExists(String path, String ext) {
    String newPath;
    String originPath = pathLib.join(path, pathLib.basename(path) + ext);
    if (File(originPath).existsSync()) {
      newPath = pathLib.join(
          path, pathLib.basename(path) + '-' + DateTime.now().toString() + ext);
    } else {
      newPath = originPath;
    }
    return newPath;
  }

  static Map getType(File file) {
    return {
      'isDir': file.statSync().type == FileSystemEntityType.directory,
      'isLink': file.statSync().type == FileSystemEntityType.link,
      'isFile': file.statSync().type == FileSystemEntityType.file,
    };
  }
}

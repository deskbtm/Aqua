import 'dart:io';
import 'dart:typed_data';

import 'package:aqua/plugin/pkg_mgmt/mgmt.dart';
import 'package:flutter/widgets.dart';
import 'package:aqua/common/widget/images.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:path/path.dart' as pathLib;

enum ShowOnlyType { all, folder, file, link }

class SelfFileEntity {
  final DateTime changed;
  final DateTime modified;
  final DateTime accessed;
  final FileSystemEntityType type;
  final int mode;
  final int size;
  final String path;
  final FileSystemEntity entity;
  final String filename;
  final String ext;
  final String pureName;
  final String modeString;
  final String humanSize;
  final Uint8List? apkIcon;
  final bool isDir;
  final bool isLink;
  final bool isFile;

  SelfFileEntity({
    required this.path,
    required this.pureName,
    required this.apkIcon,
    required this.isLink,
    required this.isFile,
    required this.ext,
    required this.humanSize,
    required this.changed,
    required this.accessed,
    required this.mode,
    required this.size,
    required this.isDir,
    required this.filename,
    required this.modified,
    required this.type,
    required this.entity,
    required this.modeString,
  });
}

class SelfFileList {
  final List<SelfFileEntity> folderList;
  final List<SelfFileEntity> fileList;
  final List<SelfFileEntity> linkList;
  final List<SelfFileEntity> allList;
  final Directory cwd;

  SelfFileList({
    required this.cwd,
    required this.folderList,
    required this.fileList,
    required this.linkList,
    required this.allList,
  });
}

class FsUtils {
  static Future<SelfFileEntity> createSelfFileEntity(
      FileSystemEntity content) async {
    FileStat stat = await content.stat();

    String filename = pathLib.basename(content.path);
    String ext = pathLib.extension(content.path).trim().toLowerCase();
    Uint8List? apkIcon;

    if (ext == '.apk') {
      apkIcon = (await PackageMgmt.getApkInfo(content.path))['icon'];
    }

    return SelfFileEntity(
      changed: stat.changed,
      modified: stat.modified,
      accessed: stat.accessed,
      path: content.path,
      type: stat.type,
      mode: stat.mode,
      modeString: stat.modeString(),
      size: stat.size,
      entity: content,
      filename: filename,
      ext: ext,
      humanSize: MixUtils.humanStorageSize(stat.size.toDouble()),
      apkIcon: apkIcon,
      isDir: stat.type == FileSystemEntityType.directory,
      isFile: stat.type == FileSystemEntityType.file,
      isLink: stat.type == FileSystemEntityType.link,
      pureName: pathLib.basenameWithoutExtension(filename),
    );
  }

  static Future<SelfFileList?> readdir(
    Directory currentDir, {
    bool autoSort = true,
    String sortType = SORT_CASE,
    bool showHidden = false,
    bool reversed = false,
    bool recursive = false,
  }) async {
    if (!await currentDir.exists()) {
      return null;
    }

    List<SelfFileEntity> folderList = [];
    List<SelfFileEntity> fileList = [];
    List<SelfFileEntity> linkList = [];

    await for (var content in currentDir.list(recursive: recursive)) {
      if (await content.exists()) {
        SelfFileEntity fileEntity = await createSelfFileEntity(content);

        if (!showHidden && fileEntity.filename[0] == '.') {
          continue;
        }

        switch (fileEntity.type) {
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
      allList: [...folderList, ...fileList, ...linkList],
      cwd: currentDir,
    );
  }

  static List<SelfFileEntity> sortByCase(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) {
      String preBase = pathLib.basename(pre.entity.path).toLowerCase();
      String nextBase = pathLib.basename(next.entity.path).toLowerCase();
      return preBase.compareTo(nextBase);
    });
    return reversed ? list.reversed.toList() : list;
  }

  static List<SelfFileEntity> sortBySize(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.size > next.size ? -1 : 1);
    return reversed ? list.reversed.toList() : list;
  }

  static List<SelfFileEntity> sortByType(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.mode > next.mode ? -1 : 1);
    return reversed ? list.reversed.toList() : list;
  }

  static List<SelfFileEntity> sortByModified(List<SelfFileEntity> list,
      {bool reversed = false}) {
    list.sort((pre, next) => pre.modified.millisecondsSinceEpoch >
            next.modified.millisecondsSinceEpoch
        ? -1
        : 1);
    return reversed ? list.reversed.toList() : list;
  }

  static String filename(String path) => pathLib.basename(path);

  static bool doNothing(String from, String to) {
    if (pathLib.canonicalize(from) == pathLib.canonicalize(to)) {
      return true;
    }
    if (pathLib.isWithin(from, to)) {
      throw ArgumentError('Cannot copy from $from to $to');
    }
    return false;
  }

  static Future<Null> copyDir(String from, String to) async {
    if (doNothing(from, to)) {
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

  static Future<Null> copy(
    SelfFileEntity from,
    String to,
  ) async {
    FileSystemEntity entity = from.entity;
    if (doNothing(entity.path, to)) {
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

  static String renameNewPath(String origin, String filename) {
    filename = trimSlash(filename);
    if (pathLib.extension(filename) == '') {
      return pathLib.join(
          pathLib.dirname(origin), filename + pathLib.extension(origin));
    } else {
      return pathLib.join(pathLib.dirname(origin), filename);
    }
  }

  // 去除路径前缀/ 后缀/
  static String trimSlash(String name) {
    return name.trim().replaceAll(RegExp(r"^(\/+)|(\/+)$"), '');
  }

  static String newPathWhenExists(String noExt, String ext) {
    String newPath = noExt + ext;
    if (File(newPath).existsSync()) {
      newPath = noExt + '-' + DateTime.now().toString() + ext;
    }
    return newPath;
  }

  static String getName(String name) {
    if (name.contains('.')) {
      return getName(pathLib.basenameWithoutExtension(name));
    } else {
      return name;
    }
  }

  static String getArchiveName(List<String> paths, String bak) {
    String name;
    if (paths.length == 1) {
      name = getName(paths.first);
    } else {
      name = pathLib.basename(bak);
    }
    return name;
  }

  static void matchFileExt(
    String ext, {
    required Function casePPT,
    required Function caseWord,
    required Function caseCVS,
    required Function caseFlash,
    required Function caseExcel,
    required Function caseHtml,
    required Function casePdf,
    required Function caseImage,
    required Function caseText,
    required Function caseAudio,
    required Function caseVideo,
    required Function caseArchive,
    required Function casePs,
    required Function caseApk,
    required Function caseFolder,
    required Function caseSymbolLink,
    required Function caseMd,
    required Function defaultExec,
  }) {
    ext = ext.toLowerCase();
    switch (ext) {
      case '.ppt':
      case '.pptx':
        if (casePPT != null) casePPT();
        break;
      case '.doc':
      case '.docx':
        if (caseWord != null) caseWord();
        break;
      case '.cvs':
        if (caseCVS != null) caseCVS();
        break;
      case '.swf':
        if (caseFlash != null) caseFlash();
        break;
      case '.xls':
      case '.xlsx':
        if (caseExcel != null) caseExcel();
        break;
      case '.htm':
      case '.html':
        if (caseHtml != null) caseHtml();
        break;
      case '.pdf':
        if (casePdf != null) casePdf();
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        if (caseImage != null) caseImage();
        break;
      case '.txt':
        if (caseText != null) caseText();
        break;
      case '.flac':
      case '.mp3':
      case '.wav':
      case '.mid':
        if (caseAudio != null) caseAudio();
        break;
      case '.md':
        if (caseMd != null) caseMd();
        break;
      case '.mp4':
      case '.flv':
      case '.avi':
      case '.mov':
      case '.wmv':
      case '.rmvb':
      case '.rm':
      case '.asf':
      case '.mpg':
      case '.mpeg':
        if (caseVideo != null) caseVideo();
        break;
      case '.zip':
      case '.rar':
      case '.gz':
      case '.cz':
      case '.xz':
      case '.tar':
      case '.tgz':
      case '.bz':
      case '.bz2':
      case '.tbz2':
        if (caseArchive != null) caseArchive();
        break;
      case '.psd':
        if (casePs != null) casePs();
        break;
      case '.apk':
        if (caseApk != null) caseApk();
        break;
      case 'folder':
        if (caseFolder != null) caseFolder();
        break;
      case 'link':
        if (caseSymbolLink != null) caseSymbolLink();
        break;
      default:
        if (defaultExec != null) defaultExec();
        break;
    }
  }

  static Widget matchEntryByMimeType(
    String mime, {
    required Widget Function() caseText,
    required Widget Function() caseImage,
    required Widget Function() caseVideo,
    required Widget Function() caseDefault,
  }) {
    Widget result;
    if (RegExp(r"text/.*").hasMatch(mime) && caseText != null) {
      result = caseText();
    } else if (RegExp(r"image/.*").hasMatch(mime) && caseImage != null) {
      result = caseImage();
    } /* else if (RegExp(r"audio/.*").hasMatch(mime) && caseAudio != null) {
    result = caseAudio();
  } */
    else if (RegExp(r"video/.*").hasMatch(mime) && caseVideo != null) {
      result = caseVideo();
    } /* else if (RegExp(r"application/.*").hasMatch(mime) && caseBinary != null) {
      result = caseBinary();
    }  */
    else {
      result = caseDefault();
    }

    return result;
  }

  static void matchFileActionByExt(
    String ext, {
    required Function caseImage,
    required Function caseText,
    required Function caseAudio,
    required Function caseVideo,
    required Function caseMd,
    required Function caseArchive,
    required Function defaultExec,
  }) {
    ext = ext.toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        if (caseImage != null) caseImage();
        break;
      case '.txt':
        if (caseText != null) caseText();
        break;
      case '.zip':
      case '.gz':
      case '.tar':
      case '.tgz':
      case '.xz':
      case '.txz':
      case '.bz2':
      case '.tbz2':
      case '.jar':
        if (caseArchive != null) caseArchive();
        break;
      case '.flac':
      case '.mp3':
      case '.wav':
      case '.mid':
        if (caseAudio != null) caseAudio();
        break;
      case '.md':
        if (caseMd != null) caseMd();
        break;
      case '.flv':
      case '.avi':
      case '.mov':
      case '.wmv':
      case '.rmvb':
      case '.rm':
      case '.asf':
      case '.mpg':
      case '.mpeg':
      case '.mp4':
        if (caseVideo != null) caseVideo();
        break;
      default:
        if (defaultExec != null) defaultExec();
        break;
    }
  }

  static Widget matchFileIcon(String ext, {double size = 30}) {
    late Widget iconImg;

    matchFileExt(
      ext,
      casePPT: () {
        iconImg = AppImages.ppt();
      },
      caseWord: () {
        iconImg = AppImages.word();
      },
      caseCVS: () {
        iconImg = AppImages.cvs();
      },
      caseFlash: () {
        iconImg = AppImages.flash();
      },
      caseExcel: () {
        iconImg = AppImages.excel();
      },
      caseHtml: () {
        iconImg = AppImages.html();
      },
      casePdf: () {
        iconImg = AppImages.pdf();
      },
      caseImage: () {
        iconImg = AppImages.image();
      },
      caseText: () {
        iconImg = AppImages.txt();
      },
      caseAudio: () {
        iconImg = AppImages.audio();
      },
      caseVideo: () {
        iconImg = AppImages.video();
      },
      caseArchive: () {
        iconImg = AppImages.zip();
      },
      casePs: () {
        iconImg = AppImages.psd();
      },
      caseApk: () {
        iconImg = AppImages.apk();
      },
      caseFolder: () {
        iconImg = AppImages.folder();
      },
      caseSymbolLink: () {
        iconImg = AppImages.link();
      },
      caseMd: () {
        iconImg = AppImages.md();
      },
      defaultExec: () {
        iconImg = AppImages.unknown();
      },
    );

    return iconImg;
  }

// ignore: non_constant_identifier_names
  static List<String> IMG_EXTS = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];

// ignore: non_constant_identifier_names
  static List<String> ARCHIVE_EXTS = [
    '.zip',
    '.gz',
    '.tar',
    '.tgz',
    '.xz',
    '.txz',
    '.bz2',
    '.tbz2',
    '.jar',
  ];

// ignore: non_constant_identifier_names
  static List<String> VIDEO_EXTS = [
    '.mp4',
    '.flv',
    '.avi',
    '.mov',
    '.wmv',
    '.rmvb',
    '.rm',
    '.asf',
    '.mpg',
    '.mpeg',
  ];

  static List<String> HAVE_THUMBNAIL = [
    ...IMG_EXTS,
    ...VIDEO_EXTS,
  ];

  static List<String> filterImages(List<SelfFileEntity> list) {
    List<String> result = [];
    for (var item in list) {
      if (IMG_EXTS.contains(item.ext)) {
        result.add(item.entity.path);
      }
    }
    return result;
  }
}

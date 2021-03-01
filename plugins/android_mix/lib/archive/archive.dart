import 'package:android_mix/archive/enums.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';

abstract class ArchiveBasic {
  void onZipArchive(dynamic data) {}
  void onZipSuccess() {}
  void onZipError() {}
  void onZipCancel() {}
}

class Archive {
  MethodChannel _channel;

  Archive(MethodChannel mc) {
    _channel = mc;
  }

  Future<bool> zip(
    List<String> paths,
    String targetPath, {
    ZipCompressLevel level = ZipCompressLevel.normal,
    ZipCompressMethod method = ZipCompressMethod.deflate,
    ZipEncryptionMethod encrypt = ZipEncryptionMethod.standard,
    String pwd,
  }) async {
    return _channel.invokeMethod('zip', {
      'paths': paths,
      'targetPath': targetPath,
      'level': level.index,
      'method': method.index,
      'encrypt': encrypt.index,
      'pwd': pwd,
    });
  }

  Future<bool> unzip(
    String path,
    String targetPath, {
    String pwd,
  }) async {
    return _channel.invokeMethod('unzip', {
      'path': path,
      'targetPath': targetPath,
      'pwd': pwd,
    });
  }

  Future<bool> isZipEncrypted(String path) {
    return _channel.invokeMethod('isZipEncrypted', {
      'path': path,
    });
  }

  Future<bool> isValidZipFile(String path) {
    return _channel.invokeMethod('isValidZipFile', {
      'path': path,
    });
  }

  Future<bool> extractArchive(
      String path, String dest, ArchiveFormat archiveFormat,
      {CompressionType compressionType}) {
    return _channel.invokeMethod('extractArchive', {
      'path': path,
      'dest': dest,
      'archiveFormat': archiveFormat.index,
      if (compressionType != null) ...{'compressionType': compressionType.index}
    });
  }

  Future<bool> createArchive(List<String> paths, String dest,
      String archiveName, ArchiveFormat archiveFormat,
      {CompressionType compressionType}) {
    return _channel.invokeMethod('createArchive', {
      'paths': paths,
      'dest': dest,
      'archiveName': archiveName,
      'archiveFormat': archiveFormat.index,
      if (compressionType != null) ...{'compressionType': compressionType.index}
    });
  }

  // Future<List> extractTarGzFeedSymLink(
  //     String tarPath, String dest, String linuxRootPath) {
  //   return _channel.invokeMethod('extractTarGz', {
  //     'source': tarPath,
  //     'dest': dest,
  //     'linuxRootPath': linuxRootPath,
  //   });
  // }
}

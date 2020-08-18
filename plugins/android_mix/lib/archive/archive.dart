import 'dart:convert';

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
    CompressLevel level = CompressLevel.normal,
    CompressMethod method = CompressMethod.deflate,
    EncryptionMethod encrypt = EncryptionMethod.standard,
    String pwd,
    Function(dynamic) onZip,
    Function onZipSuccess,
    Function onZipError,
    Function onZipCancel,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onZip':
          if (onZip != null)
            onZip(call.arguments != null ? json.decode(call.arguments) : null);
          break;
        case 'onZipSuccess':
          if (onZipSuccess != null) onZipSuccess();
          break;
        case 'onZipError':
          if (onZipError != null) onZipError();
          break;
        case 'onZipCancel':
          if (onZipCancel != null) onZipCancel();
          break;
        default:
          throw MissingPluginException();
      }
    });
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
    Function(dynamic) onUnZip,
    Function onUnZipSuccess,
    Function onUnZipError,
    Function onUnZipCancel,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onUnZip':
          if (onUnZip != null) onUnZip(call.arguments);
          break;
        case 'onUnZipSuccess':
          if (onUnZipSuccess != null) onUnZipSuccess();
          break;
        case 'onUnZipError':
          if (onUnZipError != null) onUnZipError();
          break;
        case 'onUnZipCancel':
          if (onUnZipCancel != null) onUnZipCancel();
          break;
        default:
          throw MissingPluginException();
      }
    });
    return _channel.invokeMethod('unzip', {
      'path': path,
      'targetPath': targetPath,
      'pwd': pwd,
    });
  }

  Future<void> tar(
    List<String> path,
    String targetPath, {
    Function(dynamic) onTar,
    Function onTarSuccess,
    Function onTarError,
    Function onTarCancel,
  }) async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onTar':
          if (onTar != null) onTar(call.arguments);
          break;
        case 'onTarSuccess':
          if (onTarSuccess != null) onTarSuccess();
          break;
        case 'onTarError':
          if (onTarError != null) onTarError();
          break;
        case 'onTarCancel':
          if (onTarCancel != null) onTarCancel();
          break;
        default:
          throw MissingPluginException();
      }
    });
    await _channel.invokeMethod('tar', {
      'path': path,
      'targetPath': targetPath,
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
}

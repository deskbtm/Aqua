import 'dart:io';
import 'body_parser/src/file.dart';
import 'util.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as pathLib;
import 'package:shelf/shelf.dart';

import 'directory_listing.dart';

final _defaultMimeTypeResolver = MimeTypeResolver();

Handler createDirHandler(
  String fileSystemPath, {
  bool serveFilesOutsidePath: true,
  bool listDirectories: true,
  MimeTypeResolver? contentTypeResolver,
  bool isDark = true,
  required String serverUrl,
  required String uploadSavePath,
  Function(bool)? onUploadResult,
}) {
  var rootDir = Directory(fileSystemPath);
  if (!rootDir.existsSync()) {
    throw ArgumentError('A directory corresponding to fileSystemPath '
        '"$fileSystemPath" could not be found');
  }

  fileSystemPath = rootDir.resolveSymbolicLinksSync();

  contentTypeResolver ??= _defaultMimeTypeResolver;

  return (Request request) async {
    String method = request.method;
    Uri url = request.url;

    switch (method) {
      case 'GET':
        {
          var segs = [fileSystemPath]..addAll(request.url.pathSegments);
          var fsPath = pathLib.joinAll(segs);
          var entityType = FileSystemEntity.typeSync(fsPath, followLinks: true);
          File? file;
          if (entityType == FileSystemEntityType.file) {
            file = File(fsPath);
          } else if (entityType == FileSystemEntityType.directory) {
            // file = _tryDefaultFile(fsPath, defaultDocument)!;

            if (file == null && listDirectories) {
              var uri = request.requestedUri;
              if (!uri.path.endsWith('/'))
                return _redirectToAddTrailingSlash(uri);
              return listDirectory(fileSystemPath, fsPath,
                  serverUrl: serverUrl, isDark: isDark);
            }
          }

          if (file == null) {
            return Response.notFound(
              jsonEncode({'msg': '访问失败', 'code': 0}),
            );
          }

          if (!serveFilesOutsidePath) {
            var resolvedPath = file.resolveSymbolicLinksSync();

            if (!pathLib.isWithin(fileSystemPath, resolvedPath)) {
              return Response.notFound(
                jsonEncode({'msg': '访问失败', 'code': 0}),
              );
            }
          }

          var uri = request.requestedUri;
          if (entityType == FileSystemEntityType.directory &&
              !uri.path.endsWith('/')) {
            return _redirectToAddTrailingSlash(uri);
          }

          return _handleFile(request, file, () async {
            return Future.value(contentTypeResolver?.lookup(file!.path));
          });
        }
        break;
      case 'POST':
        switch (url.toString()) {
          case 'upload_file':
            Map files = request.context['postFileParams'] as Map;
            try {
              await for (var item in Stream.fromIterable(files.values)) {
                FileParams pFile = item[0];
                if (pFile != null) {
                  File file =
                      File(pathLib.join(uploadSavePath, pFile.filename));
                  IOSink fileSink = file.openWrite();
                  await pFile.part.pipe(fileSink);
                  fileSink.close();
                  debugPrint('${pFile.filename} upload done');
                  if (onUploadResult != null) onUploadResult(true);
                  return Response.ok(
                    jsonEncode({'msg': '上传成功', 'code': 1}),
                    encoding: Utf8Codec(),
                    headers: {HttpHeaders.contentTypeHeader: 'text/html'},
                  );
                }
              }
            } catch (e) {
              if (onUploadResult != null) onUploadResult(false);
              return Response.notFound(
                jsonEncode({'msg': '上传失败 $e', 'code': 0}),
              );
            }
        }
        return Response.notFound(
          jsonEncode({'msg': '上传失败 ', 'code': 0}),
        );
        break;
      default:
        return Response.notFound(
          jsonEncode({'msg': '未找到http $method 方法', 'code': 0}),
        );
    }
  };
}

Response _redirectToAddTrailingSlash(Uri uri) {
  var location = Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.port,
    path: uri.path + '/',
    query: uri.query,
  );
  return Response.movedPermanently(location.toString());
}

File? _tryDefaultFile(String dirPath, String defaultFile) {
  if (defaultFile == null) return null;
  String filePath = pathLib.join(dirPath, defaultFile);
  File file = File(filePath);

  if (file.existsSync()) {
    return file;
  }

  return null;
}

Handler createFilesHandler(
  List<String> pathList, {
  bool isDark = true,
  required String serverUrl,
  MimeTypeResolver? contentTypeResolver,
  required String uploadSavePath,
  Function(bool)? onUploadResult,
}) {
  contentTypeResolver ??= _defaultMimeTypeResolver;
  return (request) async {
    var file = File(request.url.path);
    if (request.method == 'POST') {
      switch (request.url.toString()) {
        case 'upload_file':
          Map files = request.context['postFileParams'] as Map;
          try {
            await for (var item in Stream.fromIterable(files.values)) {
              FileParams? pFile = item[0];
              if (pFile != null) {
                File file = File(pathLib.join(uploadSavePath, pFile.filename));
                // file.writeAsBytes(await pFile.);
                IOSink fileSink = file.openWrite();
                await pFile.part.pipe(fileSink);
                fileSink.close();
                debugPrint('${pFile.filename} upload done');
                if (onUploadResult != null) onUploadResult(true);
                return Response.ok(
                  jsonEncode({'msg': '上传成功', 'code': 1}),
                  encoding: Utf8Codec(),
                  headers: {HttpHeaders.contentTypeHeader: 'text/html'},
                );
              }
            }
          } catch (e) {
            if (onUploadResult != null) onUploadResult(false);
            return Response.notFound(
              jsonEncode({'msg': '上传失败 $e', 'code': 0}),
            );
          }
      }
    }

    if (file.existsSync()) {
      return _handleFile(request, file, () async {
        return Future.value(contentTypeResolver?.lookup(file!.path));
      });
    }
    return listFiles(pathList, serverUrl: serverUrl, isDark: isDark);
  };
}

Future<Response> _handleFile(
    Request request, File file, FutureOr<String> getContentType()) async {
  var stat = file.statSync();
  var ifModifiedSince = request.ifModifiedSince;

  if (ifModifiedSince != null) {
    var fileChangeAtSecResolution = toSecondResolution(stat.changed);
    if (!fileChangeAtSecResolution.isAfter(ifModifiedSince)) {
      return Response.notModified();
    }
  }

  var headers = {
    HttpHeaders.contentLengthHeader: stat.size.toString(),
    HttpHeaders.lastModifiedHeader: formatHttpDate(stat.changed)
  };

  String contentType = await getContentType();
  // ignore: unnecessary_null_comparison
  if (contentType != null) headers[HttpHeaders.contentTypeHeader] = contentType;

  return Response.ok(file.openRead(), headers: headers);
}

// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

import 'directory_listing.dart';
import 'util.dart';

final _defaultMimeTypeResolver = new MimeTypeResolver();

Handler createWebHandler(
  String fileSystemPath, {
  bool serveFilesOutsidePath: true,
  String defaultDocument,
  bool listDirectories: true,
  MimeTypeResolver contentTypeResolver,
  bool isDark = true,
}) {
  var rootDir = new Directory(fileSystemPath);
  if (!rootDir.existsSync()) {
    throw new ArgumentError('A directory corresponding to fileSystemPath '
        '"$fileSystemPath" could not be found');
  }

  fileSystemPath = rootDir.resolveSymbolicLinksSync();

  contentTypeResolver ??= _defaultMimeTypeResolver;

  return (Request request) {
    String method = request.method;
    Uri url = request.url;

    switch (method) {
      case 'GET':
        {
          var segs = [fileSystemPath]..addAll(request.url.pathSegments);

          var fsPath = p.joinAll(segs);

          var entityType = FileSystemEntity.typeSync(fsPath, followLinks: true);

          File file;

          if (entityType == FileSystemEntityType.file) {
            file = new File(fsPath);
          } else if (entityType == FileSystemEntityType.directory) {
            file = _tryDefaultFile(fsPath, defaultDocument);
            if (file == null && listDirectories) {
              var uri = request.requestedUri;
              if (!uri.path.endsWith('/'))
                return _redirectToAddTrailingSlash(uri);
              return listDirectory(fileSystemPath, fsPath, isDark: isDark);
            }
          }

          if (file == null) {
            return new Response.notFound('Not Found');
          }

          if (!serveFilesOutsidePath) {
            var resolvedPath = file.resolveSymbolicLinksSync();

            // Do not serve a file outside of the original fileSystemPath
            if (!p.isWithin(fileSystemPath, resolvedPath)) {
              return new Response.notFound('Not Found');
            }
          }

          var uri = request.requestedUri;
          if (entityType == FileSystemEntityType.directory &&
              !uri.path.endsWith('/')) {
            return _redirectToAddTrailingSlash(uri);
          }

          return _handleFile(request, file, () async {
            return contentTypeResolver.lookup(file.path);
          });
        }
        break;
      case 'POST':
        switch (url.toString()) {
        }
        return Response.notFound('');
      default:
        return Response.notFound('');
    }
  };
}

Response _redirectToAddTrailingSlash(Uri uri) {
  var location = new Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.port,
      path: uri.path + '/',
      query: uri.query);

  return new Response.movedPermanently(location.toString());
}

File _tryDefaultFile(String dirPath, String defaultFile) {
  if (defaultFile == null) return null;

  var filePath = p.join(dirPath, defaultFile);

  var file = new File(filePath);

  // File.fromRawPath(rawPath)

  if (file.existsSync()) {
    return file;
  }

  return null;
}

/// Creates a shelf [Handler] that serves the file at [path].
///
/// This returns a 404 response for any requests whose [Request.url] doesn't
/// match [url]. The [url] defaults to the basename of [path].
///
/// This uses the given [contentType] for the Content-Type header. It defaults
/// to looking up a content type based on [path]'s file extension, and failing
/// that doesn't sent a [contentType] header at all.
Handler createFilesHandler(
  List<String> pathList, {
  String url,
  String contentType,
  bool isDark = true,
}) {
  // var file = new File();
  // if (!file.existsSync()) {
  //   throw new ArgumentError.value(path, 'path', 'does not exist.');
  // } else if (url != null && !p.url.isRelative(url)) {
  //   throw new ArgumentError.value(url, 'url', 'must be relative.');
  // }

  // contentType ??= _defaultMimeTypeResolver.lookup(path);
  // url ??= p.toUri(p.basename(path)).toString();

  return (request) {
    var file = new File(request.url.path);
    if (file.existsSync()) {
      return _handleFile(request, file, () => contentType);
    }
    return listFiles(pathList, isDark: isDark);
  };
}

/// Serves the contents of [file] in response to [request].
///
/// This handles caching, and sends a 304 Not Modified response if the request
/// indicates that it has the latest version of a file. Otherwise, it calls
/// [getContentType] and uses it to populate the Content-Type header.
Future<Response> _handleFile(
    Request request, File file, FutureOr<String> getContentType()) async {
  var stat = file.statSync();
  var ifModifiedSince = request.ifModifiedSince;

  if (ifModifiedSince != null) {
    var fileChangeAtSecResolution = toSecondResolution(stat.changed);
    if (!fileChangeAtSecResolution.isAfter(ifModifiedSince)) {
      return new Response.notModified();
    }
  }

  var headers = {
    HttpHeaders.contentLengthHeader: stat.size.toString(),
    HttpHeaders.lastModifiedHeader: formatHttpDate(stat.changed)
  };

  var contentType = await getContentType();
  if (contentType != null) headers[HttpHeaders.contentTypeHeader] = contentType;

  return new Response.ok(file.openRead(), headers: headers);
}

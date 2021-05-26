library body_parser;

import 'dart:core';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'buffer.dart';
import 'file.dart';
part 'body_parse_result.dart';

Future<BodyParseResult> parseBodyFromStream(
    Stream<List<int>> data, MediaType contentType, Uri requestUri,
    {bool storeOriginalBuffer = false}) async {
  Stream<List<int>> stream = data;

  Future<List<int>> getBytes() {
    return stream
        .fold<BytesBuilder>(BytesBuilder(copy: false),
            (BytesBuilder a, List<int> b) => a..add(b))
        .then((BytesBuilder b) => b.takeBytes());
  }

  var result = _BodyParseResultImpl();

  if (storeOriginalBuffer) {
    var bytes = await getBytes();
    result.originalBuffer = Buffer(bytes);
    var ctrl = StreamController<List<int>>()..add(bytes);
    stream = ctrl.stream;
    await ctrl.close();
  }

  Future<String> getBody() {
    return stream.transform(utf8.decoder).join();
  }

  try {
    if (requestUri.hasQuery) {
      result.query = Uri.splitQueryString(requestUri.query);
    }

    if (contentType != null) {
      if (contentType.type == 'multipart' &&
          contentType.parameters.containsKey('boundary')) {
        var parts = stream.transform(
            MimeMultipartTransformer(contentType.parameters['boundary']!));

        await for (MimeMultipart part in parts) {
          var header = HeaderValue.parse(part.headers['content-disposition']!);
          String name = header.parameters['name']!;

          String filename = header.parameters['filename']!;
          if (filename == null) {
            var list = result.postFileParams[name];
            if (list == null) {
              list = <String>[];
            }
            BytesBuilder builder = await part.fold(
                BytesBuilder(copy: false),
                (BytesBuilder b, List<int> d) =>
                    b..add(d is! String ? d : (d as String).codeUnits));
            list.add(utf8.decode(builder.takeBytes()));
            result.postFileParams[name] = list;
            continue;
          }
          var list = result.postFileParams[name];
          if (list == null) {
            list = <FileParams>[];
          }
          list.add(FileParams(
              mimeType: MediaType.parse(part.headers['content-type']!).mimeType,
              name: name,
              filename: filename,
              part: part));
          result.postFileParams[name] = list;
        }
      } else if (contentType.mimeType == 'application/json') {
        result.postParams
            .addAll(_foldToStringDynamic(json.decode(await getBody()) as Map)!);
      } else if (contentType.mimeType == 'application/x-www-form-urlencoded') {
        result.postParams = Uri.splitQueryString(await getBody());
      }
    }
  } catch (e, st) {
    result.error = e;
    result.stack = st;
  }
  return result;
}

class _BodyParseResultImpl implements BodyParseResult {
  @override
  Map<String, dynamic> postParams = {};

  @override
  Map<String, List<dynamic>> postFileParams = {};

  @override
  late Buffer originalBuffer;

  @override
  Map<String, dynamic> query = {};

  @override
  var error;

  @override
  late StackTrace stack;
}

Map<String, dynamic>? _foldToStringDynamic(Map? map) {
  return map == null
      ? null
      : map.keys.fold<Map<String, dynamic>>(
          <String, dynamic>{}, (out, k) => out..[k.toString()] = map[k]);
}

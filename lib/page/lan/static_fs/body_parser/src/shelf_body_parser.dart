import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:http_parser/http_parser.dart';
import 'body_parser.dart';

/// Creates a Shelf [Middleware] to parse body.
///
shelf.Middleware bodyParser({bool storeOriginalBuffer = false}) {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      var result = await parseBodyFromStream(
          request.read(),
          request.headers['content-type'] != null
              ? MediaType.parse(request.headers['content-type']!)
              // ignore: null_check_always_fails
              : null!,
          request.url,
          storeOriginalBuffer: storeOriginalBuffer);
      return Future.sync(() {
        return innerHandler(
          request.change(context: {
            'query': result.query,
            'postParams': result.postParams,
            'postFileParams': result.postFileParams,
            'originalBuffer': result.originalBuffer
          }),
        );
      }).then((shelf.Response response) {
        return response;
      }, onError: (error, StackTrace stackTrace) {
        throw error;
      });
    };
  };
}

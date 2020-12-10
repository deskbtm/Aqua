/// Support for doing something awesome.
///
/// More dartdocs go here.
library shelf_body_parser;

export 'src/shelf_body_parser.dart';
export 'src/buffer.dart';
export 'src/file.dart';

dynamic getParams(Map<String, dynamic> params, String key) {
  var value = params[key];
  if (value is List<dynamic>) return value[0];
  return value;
}

// TODO: Export any libraries intended for clients of this package.

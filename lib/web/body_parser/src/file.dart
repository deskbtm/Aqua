import 'package:mime/mime.dart';

/// Represents a file uploaded to the server.
class FileParams {
  /// The MIME type of the uploaded file.
  String mimeType;

  /// The name of the file field from the request.
  String name;

  /// The filename of the file.
  String filename;

  /// The bytes that make up this file.
  MimeMultipart part;

  FileParams(
      {String mimeType, String name, String filename, MimeMultipart part})
      : mimeType = mimeType,
        name = name,
        filename = filename,
        part = part;

  @override
  String toString() =>
      'filename:${this.filename} name:${this.name} mimeType:${this.mimeType}';
}

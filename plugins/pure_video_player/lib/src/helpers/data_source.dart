import 'dart:io';
import 'package:meta/meta.dart' show required;
import 'package:video_player/video_player.dart'
    show VideoFormat, DataSourceType, ClosedCaptionFile;

class DataSource {
  final File? file;
  final String? source, package;
  final DataSourceType? type;
  final VideoFormat? formatHint;
  final Future<ClosedCaptionFile>? closedCaptionFile; // for subtiles

  DataSource({
    this.file,
    this.source,
    required this.type,
    this.formatHint,
    this.package,
    this.closedCaptionFile,
  })  : assert(type != null),
        assert((type == DataSourceType.file && file != null) || source != null);

  DataSource copyWith({
    File? file,
    String? source,
    String? package,
    DataSourceType? type,
    VideoFormat? formatHint,
    Future<ClosedCaptionFile>? closedCaptionFile,
  }) {
    return DataSource(
      file: file ?? this.file,
      source: source ?? this.source,
      type: type ?? this.type,
      package: package ?? this.package,
      formatHint: formatHint ?? this.formatHint,
      closedCaptionFile: closedCaptionFile ?? this.closedCaptionFile,
    );
  }
}

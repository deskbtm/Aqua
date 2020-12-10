import 'package:json_annotation/json_annotation.dart';
part 'joystick_component_recorder.g.dart';

@JsonSerializable(nullable: false)
class JoystickComponentRecorder {
  final double scaleRate;
  final int rotateCount;
  final double x;
  final double y;
  final String type;
  final List<Map> mapper;
  final bool vibration;

  JoystickComponentRecorder({
    this.type,
    this.vibration = true,
    this.scaleRate = 1,
    this.rotateCount = 0,
    this.x = 0,
    this.y = 0,
    this.mapper = const [],
  });

  factory JoystickComponentRecorder.fromJson(Map<String, dynamic> json) =>
      _$JoystickComponentRecorderFromJson(json);

  Map<String, dynamic> toJson() => _$JoystickComponentRecorderToJson(this);
}

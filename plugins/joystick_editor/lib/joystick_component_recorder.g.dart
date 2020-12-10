// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'joystick_component_recorder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoystickComponentRecorder _$JoystickComponentRecorderFromJson(
    Map<String, dynamic> json) {
  return JoystickComponentRecorder(
    type: json['type'] as String,
    scaleRate: (json['scaleRate'] as num).toDouble(),
    rotateCount: json['rotateCount'] as int,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    mapper:
        (json['mapper'] as List).map((e) => e as Map<String, dynamic>).toList(),
  );
}

Map<String, dynamic> _$JoystickComponentRecorderToJson(
        JoystickComponentRecorder instance) =>
    <String, dynamic>{
      'scaleRate': instance.scaleRate,
      'rotateCount': instance.rotateCount,
      'x': instance.x,
      'y': instance.y,
      'type': instance.type,
      'mapper': instance.mapper,
    };

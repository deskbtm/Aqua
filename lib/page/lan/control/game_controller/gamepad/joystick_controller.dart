import 'dart:math' as _math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/circle_view.dart';

typedef JoystickDirectionCallback = void Function(
    double degrees, double distance);

class JoystickController extends StatelessWidget {
  final double size;
  final Color iconsColor;
  final Color backgroundColor;
  final Color innerCircleColor;
  final double opacity;
  final JoystickDirectionCallback onDirectionChanged;
  final Duration interval;
  final bool showArrows;

  JoystickController({
    this.size,
    this.iconsColor = Colors.white54,
    this.backgroundColor = Colors.transparent,
    this.innerCircleColor = Colors.red,
    this.opacity,
    this.onDirectionChanged,
    this.interval,
    this.showArrows = true,
  });

  @override
  Widget build(BuildContext context) {
    double actualSize = size != null
        ? size
        : _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;

    print('$actualSize ============');
    double innerCircleSize = actualSize / 2;
    Offset lastPosition = Offset(innerCircleSize, innerCircleSize);

    DateTime _callbackTimestamp;

    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          Widget joystick = Stack(
            children: <Widget>[
              CircleView.joystickCircle(
                actualSize,
                backgroundColor,
              ),
              Positioned(
                child: CircleView.joystickInnerCircle(
                  actualSize / 2,
                  innerCircleColor,
                ),
              ),
              // if (showArrows) ...createArrows(),
              OverflowBox(
                child: Container(
                  child: Column(children: [
                    Row(children: [Container(), Container()]),
                    Row(),
                  ]),
                ),
              )
            ],
          );

          return GestureDetector(
            onPanStart: (details) {},
            onPanEnd: (details) {},
            onPanUpdate: (details) {},
            child: (opacity != null)
                ? Opacity(opacity: opacity, child: joystick)
                : joystick,
          );
        },
      ),
    );
  }

  List<Widget> createArrows() {
    return [
      Positioned(
        child: Icon(
          Icons.keyboard_arrow_up,
          color: iconsColor,
        ),
        top: 16.0,
        left: 0.0,
        right: 0.0,
      ),
      Positioned(
        child: Icon(
          Icons.keyboard_arrow_left,
          color: iconsColor,
        ),
        top: 0.0,
        bottom: 0.0,
        left: 16.0,
      ),
      Positioned(
        child: Icon(
          Icons.keyboard_arrow_right,
          color: iconsColor,
        ),
        top: 0.0,
        bottom: 0.0,
        right: 16.0,
      ),
      Positioned(
        child: Icon(
          Icons.keyboard_arrow_down,
          color: iconsColor,
        ),
        bottom: 16.0,
        left: 0.0,
        right: 0.0,
      ),
    ];
  }
}

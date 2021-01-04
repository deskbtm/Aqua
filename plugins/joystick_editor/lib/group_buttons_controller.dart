import 'dart:collection';
import 'dart:math' as _math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joystick_editor/single_button_item.dart';
import 'package:joystick_editor/utils.dart';

import 'circle_view.dart';
import 'joystick_gestures.dart';

typedef GroupButtonPressedCallback = Future<void> Function(
    int buttonIndex, JoystickGestures gesture);

class GroupButtonsController extends StatelessWidget {
  final double minSize;
  final int rotate;
  final List<SingleButtonItem> buttons;
  final GroupButtonPressedCallback onGroupButtonPressed;
  final Map<int, Color> buttonsStateMap = HashMap<int, Color>();
  final double buttonsPadding;
  final Color backgroundPadButtonsColor;
  final bool withVibration;

  GroupButtonsController({
    this.minSize = 180,
    @required this.buttons,
    this.onGroupButtonPressed,
    this.buttonsPadding = 0,
    this.backgroundPadButtonsColor = Colors.transparent,
    this.rotate = 0,
    this.withVibration = true,
  }) : assert(buttons != null && buttons.isNotEmpty) {
    buttons.forEach(
        (button) => buttonsStateMap[button.index] = button.backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    double actualSize = minSize != null
        ? minSize
        : _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;
    double innerCircleSize = actualSize / 3;

    return Center(
      child: Stack(children: createButtons(innerCircleSize, actualSize)),
    );
  }

  List<Widget> createButtons(double innerCircleSize, double actualSize) {
    List<Widget> list = List();
    list.add(CircleView.padBackgroundCircle(
        actualSize,
        backgroundPadButtonsColor,
        backgroundPadButtonsColor != Colors.transparent
            ? Colors.black45
            : Colors.transparent,
        backgroundPadButtonsColor != Colors.transparent
            ? Colors.black12
            : Colors.transparent));

    for (var i = 0; i < buttons.length; i++) {
      var padButton = buttons[i];
      list.add(createPositionedButtons(
        padButton,
        actualSize,
        i,
        innerCircleSize,
      ));
    }
    return list;
  }

  Positioned createPositionedButtons(SingleButtonItem paddButton,
      double actualSize, int index, double innerCircleSize) {
    return Positioned(
      child: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () async {
              await _processGesture(paddButton, JoystickGestures.TAP);
            },
            onTapUp: (details) async {
              await _processGesture(paddButton, JoystickGestures.TAPUP);
              Future.delayed(const Duration(milliseconds: 50), () {
                setState(() => buttonsStateMap[paddButton.index] =
                    paddButton.backgroundColor);
              });
            },
            onTapDown: (details) async {
              await _processGesture(paddButton, JoystickGestures.TAPDOWN);

              setState(() =>
                  buttonsStateMap[paddButton.index] = paddButton.pressedColor);
            },
            onTapCancel: () async {
              await _processGesture(paddButton, JoystickGestures.TAPCANCEL);

              setState(() => buttonsStateMap[paddButton.index] =
                  paddButton.backgroundColor);
            },
            onLongPress: () async {
              await _processGesture(paddButton, JoystickGestures.LONGPRESS);
            },
            onLongPressStart: (details) async {
              await _processGesture(
                  paddButton, JoystickGestures.LONGPRESSSTART);

              setState(() =>
                  buttonsStateMap[paddButton.index] = paddButton.pressedColor);
            },
            onLongPressUp: () async {
              await _processGesture(paddButton, JoystickGestures.LONGPRESSUP);

              setState(() => buttonsStateMap[paddButton.index] =
                  paddButton.backgroundColor);
            },
            child: Padding(
              padding: EdgeInsets.all(buttonsPadding),
              child: CircleView.padButtonCircle(
                innerCircleSize,
                buttonsStateMap[paddButton.index],
                paddButton.buttonImage,
                paddButton.buttonIcon,
                paddButton.buttonText,
              ),
            ),
          );
        },
      ),
      top: _calculatePositionYOfButton(index, innerCircleSize, actualSize),
      left: _calculatePositionXOfButton(index, innerCircleSize, actualSize),
    );
  }

  Future<void> _processGesture(
      SingleButtonItem button, JoystickGestures gesture) async {
    if (onGroupButtonPressed != null &&
        button.supportedGestures.contains(gesture)) {
      print('${button.index} $gesture');
      if (withVibration) {
        await pressVibrate();
      }
      await onGroupButtonPressed(button.index, gesture);
      print("$gesture paddbutton id =  ${[button.index]}");
    }
  }

  double _calculatePositionXOfButton(
      int index, double innerCircleSize, double actualSize) {
    double degrees = 360 / buttons.length * index;
    double lastAngleRadians = (degrees) * (_math.pi / 180.0);

    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
  }

  double _calculatePositionYOfButton(
      int index, double innerCircleSize, double actualSize) {
    double degrees = 360 / buttons.length * index;
    double lastAngleRadians = (degrees) * (_math.pi / 180.0);
    var rBig = actualSize / 2;
    var rSmall = (innerCircleSize + 2 * buttonsPadding) / 2;

    return (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);
  }
}

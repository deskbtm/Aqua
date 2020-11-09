import 'dart:collection';
import 'dart:math' as _math;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/gamepad_gestures.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/pad_button_item.dart';

import 'circle_view.dart';

typedef GroupButtonPressedCallback = Future<void> Function(
    int buttonIndex, GamePadGestures gesture);

class GroupButtonsController extends StatelessWidget {
  final double size;
  final List<PadButtonItem> buttons;
  final GroupButtonPressedCallback groupButtonPressedCallback;
  final Map<int, Color> buttonsStateMap = HashMap<int, Color>();
  final double buttonsPadding;
  final Color backgroundPadButtonsColor;

  GroupButtonsController({
    this.size,
    @required this.buttons,
    this.groupButtonPressedCallback,
    this.buttonsPadding = 0,
    this.backgroundPadButtonsColor = Colors.transparent,
  }) : assert(buttons != null && buttons.isNotEmpty) {
    buttons.forEach(
        (button) => buttonsStateMap[button.index] = button.backgroundColor);
  }

  @override
  Widget build(BuildContext context) {
    double actualSize = size != null
        ? size
        : _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;
    double innerCircleSize = actualSize / 3;

    return Center(
        child: Stack(children: createButtons(innerCircleSize, actualSize)));
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

  Positioned createPositionedButtons(PadButtonItem paddButton,
      double actualSize, int index, double innerCircleSize) {
    return Positioned(
      child: StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () async {
              await _processGesture(paddButton, GamePadGestures.TAP);
            },
            onTapUp: (details) async {
              await _processGesture(paddButton, GamePadGestures.TAPUP);
              Future.delayed(const Duration(milliseconds: 50), () {
                setState(() => buttonsStateMap[paddButton.index] =
                    paddButton.backgroundColor);
              });
            },
            onTapDown: (details) async {
              await _processGesture(paddButton, GamePadGestures.TAPDOWN);

              setState(() =>
                  buttonsStateMap[paddButton.index] = paddButton.pressedColor);
            },
            onTapCancel: () async {
              await _processGesture(paddButton, GamePadGestures.TAPCANCEL);

              setState(() => buttonsStateMap[paddButton.index] =
                  paddButton.backgroundColor);
            },
            onLongPress: () async {
              await _processGesture(paddButton, GamePadGestures.LONGPRESS);
            },
            onLongPressStart: (details) async {
              await _processGesture(paddButton, GamePadGestures.LONGPRESSSTART);

              setState(() =>
                  buttonsStateMap[paddButton.index] = paddButton.pressedColor);
            },
            onLongPressUp: () async {
              await _processGesture(paddButton, GamePadGestures.LONGPRESSUP);

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
      PadButtonItem button, GamePadGestures gesture) async {
    if (GroupButtonPressedCallback != null &&
        button.supportedGestures.contains(gesture)) {
      await groupButtonPressedCallback(button.index, gesture);
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

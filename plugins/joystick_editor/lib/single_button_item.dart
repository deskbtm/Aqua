import 'dart:ui';

import 'package:flutter/material.dart';

import 'joystick_gestures.dart';

/// Model of one padd button.
class SingleButtonItem {
  /// [index] required parameter, the key to recognize button instance.
  final int index;

  /// [buttonText] optional parameter, the text to be displayed inside the
  /// button. Omitted if [buttonImage] is set. Default value is empty string.
  final Widget buttonText;

  /// [buttonImage] optional parameter, image which will be displayed inside
  /// the button.
  final Image buttonImage;

  /// [buttonIcon] optional parameter, image which will be displayed inside
  /// the button.
  final Icon buttonIcon;

  /// [backgroundColor] color of button in default state.
  final Color backgroundColor;

  /// [pressedColor] color of button when it is pressed.
  final Color pressedColor;

  /// [supportedGestures] optional parameter, list of gestures for button which
  /// will call the callback [PadButtonsView.padButtonPressedCallback].
  ///
  /// Default value is [JoystickGestures.TAP].
  final List<JoystickGestures> supportedGestures;

  const SingleButtonItem({
    @required this.index,
    this.buttonText,
    this.buttonImage,
    this.buttonIcon,
    this.backgroundColor = Colors.white54,
    this.pressedColor = Colors.lightBlueAccent,
    this.supportedGestures = const [JoystickGestures.TAP],
  }) : assert(index != null);
}

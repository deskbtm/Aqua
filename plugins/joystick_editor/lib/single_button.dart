import 'package:flutter/cupertino.dart';

import 'circle_view.dart';
import 'joystick_gestures.dart';

class SingleCircleButton extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final Color pressedColor;
  final Image buttonImage;
  final Icon buttonIcon;
  final Widget buttonText;
  final bool withVibration;
  final Function(JoystickGestures) singlePressedCallback;

  const SingleCircleButton({
    Key key,
    this.size,
    this.backgroundColor,
    this.buttonImage,
    this.buttonIcon,
    this.buttonText,
    this.withVibration,
    this.singlePressedCallback,
    this.pressedColor,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SingleCircleButtonState();
  }
}

class _SingleCircleButtonState extends State<SingleCircleButton> {
  Color _color;

  @override
  initState() {
    super.initState();
    _color = widget.backgroundColor;
  }

  Future<void> _processGesture(JoystickGestures gesture) async {
    if (widget.singlePressedCallback != null) {
      await widget.singlePressedCallback(gesture);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () async {
            await _processGesture(JoystickGestures.TAP);
          },
          onTapUp: (details) async {
            await _processGesture(JoystickGestures.TAPUP);
            Future.delayed(const Duration(milliseconds: 50), () {
              setState(() => _color = widget.backgroundColor);
            });
          },
          onTapDown: (details) async {
            await _processGesture(JoystickGestures.TAPDOWN);
            setState(() => _color = widget.pressedColor);
          },
          onTapCancel: () async {
            await _processGesture(JoystickGestures.TAPCANCEL);
            setState(() => _color = widget.backgroundColor);
          },
          onLongPress: () async {
            await _processGesture(JoystickGestures.LONGPRESS);
          },
          onLongPressStart: (details) async {
            await _processGesture(JoystickGestures.LONGPRESSSTART);
            setState(() => _color = widget.pressedColor);
          },
          onLongPressUp: () async {
            await _processGesture(JoystickGestures.LONGPRESSUP);
            setState(() => _color = widget.backgroundColor);
          },
          child: CircleView.padButtonCircle(
            widget.size,
            _color,
            widget.buttonImage,
            widget.buttonIcon,
            widget.buttonText,
          ),
        );
      },
    );
  }
}

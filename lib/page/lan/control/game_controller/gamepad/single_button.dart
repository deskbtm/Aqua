import 'package:flutter/cupertino.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/circle_view.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/gamepad_gestures.dart';

class SingleButton extends StatefulWidget {
  final double size;
  final Color color;
  final Image buttonImage;
  final Icon buttonIcon;
  final Widget buttonText;
  final bool withVibration;
  final Function(GamePadGestures) singlePressedCallback;

  const SingleButton(
      {Key key,
      this.size,
      this.color,
      this.buttonImage,
      this.buttonIcon,
      this.buttonText,
      this.withVibration,
      this.singlePressedCallback})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _SingleButtonState();
  }
}

class _SingleButtonState extends State<SingleButton> {
  Future<void> _processGesture(GamePadGestures gesture) async {
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
            await _processGesture(GamePadGestures.TAP);
          },
          onTapUp: (details) async {
            await _processGesture(GamePadGestures.TAPUP);
            Future.delayed(const Duration(milliseconds: 50), () {
              // setState(() => buttonsStateMap[paddButton.index] =
              //     paddButton.backgroundColor);
            });
          },
          onTapDown: (details) async {
            await _processGesture(GamePadGestures.TAPDOWN);

            // setState(() =>
            //     buttonsStateMap[paddButton.index] = paddButton.pressedColor);
          },
          onTapCancel: () async {
            await _processGesture(GamePadGestures.TAPCANCEL);

            // setState(() =>
            //     buttonsStateMap[paddButton.index] = paddButton.backgroundColor);
          },
          onLongPress: () async {
            await _processGesture(GamePadGestures.LONGPRESS);
          },
          onLongPressStart: (details) async {
            await _processGesture(GamePadGestures.LONGPRESSSTART);

            // setState(() =>
            //     buttonsStateMap[paddButton.index] = paddButton.pressedColor);
          },
          onLongPressUp: () async {
            await _processGesture(GamePadGestures.LONGPRESSUP);

            // setState(() =>
            // buttonsStateMap[paddButton.index] = paddButton.backgroundColor);
          },
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircleView.padButtonCircle(
              widget.size,
              widget.color,
              widget.buttonImage,
              widget.buttonIcon,
              widget.buttonText,
            ),
          ),
        );
      },
    );
  }
}

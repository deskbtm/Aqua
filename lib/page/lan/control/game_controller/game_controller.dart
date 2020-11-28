import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/page/lan/control/game_controller/component-editor.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/group_buttons_controller.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/joystick_controller.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/pad_button_item.dart';
import 'package:lan_file_more/page/lan/control/game_controller/gamepad/single_button.dart';

class GameControllerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GameControllerPageState();
  }
}

class _GameControllerPageState extends State<GameControllerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  double x = 0;
  double y = 0;
  Offset _offset = Offset(0, 0);
  double buttonSize = 200;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Stack(
          children: [
            // ComponentContainer(
            //   child: PadSingleButton(
            //     size: 50,
            //     buttonText: NoResizeText(
            //       "A",
            //       style: TextStyle(fontSize: 18),
            //     ),
            //   ),
            // ),

            JoystickController(
              size: 200,
              iconsColor: Colors.black45,
            ),
            ComponentEditor(
              editorMode: true,
              minSize: 240,
              onResize: (scale) {
                setState(() {
                  buttonSize = buttonSize * scale;
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: JoystickController(
                  size: buttonSize,
                  iconsColor: Colors.black45,
                  // size: 400,
                ),
              ),
            ),
            // ComponentEditor(
            //   editorMode: true,
            //   child: Container(
            //     padding: EdgeInsets.all(10),
            //     child: SingleButton(
            //       size: 50,
            //       buttonText: NoResizeText(
            //         "A",
            //         style: TextStyle(fontSize: 18),
            //       ),
            //     ),
            //   ),
            // ),
            SingleButton(
              size: 60,
              pressedColor: Colors.green,
              singlePressedCallback: (gesture) {
                print(gesture);
              },
              buttonText: NoResizeText(
                "B",
                style: TextStyle(fontSize: 18),
              ),
            ),
            ComponentEditor(
              editorMode: true,
              minSize: 80,
              onResize: (scale) {},
              child: SingleButton(
                pressedColor: Colors.green,
                singlePressedCallback: (gesture) {
                  print(gesture);
                },
                buttonText: NoResizeText(
                  "B",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            ComponentEditor(
              editorMode: true,
              minSize: 240,
              onResize: (scale) {
                print(scale);
              },
              child: Container(
                child: GroupButtonsController(
                  size: 210,
                  buttons: [
                    SingleButtonItem(
                      index: 0,
                      buttonText: NoResizeText(
                        "A",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SingleButtonItem(
                      index: 1,
                      pressedColor: Colors.red,
                      buttonText: NoResizeText(
                        "B",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SingleButtonItem(
                      index: 2,
                      pressedColor: Colors.green,
                      buttonText: NoResizeText(
                        "C",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    SingleButtonItem(
                      index: 3,
                      buttonText: NoResizeText(
                        "D",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

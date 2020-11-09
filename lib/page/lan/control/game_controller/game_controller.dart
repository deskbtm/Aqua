import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/page/lan/control/game_controller/component_container.dart';
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
            ResizebleWidget(
              editorMode: true,
              child: Container(
                padding: EdgeInsets.all(10),
                child: JoystickController(
                  iconsColor: Colors.black45,
                  // size: 400,
                ),
              ),
            ),
            ResizebleWidget(
              editorMode: true,
              child: Container(
                padding: EdgeInsets.all(10),
                child: SingleButton(
                  size: 50,
                  buttonText: NoResizeText(
                    "A",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            ResizebleWidget(
              editorMode: true,
              child: Container(
                padding: EdgeInsets.all(10),
                child: SingleButton(
                  size: 50,
                  buttonText: NoResizeText(
                    "B",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            ResizebleWidget(
              editorMode: true,
              child: Container(
                padding: EdgeInsets.all(10),
                child: GroupButtonsController(
                  buttons: [
                    PadButtonItem(
                      index: 0,
                      buttonText: NoResizeText(
                        "A",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    PadButtonItem(
                      index: 1,
                      pressedColor: Colors.red,
                      buttonText: NoResizeText(
                        "B",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    PadButtonItem(
                      index: 2,
                      pressedColor: Colors.green,
                      buttonText: NoResizeText(
                        "C",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    PadButtonItem(
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

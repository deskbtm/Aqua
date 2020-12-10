import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:joystick_editor/single_button_item.dart';

import 'group_buttons_controller.dart';
import 'joystick_component_editor.dart';
import 'joystick_component_recorder.dart';
import 'joystick_controller.dart';
import 'no_resize_text.dart';

class JoystickBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _JoystickBoardState();
  }
}

class _JoystickBoardState extends State<JoystickBoard> {
  bool _editMode = false;
  List<JoystickComponentRecorder> defaultCmpts;
  bool _locker;

  @override
  void initState() {
    super.initState();
    _locker = true;
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (_locker) {
      _locker = false;
      defaultCmpts = [
        JoystickComponentRecorder(
          type: 'joystick',
          scaleRate: 1,
          rotateCount: 3,
          x: 10,
          y: 40,
          mapper: [],
        ),
        JoystickComponentRecorder(
          type: 'group',
          scaleRate: 1,
          rotateCount: 3,
          x: 10,
          y: MediaQuery.of(context).size.height - 280,
          mapper: [
            {
              'text': 'A',
              'target': 'A',
              'index': 1,
            },
            {
              'text': 'B',
              'target': 'B',
              'index': 2,
            },
            {
              'text': 'C',
              'target': 'C',
              'index': 3,
            },
            {
              'text': 'D',
              'target': 'D',
              'index': 4,
            }
          ],
        ),
      ];
    }
  }

  List<Widget> createComponents() {
    return defaultCmpts.map<Widget>((e) {
      switch (e.type) {
        case 'joystick':
          return GameComponentEditor(
            editorSize: 200,
            isEdit: _editMode,
            top: e.y,
            left: e.x,
            scaleRate: e.scaleRate,
            rotateCount: e.rotateCount,
            child: JoystickController(
              size: 180,
              onDirectionChanged: (degree, distance) {
                log('$degree $distance');
              },
            ),
          );
        case 'group':
          return GameComponentEditor(
            editorSize: 200,
            isEdit: _editMode,
            top: e.y,
            left: e.x,
            scaleRate: 1,
            rotateCount: 3,
            child: GroupButtonsController(
              minSize: 180,
              onGroupButtonPressed: (index, gesture) async {  
                print(index);
                print(gesture);
              },
              buttons: e.mapper
                  .map(
                    (e) => SingleButtonItem(
                      index: e['index'],
                      buttonText: NoResizeText(
                        e['text'],
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        default:
          return null;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    log('$_editMode');
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              Row(
                children: [
                  CupertinoButton(
                    onPressed: () {},
                    child: Text('编辑'),
                  ),
                  CupertinoButton(
                    onPressed: () {},
                    child: Text('保存'),
                  ),
                ],
              ),
              ...createComponents(),
            ],
          ),
        ),
      ),
    );
  }
}

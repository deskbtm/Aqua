import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';

// ignore: must_be_immutable
class DoublePop extends StatelessWidget {
  Widget child;
  DateTime _lastPressedTime;
  DoublePop({this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (_lastPressedTime == null ||
            DateTime.now().difference(_lastPressedTime) >
                Duration(seconds: 1)) {
          _lastPressedTime = DateTime.now();
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: NoResizeText('demo')));
          return false;
        }
        exit(0);
        return false;
      },
    );
  }
}

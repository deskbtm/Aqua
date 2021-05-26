import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DoubleTapBack extends StatelessWidget {
  final Widget child;
  late DateTime _lastPressedTime;
  DoubleTapBack({required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (_lastPressedTime == null ||
            DateTime.now().difference(_lastPressedTime) >
                Duration(milliseconds: 500)) {
          _lastPressedTime = DateTime.now();

          return false;
        }
        return true;
      },
    );
  }
}

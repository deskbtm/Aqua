import 'package:flutter/material.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';

// ignore: must_be_immutable
class DoublePop extends StatelessWidget {
  final Widget child;
  final CommonModel commonModel;
  final ThemeModel themeModel;
  DateTime _lastPressedTime;
  DoublePop({
    this.child,
    this.commonModel,
    this.themeModel,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (commonModel.canPopToDesktop) {
          if (_lastPressedTime == null ||
              DateTime.now().difference(_lastPressedTime) >
                  Duration(milliseconds: 800)) {
            _lastPressedTime = DateTime.now();
            BotToast.showText(text: '再按一次退出');
            return false;
          }
          return true;
        } else {
          return false;
        }
      },
    );
  }
}

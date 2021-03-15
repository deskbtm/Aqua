import 'package:flutter/material.dart';
import 'package:aqua/external/bot_toast/bot_toast.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
            BotToast.showText(text: AppLocalizations.of(context).pressAgain);
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

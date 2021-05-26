import 'package:flutter/material.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class DoublePop extends StatelessWidget {
  final Widget child;
  final CommonModel commonModel;
  final ThemeModel themeModel;
  late DateTime _lastPressedTime;
  DoublePop({
    required this.child,
    required this.commonModel,
    required this.themeModel,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (commonModel.canPopToDesktop) {
          // ignore: unnecessary_null_comparison
          if (_lastPressedTime == null ||
              DateTime.now().difference(_lastPressedTime) >
                  Duration(milliseconds: 800)) {
            _lastPressedTime = DateTime.now();
            Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.pressAgain,
            );

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

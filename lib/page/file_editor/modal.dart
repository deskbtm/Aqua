import 'dart:async';
import 'dart:ui';

import 'package:aqua/common/widget/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dialog.dart';

class CoverCupertinoModalPopupRoute<T> extends PopupRoute<T> {
  CoverCupertinoModalPopupRoute({
    this.barrierColor,
    this.barrierLabel,
    this.builder,
    bool semanticsDismissible,
    ImageFilter filter,
    RouteSettings settings,
  }) : super(
          filter: filter,
          settings: settings,
        ) {
    _semanticsDismissible = semanticsDismissible;
  }

  final WidgetBuilder builder;
  bool _semanticsDismissible;

  @override
  final String barrierLabel;

  @override
  final Color barrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => _semanticsDismissible ?? false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 0);

  Animation<double> _animation;

  Tween<Offset> _offsetTween;

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    _animation = CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: const Offset(0.0, 0.0),
    );
    return _animation;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: builder),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation),
        child: child,
      ),
    );
  }
}

Future<T> showCupertinoModal<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  @required ImageFilter filter,
  bool useRootNavigator = true,
  bool semanticsDismissible,
  bool transparent = false,
}) {
  assert(useRootNavigator != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    CoverCupertinoModalPopupRoute<T>(
      barrierColor: transparent
          ? Color(0x00382F2F)
          : CupertinoDynamicColor.resolve(
              CupertinoDynamicColor.withBrightness(
                color: Color(0x33000000),
                darkColor: Color(0x7A000000),
              ),
              context,
            ),
      barrierLabel: 'Dismiss',
      builder: builder,
      filter: filter,
      semanticsDismissible: semanticsDismissible,
    ),
  );
}

Future<dynamic> showTextFieldModal(
  BuildContext context, {
  bool popPreviousWindow = false,
  String title = '',
  String tip,
  String placeholder,
  String initText,
  @required FutureOr Function(String) onOk,
  @required FutureOr Function() onCancel,
  bool transparent = false,
  String defaultCancelText,
  Color itemFontColor,
  Color dialogBgColor,
}) async {
  if (popPreviousWindow) Navigator.pop(context);

  TextEditingController textEditingController = TextEditingController();

  if (initText != null) textEditingController.text = initText;

  return showCupertinoModal(
    context: context,
    transparent: transparent,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            fontColor: itemFontColor,
            bgColor: dialogBgColor,
            title: LanDialogTitle(title: title),
            action: true,
            children: <Widget>[
              if (tip != null) ...[
                Text(tip, textScaleFactor: 1),
                SizedBox(height: 10),
              ],
              AquaTextField(
                controller: textEditingController,
                placeholder: placeholder,
              ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              await onOk(textEditingController.text);
            },
            onCancel: () async {
              await onCancel();
              Navigator.pop(context);
            },
            defaultCancelText: defaultCancelText,
          );
        },
      );
    },
  );
}

Future<dynamic> showSelectModal(
  BuildContext context, {
  bool popPreviousWindow = false,
  String title = '',
  String subTitle = '',
  List<dynamic> options,
  bool transparent = false,
  String defaultOkText,
  String defaultCancelText,
  bool action = false,
  Function(int) onSelected,
  Function onOk,
  Function onCancel,
  Function(BuildContext) doAction,
  List<Widget> leadingList,
  Color itemFontColor,
  Color dialogBgColor,
  Color selectItemColor,
}) async {
  if (popPreviousWindow) Navigator.of(context);

  List<dynamic> tmpOptions = options;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: itemFontColor,
            bgColor: dialogBgColor,
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                Text(title, textScaleFactor: 1),
                SizedBox(width: 5),
                Text(
                  subTitle,
                  style: TextStyle(fontSize: 10),
                  textScaleFactor: 1,
                ),
              ],
            ),
            action: action,
            children: [
              if (leadingList != null) ...leadingList,
              Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2),
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (onSelected != null) onSelected(index);
                        },
                        child: tmpOptions[index] is String
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                  color: selectItemColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                margin: EdgeInsets.only(top: 4, bottom: 4),
                                child: Text(
                                  tmpOptions[index],
                                  style: TextStyle(
                                      fontSize: 16, color: itemFontColor),
                                  textScaleFactor: 1,
                                ),
                              )
                            : tmpOptions[index],
                      ),
                    );
                  },
                  itemCount: tmpOptions?.length,
                ),
              )
            ],
            defaultOkText: defaultOkText,
            defaultCancelText: defaultCancelText,
            onOk: () async {
              await onOk();
              Navigator.pop(context);
            },
            onCancel: () {
              onCancel();
              Navigator.pop(context);
            },
          );
        },
      );
    },
  );
}

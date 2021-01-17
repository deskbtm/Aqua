import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/dialog.dart';
import 'package:lan_file_more/common/widget/loading_flipping.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/text_field.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SplitSelectionModal extends StatefulWidget {
  final List<Widget> leftChildren;
  final List<Widget> rightChildren;
  final Widget topPanel;
  final bool isChangeView;
  // final Function onDispose;
  final topFlex;
  final bottomFlex;

  const SplitSelectionModal({
    Key key,
    this.leftChildren = const [],
    this.rightChildren = const [],
    this.isChangeView,
    this.topPanel,
    // this.onDispose,
    this.topFlex = 1,
    this.bottomFlex = 3,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplitSelectionModalState();
  }
}

class SplitSelectionModalState extends State<SplitSelectionModal> {
  List<Widget> _leftChildren;
  List<Widget> _rightChildren;
  insertLeftCol(List<Widget> children) {
    if (mounted) {
      setState(() {
        _leftChildren = children;
      });
    }
  }

  insertRightCol(List<Widget> children) {
    if (mounted) {
      setState(() {
        _rightChildren = children;
      });
    }
  }

  pushLeft(Widget item) {
    if (mounted) {
      setState(() {
        _leftChildren.add(item);
      });
    }
  }

  pushRight(Widget item) {
    if (mounted) {
      setState(() {
        _rightChildren.add(item);
      });
    }
  }

  replaceRight(int index, Widget item) {
    if (mounted) {
      setState(() {
        _leftChildren.replaceRange(index, index + 1, [item]);
      });
    }
  }

  replaceLeft(int index, List<Widget> items) {
    if (mounted) {
      setState(() {
        _leftChildren.replaceRange(index, index + 1, items);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _leftChildren = widget.leftChildren;
    _rightChildren = widget.rightChildren;
  }

  @override
  Widget build(BuildContext context) {
    Widget colListView(List<Widget> children) => Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: 1,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: children,
              );
            },
          ),
        );

    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: widget.topFlex,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: widget.topPanel == null ? Container() : widget.topPanel,
            ),
          ),
          Expanded(
            flex: widget.bottomFlex,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                colListView(_leftChildren),
                colListView(_rightChildren)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showForceScopeModal(
  BuildContext context,
  ThemeModel provider, {
  String title = '',
  String tip = '',
  @required Function onOk,
  Function onCancel,
  bool transparent = false,
  String defaultOkText,
  String defaultCancelText,
  List<Widget> additionList,
  bool withOk = true,
  bool withCancel = true,
}) async {
  MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;
  bool popAble = false;

  return showCupertinoModal(
    context: context,
    // semanticsDismissible: true,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return WillPopScope(
            onWillPop: () async {
              return popAble;
            },
            child: LanDialog(
              fontColor: themeData.itemFontColor,
              bgColor: themeData.dialogBgColor,
              title: NoResizeText(title),
              action: true,
              children: <Widget>[
                SizedBox(height: 10),
                NoResizeText(tip),
                ...?additionList,
                SizedBox(height: 10),
              ],
              withCancel: withCancel,
              withOk: withOk,
              defaultOkText: defaultOkText,
              onOk: () async {
                changeState(() {
                  popAble = true;
                });
                MixUtils.safePop(context);
                onOk();
              },
              defaultCancelText: defaultCancelText,
              onCancel: () {
                changeState(() {
                  popAble = true;
                });
                MixUtils.safePop(context);
                if (onCancel != null) onCancel();
              },
              actionPos: MainAxisAlignment.end,
            ),
          );
        },
      );
    },
  );
}

class CupertinoModalPopupRoute<T> extends PopupRoute<T> {
  CupertinoModalPopupRoute({
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
    CupertinoModalPopupRoute<T>(
      barrierColor: transparent
          ? Color(0x00382F2F)
          : CupertinoDynamicColor.resolve(
              CupertinoDynamicColor.withBrightness(
                color: Color(0x17000000),
                darkColor: Color(0x33000000),
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

Future<dynamic> showSingleTextFieldModal(
  BuildContext context,
  ThemeModel provider, {
  bool popPreviousWindow = false,
  String title = '',
  String tip,
  String placeholder,
  String initText,
  @required FutureOr Function(String) onOk,
  @required FutureOr Function() onCancel,
  bool transparent = false,
  String defaultCancelText,
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;
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
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: LanDialogTitle(title: title),
            action: true,
            children: <Widget>[
              if (tip != null) ...[
                NoResizeText(tip),
                SizedBox(height: 10),
              ],
              LanTextField(
                controller: textEditingController,
                placeholder: placeholder,
              ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              await onOk(textEditingController.text?.trim());
              MixUtils.safePop(context);
            },
            onCancel: () async {
              await onCancel();
              MixUtils.safePop(context);
            },
            defaultCancelText: defaultCancelText,
          );
        },
      );
    },
  );
}

Future<dynamic> showTwoTextFieldModal(
  BuildContext context,
  ThemeModel provider, {
  bool popPreviousWindow = false,
  String title = '',
  String fPlaceholder,
  String sPlaceholder,
  @required Function(String, String) onOk,
  Function onCancel,
  bool transparent = false,
  String defaultCancelText,
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;
  TextEditingController fEditingController = TextEditingController();
  TextEditingController sEditingController = TextEditingController();

  return showCupertinoModal(
    context: context,
    transparent: transparent,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: LanDialogTitle(title: title),
            action: true,
            children: <Widget>[
              SizedBox(
                height: 30,
                child: LanTextField(
                  style: TextStyle(fontSize: 16),
                  controller: fEditingController,
                  placeholder: fPlaceholder,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 32,
                child: LanTextField(
                  style: TextStyle(fontSize: 16),
                  controller: sEditingController,
                  placeholder: sPlaceholder,
                  maxLines: 1,
                ),
              ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              onOk(fEditingController.text, sEditingController.text);
              await MixUtils.safePop(context);
            },
            onCancel: () async {
              if (onCancel != null) onCancel();
              await MixUtils.safePop(context);
            },
            defaultCancelText: defaultCancelText,
          );
        },
      );
    },
  );
}

/// 展示提示文字
Future<dynamic> showTipTextModal(
  BuildContext context,
  ThemeModel provider, {
  bool popPreviousWindow = false,
  String title = '',
  String tip = '',
  Widget confirmedView,
  Function onOk,
  Function onCancel,
  bool transparent = false,
  String defaultOkText,
  String defaultCancelText,
  List<Widget> additionList,
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;
  bool confirm = false;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: NoResizeText(title),
            action: true,
            children: <Widget>[
              confirmedView != null
                  ? (confirm ? confirmedView : NoResizeText(tip))
                  : NoResizeText(tip),
              SizedBox(height: 10),
              if (additionList != null) ...additionList
            ],
            defaultOkText: defaultOkText,
            defaultCancelText: defaultCancelText,
            onOk: () async {
              if (confirmedView != null) {
                if (confirm) {
                  return;
                }
                changeState(() {
                  confirm = true;
                });
              }
              if (onOk != null) {
                await onOk();
              }
              MixUtils.safePop(context);
            },
            onCancel: () {
              if (onCancel != null) {
                onCancel();
              }
              MixUtils.safePop(context);
            },
          );
        },
      );
    },
  );
}

Future<dynamic> showSelectModal(
  BuildContext context,
  ThemeModel provider, {
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
  Function(int, List<dynamic> tmp) onLongPressDeleteItem,
  List<Widget> leadingList,
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;
  if (doAction != null) doAction(context);
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
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              children: <Widget>[
                NoResizeText(title),
                SizedBox(width: 5),
                NoResizeText(
                  subTitle,
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
            action: action,
            children: [
              if (leadingList != null) ...leadingList,
              ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (onSelected != null) onSelected(index);
                      },
                      onLongPress: () {
                        tmpOptions.removeAt(index);
                        if (onLongPressDeleteItem != null) {
                          onLongPressDeleteItem(index, tmpOptions);
                        }
                        changeState(() {});
                      },
                      child: tmpOptions[index] is String
                          ? Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 8, bottom: 8),
                              decoration: BoxDecoration(
                                color: themeData.itemColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              margin: EdgeInsets.only(top: 4, bottom: 4),
                              child: NoResizeText(
                                tmpOptions[index],
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : tmpOptions[index],
                    ),
                  );
                },
                itemCount: tmpOptions?.length,
              )
            ],
            defaultOkText: defaultOkText,
            defaultCancelText: defaultCancelText,
            onOk: () async {
              await onOk();
              MixUtils.safePop(context);
            },
            onCancel: () {
              onCancel();
              MixUtils.safePop(context);
            },
          );
        },
      );
    },
  );
}

Future<dynamic> showLoadingModal(
  BuildContext context,
  ThemeModel provider, {
  bool popPreviousWindow = false,
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            children: [
              Center(
                child: LoadingDoubleFlipping.square(
                  size: 30,
                  backgroundColor: Color(0xFF007AFF),
                ),
              )
            ],
          );
        },
      );
    },
  );
}

Future<dynamic> showQrcodeModal(
  BuildContext context,
  String data,
  ThemeModel provider, {
  bool popPreviousWindow = false,
  String title = '扫描二维码',
}) async {
  if (popPreviousWindow) MixUtils.safePop(context);
  LanFileMoreTheme themeData = provider.themeData;

  return showCupertinoModal(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) changeState) {
          return LanDialog(
            actionPos: MainAxisAlignment.end,
            fontColor: themeData.itemFontColor,
            bgColor: themeData.dialogBgColor,
            title: LanDialogTitle(title: title),
            action: false,
            children: [
              Center(
                child: QrImage(
                  data: data,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        LanText(data, small: true),
                        SizedBox(height: 10),
                        LanText('地址已经复制到剪贴板'),
                      ],
                    )
                  ],
                ),
              )
            ],
          );
        },
      );
    },
  );
}

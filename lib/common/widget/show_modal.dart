import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/dialog.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/text_field.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';

class SplitSelectionModal extends StatefulWidget {
  final List<Widget> leftChildren;
  final List<Widget> rightChildren;
  final Widget topPanel;
  final bool isChangeView;
  final Function onDispose;

  const SplitSelectionModal({
    Key key,
    this.leftChildren = const [],
    this.rightChildren = const [],
    this.isChangeView,
    this.topPanel,
    this.onDispose,
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
  void dispose() {
    super.dispose();
    if (widget.onDispose != null) widget.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: widget.topPanel == null ? Container() : widget.topPanel,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _leftChildren,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _rightChildren,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showBlurModal(BuildContext context, {Widget child}) {
  showCupertinoModalPopup(
    context: context,
    // filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: child,
      );
    },
  );
}

void showBlurSelectionModal(BuildContext context,
    {List<Widget> children = const [], bool left = true, Key key}) {
  showCupertinoModalPopup(
    context: context,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, state) {
        return SplitSelectionModal(
          key: key,
          leftChildren: left ? children : [],
          rightChildren: left ? [] : children,
        );
      });
    },
  );
}

Future<void> loadingModal(
  BuildContext context, {
  String title = '',
  @required ThemeProvider provider,
  Function onCancel,
}) async {
  MixUtils.safePop(context);
  dynamic themeData = provider.themeData;
  bool popAble = false;

  showCupertinoModal(
    context: context,
    semanticsDismissible: true,
    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
    builder: (BuildContext context) {
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
            CupertinoTheme(
              data: CupertinoTheme.of(context).copyWith(
                  brightness:
                      provider.isDark ? Brightness.dark : Brightness.light),
              child: CupertinoActivityIndicator(),
            ),
            SizedBox(height: 10),
          ],
          defaultOkText: '',
          onCancel: () {
            popAble = true;
            MixUtils.safePop(context);
            if (onCancel != null) onCancel();
          },
          actionPos: MainAxisAlignment.end,
        ),
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

      // These curves were initially measured from native iOS horizontal page
      // route animations and seemed to be a good match here as well.
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
  ImageFilter filter,
  bool useRootNavigator = true,
  bool semanticsDismissible,
  bool transparent = false,
}) {
  assert(useRootNavigator != null);
  return Navigator.of(context, rootNavigator: useRootNavigator).push(
    CupertinoModalPopupRoute<T>(
      barrierColor: transparent
          ? Color(0x00FFFFFF)
          : CupertinoDynamicColor.resolve(
              CupertinoDynamicColor.withBrightness(
                color: Color(0x33000000),
                darkColor: Color(0x7A000000),
              ),
              context,
            ),
      barrierLabel: 'Dismiss',
      builder: builder,
      filter: filter ?? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      semanticsDismissible: semanticsDismissible,
    ),
  );
}

Future<dynamic> showSingleTextModal(
  BuildContext context,
  ThemeProvider provider, {
  bool left = false,
  bool popPreWindow = false,
  String title = '',
  @required Function(String) onOk,
  @required Function onCancel,
  bool transparent = false,
}) async {
  if (popPreWindow) MixUtils.safePop(context);
  dynamic themeData = provider.themeData;
  TextEditingController textEditingController = TextEditingController();

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
              LanTextField(
                controller: textEditingController,
              ),
              SizedBox(height: 10),
            ],
            onOk: () async {
              MixUtils.safePop(context);
              onOk(textEditingController.text);
            },
            onCancel: () async {
              MixUtils.safePop(context);
              onCancel();
            },
          );
        },
      );
    },
  );
}

library focused_menu;

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'modal.dart';

class FocusedMenuItem {
  Color backgroundColor;
  Widget title;
  Icon trailingIcon;
  final Function onPressed;
  final String value;

  FocusedMenuItem({
    this.value,
    this.backgroundColor,
    @required this.title,
    this.trailingIcon,
    @required this.onPressed,
  });
}

class FocusedMenuHolder extends StatefulWidget {
  final Widget child;
  final double menuItemExtent;
  final double menuWidth;
  final List<FocusedMenuItem> menuItems;
  final bool animateMenuItems;
  final BoxDecoration menuBoxDecoration;
  // final Function(int, String) onPressed;
  final Duration duration;
  final double blurSize;
  final Color maskColor;
  final double bottomOffsetHeight;
  final double menuY;
  final double menuX;

  // 兼容 CupertinoTabBar
  final Widget icon;

  final Widget activeIcon;

  final Widget title;

  final Color backgroundColor;

  const FocusedMenuHolder({
    Key key,
    @required this.child,
    // @required this.onPressed,
    @required this.menuItems,
    this.duration,
    this.menuBoxDecoration,
    this.menuItemExtent,
    this.animateMenuItems,
    this.blurSize,
    this.maskColor,
    this.menuWidth,
    this.bottomOffsetHeight,
    this.menuY,
    this.icon,
    this.activeIcon,
    this.title,
    this.backgroundColor,
    this.menuX,
  }) : super(key: key);

  @override
  _FocusedMenuHolderState createState() => _FocusedMenuHolderState();
}

class _FocusedMenuHolderState extends State<FocusedMenuHolder> {
  GlobalKey containerKey = GlobalKey();
  Offset childOffset = Offset(0, 0);
  Size childSize;

  getOffset() {
    RenderBox renderBox = containerKey.currentContext.findRenderObject();
    Size size = renderBox.size;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    setState(() {
      this.childOffset = Offset(offset.dx, offset.dy);
      childSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: containerKey,
      onTap: () async {
        getOffset();
        await Navigator.of(context, rootNavigator: true).push(
          CoverCupertinoModalPopupRoute(
            barrierColor: widget.maskColor ??
                CupertinoDynamicColor.resolve(
                  CupertinoDynamicColor.withBrightness(
                    color: Color(0x33000000),
                    darkColor: Color(0x7A000000),
                  ),
                  context,
                ),
            barrierLabel: 'Dismiss',
            builder: (context) {
              return FocusedMenuDetails(
                itemExtent: widget.menuItemExtent,
                menuBoxDecoration: widget.menuBoxDecoration,
                child: widget.child,
                childOffset: childOffset,
                childSize: childSize,
                menuItems: widget.menuItems,
                menuWidth: widget.menuWidth,
                animateMenu: widget.animateMenuItems ?? true,
                bottomOffsetHeight: widget.bottomOffsetHeight ?? 0,
                menuY: widget.menuY ?? 0,
                menuX: widget.menuX ?? 0,
              );
            },
            semanticsDismissible: null,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class FocusedMenuDetails extends StatelessWidget {
  final List<FocusedMenuItem> menuItems;
  final BoxDecoration menuBoxDecoration;
  final Offset childOffset;
  final double itemExtent;
  final Size childSize;
  final Widget child;
  final bool animateMenu;

  final double menuWidth;

  final double bottomOffsetHeight;
  final double menuY;
  final double menuX;

  const FocusedMenuDetails(
      {Key key,
      @required this.menuItems,
      @required this.child,
      @required this.childOffset,
      @required this.childSize,
      @required this.menuBoxDecoration,
      @required this.itemExtent,
      @required this.animateMenu,
      @required this.menuWidth,
      this.bottomOffsetHeight,
      this.menuY,
      this.menuX})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final maxMenuHeight = size.height * 0.45;
    final listHeight = menuItems.length * (itemExtent ?? 50.0);

    final maxMenuWidth = menuWidth ?? (size.width * 0.70);
    final menuHeight = listHeight < maxMenuHeight ? listHeight : maxMenuHeight;
    final leftOffset = (childOffset.dx + maxMenuWidth) < size.width
        ? childOffset.dx + menuX
        : (childOffset.dx - maxMenuWidth + childSize.width - menuX);
    final topOffset = (childOffset.dy + menuHeight + childSize.height) <
            size.height - bottomOffsetHeight
        ? childOffset.dy + childSize.height + menuY
        : childOffset.dy - menuHeight - menuY;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Positioned(
              top: topOffset,
              left: leftOffset,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 200),
                builder: (BuildContext context, value, Widget iChild) {
                  return Transform.scale(
                    scale: value,
                    alignment: Alignment.center,
                    child: iChild,
                  );
                },
                tween: Tween(begin: 0.0, end: 1.0),
                child: Container(
                  width: maxMenuWidth,
                  height: menuHeight,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    child: ListView.builder(
                      itemCount: menuItems.length,
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        FocusedMenuItem item = menuItems[index];
                        Widget listItem = GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            // 不能放在前面会阻塞
                            item.onPressed();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            color: item.backgroundColor ?? Color(0xDEFFFFFF),
                            height: itemExtent ?? 50.0,
                            margin: EdgeInsets.only(bottom: 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  item.title,
                                  if (item.trailingIcon != null) ...[
                                    item.trailingIcon
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                        if (animateMenu) {
                          return TweenAnimationBuilder(
                              builder: (context, value, iChild) {
                                return Transform(
                                  transform: Matrix4.rotationX(1.5708 * value),
                                  alignment: Alignment.bottomCenter,
                                  child: iChild,
                                );
                              },
                              tween: Tween(begin: 1.0, end: 0.0),
                              duration: Duration(milliseconds: index * 200),
                              child: listItem);
                        } else {
                          return listItem;
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

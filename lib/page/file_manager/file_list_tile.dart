///[f]
import 'dart:ui';

import 'package:aqua/common/widget/marquee.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/model/select_file_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';

enum FileListTileType { folder, file }

/// 单个文件项组件
class SimpleFileListTile extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? leadingTitle;
  late final Widget? leading;
  late final Widget? trailing;
  final VoidCallback? onTap;

  final bool justDisplay;
  final bool selected;
  final Color selectedBackgroundColor;
  final Color? backgroundColor;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final void Function(DragEndDetails)? onHorizontalDragEnd;
  final void Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final void Function(DragDownDetails)? onHorizontalDragDown;
  final void Function(DragStartDetails)? onLongPressStartDetails;
  final TextStyle? titleStyle;
  final double? height;

  SimpleFileListTile({
    this.leading,
    this.onTap,
    this.onLongPressStart,
    this.onHorizontalDragEnd,
    this.justDisplay = false,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragDown,
    this.selected = false,
    this.selectedBackgroundColor = const Color(0xE10E78E9),
    this.backgroundColor,
    this.title,
    this.leadingTitle,
    this.trailing,
    this.subTitle,
    this.titleStyle,
    this.height = 72,
    this.onLongPressStartDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        onLongPressStart: justDisplay ? null : onLongPressStart,
        onHorizontalDragEnd: justDisplay ? null : onHorizontalDragEnd,
        onHorizontalDragUpdate: justDisplay ? null : onHorizontalDragUpdate,
        onHorizontalDragDown: justDisplay ? null : onHorizontalDragDown,
        onHorizontalDragStart: justDisplay ? null : onLongPressStartDetails,
        child: Container(
          height: height,
          padding: EdgeInsets.only(
            left: 12,
            right: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: selected ? selectedBackgroundColor : backgroundColor,
          ),
          margin: EdgeInsets.only(left: 4, right: 4, bottom: 3, top: 3),
          child: Row(
            children: [
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Container(
                            child: leading,
                            width: 35,
                            height: 35,
                          ),
                          if (leadingTitle != null)
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: ThemedText(
                                leadingTitle!,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          if (title != null)
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.only(top: 4),
                                alignment: Alignment.topLeft,
                                child: NotificationListener(
                                  onNotification:
                                      (ScrollNotification notification) {
                                    return true;
                                  },
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      final width =
                                          constraints.constrainWidth();

                                      return Marquee(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        ancestorWidth: width,
                                        pauseAfterRound: Duration(seconds: 10),
                                        textScaleFactor: 1,
                                        blankSpace: 30,
                                        style: TextStyle(fontSize: 13)
                                            .merge(titleStyle),
                                        text: title!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          if (subTitle != null)
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 14),
                                    // alignment: Alignment.topLeft,
                                    child: ThemedText(subTitle!, fontSize: 8),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              if (trailing != null)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [trailing!],
                )
            ],
          ),
        ),
      ),
    );
  }
}

class FileListTile extends StatefulWidget {
  final int index;
  final String? subTitle;
  final String? title;
  final VoidCallback? onTap;

  final String path;

  /// 只有部分listtile会有动画
  final bool withAnimation;

  /// 仅仅作为展示没有任何动作事件
  final bool justDisplay;

  final double? subTitleSize;
  final double? titleSize;
  final TextStyle? titleStyle;

  final String? leadingTitle;
  final Function(LongPressStartDetails)? onLongPressStart;

  /// 水平滑动第一个参数为滑动方向 1为右 -1为左
  final Function(double)? onItemHozDrag;

  final Widget? leading;

  final Widget? trailing;
  final double? height;

  const FileListTile({
    Key? key,
    required this.index,
    this.onTap,
    this.title,
    this.onItemHozDrag,
    this.onLongPressStart,
    this.titleSize = 12,
    this.subTitleSize = 7,
    this.justDisplay = false,
    this.withAnimation = false,
    this.leading,
    this.subTitle,
    this.leadingTitle,
    this.trailing,
    this.titleStyle,
    this.height,
    required this.path,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FileListTileState();
  }
}

class FileListTileState extends State<FileListTile>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late Animation<Offset> _animation;
  AnimationController? _controller;
  double _dragX = 0;
  bool _selected = false;
  late ThemeModel _tm;
  late FileManagerModel _fm;
  late SelectFileModel _selectFileModel;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    if (!widget.justDisplay) {
      _controller = AnimationController(vsync: this);
      _controller!.addListener(() {
        setState(() {
          _dragX = _animation.value.dx;
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);

    // 允许在此处添加，在父级组件添加会导致不会从最小节点开始更新，导致性能优化失败
    // 别处调用时可以使用 Provider.of<SelectFileModel>(context, listen: false)
    _selectFileModel = Provider.of<SelectFileModel>(context);

    _fm = Provider.of<FileManagerModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _handleHorizontalDragEnd(DragEndDetails details) async {
    Offset per = details.velocity.pixelsPerSecond;

    _animation = _controller!.drive(
      Tween(
        begin: Offset(_dragX, 0),
        end: Offset(0, 0),
      ),
    );

    const spring = SpringDescription(mass: 30.0, stiffness: 1.0, damping: 1.0);

    final simulation = SpringSimulation(spring, 0, 1, per.dx);
    _controller!.animateWith(simulation);

    if (widget.onItemHozDrag != null) {
      await widget.onItemHozDrag!(_dragX > 0 ? 1 : -1);
    }
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) async {
    setState(() {
      _dragX += details.delta.dx;
    });
  }

  void _handleHorizontalDragDown(DragDownDetails details) async {
    _controller?.stop();
  }

  /// 创建可拖拽移动文件项，具有弹簧效果
  Widget _createMoveableItem() {
    AquaTheme theme = _tm.themeData;

    // 判断文件是否被选中
    if (_fm.visitMode == FileManagerMode.pick) {
      _selected = _selectFileModel.hasPickedFile(widget.path)!;
    } else {
      _selected = _selectFileModel.hasSelectedFile(widget.path)!;
    }

    return Transform.translate(
      offset: Offset(_dragX, 0),
      child: SimpleFileListTile(
        selected: _selected,
        leading: widget.leading,
        leadingTitle: widget.leadingTitle,
        titleStyle: widget.titleStyle,
        trailing: widget.trailing,
        title: widget.title,
        subTitle: widget.subTitle,
        backgroundColor: theme.listTileColor,
        height: widget.height,
        onTap: widget.onTap,
        onLongPressStart: widget.onLongPressStart,
        onHorizontalDragDown: _handleHorizontalDragDown,
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget movableItem = _createMoveableItem();

    return widget.withAnimation
        ? AnimationConfiguration.staggeredList(
            position: widget.index,
            duration: const Duration(milliseconds: 100),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: movableItem,
              ),
            ),
          )
        : movableItem;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_manager.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

enum FileItemType { folder, file }

class FileItem extends StatefulWidget {
  final String subTitle;
  final int index;
  final Function() onTap;
  final Color itemBgColor;
  final Color fontColor;
  final bool withAnimation;
  final String path;
  final String filename;
  final bool justDisplay;
  final double subTitleSize;
  final double titleSize;
  final bool autoWrap;
  final Function(LongPressStartDetails) onLongPress;
  final Function(double) onHozDrag;
  final FileItemType type;
  final Widget leading;
  final FileManagerMode mode;

  /// -1 向右

  const FileItem({
    Key key,
    this.index,
    this.onTap,
    this.subTitle,
    this.fontColor,
    this.onHozDrag,
    this.itemBgColor,
    this.onLongPress,
    this.titleSize = 12,
    this.subTitleSize = 7,
    this.autoWrap = true,
    this.justDisplay = false,
    this.withAnimation = false,
    @required this.filename,
    @required this.leading,
    @required this.path,
    @required this.type,
    this.mode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FileItemState();
  }
}

class FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String get subTitle => widget.subTitle;
  Animation<Offset> _animation;
  AnimationController _controller;
  double _dragX = 0;
  bool _selected = false;
  double dir;

  int get index => widget.index;
  String get path => widget.path;
  Function() get onTap => widget.onTap;
  Color get itemBgColor => widget.itemBgColor;
  Color get fontColor => widget.fontColor;
  bool get withAnimation => widget.withAnimation;
  Function get onHozDrag => widget.onHozDrag;
  Function(
    LongPressStartDetails,
  ) get onLongPress => widget.onLongPress;

  FileItemType get type => widget.type;
  bool get justDisplay => widget.justDisplay;
  String get filename => widget.filename;
  double get subTitleSize => widget.subTitleSize;
  double get titleSize => widget.titleSize;
  bool get autoWrap => widget.autoWrap;

  ThemeModel _themeModel;
  CommonModel _commonModel;

  Widget _cacheLeading;
  String _cachePath;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!justDisplay) {
      _controller = AnimationController(vsync: this);
      _controller.addListener(() {
        setState(() {
          _dragX = _animation.value.dx;
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    // 每次渲染的时候就判断下
    // if (!justDisplay) {
    //   if (mounted) {
    //     log(path +
    //         '-----------' +
    //         _commonModel.hasSelectedFile(path).toString());
    //     setState(() {
    //       _selected = _commonModel.hasSelectedFile(path);
    //     });
    //   }
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    LanFileMoreTheme themeData = _themeModel?.themeData;
    Color itemfontColor = fontColor ?? themeData?.itemFontColor;
    Color itemColor = itemBgColor ?? themeData?.itemColor;

    /// [优化点]
    if (widget.justDisplay) {
      _selected = false;
    } else {
      if (widget.mode == FileManagerMode.pick) {
        _selected = _commonModel.hasPickFile(path);
      } else {
        _selected = _commonModel.hasSelectedFile(path);
      }
    }

    if (_cachePath != widget.path) {
      _cacheLeading = widget.leading;
      _cachePath = widget.path;
    }

    Widget tile = ListTile(
      leading: _cacheLeading,
      title: NoResizeText(
        filename,
        overflow: autoWrap
            ? filename.length > 30
                ? TextOverflow.ellipsis
                : null
            : null,
        style: TextStyle(fontSize: titleSize, color: itemfontColor),
      ),
      subtitle: NoResizeText(
        subTitle,
        style: TextStyle(fontSize: subTitleSize, color: itemfontColor),
      ),
      trailing: FileItemType.folder == type
          ? Icon(Icons.arrow_right, size: 16, color: itemfontColor)
          : null,
    );

    Widget folderInstance = Transform.translate(
      offset: Offset(_dragX, 0),
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8, bottom: 5, top: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: _selected ? Color(0xE10E78E9) : itemColor,
          ),
          // constraints: BoxConstraints(maxHeight: 76),
          child: justDisplay
              ? tile
              : GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap(
                          /* (b) {
                        if (mounted) {
                          setState(() {
                            _selected = b;
                          });
                        }
                      } */
                          );
                    }
                  },
                  onLongPressStart: (d) {
                    if (onLongPress != null) {
                      onLongPress(
                        d, /* (b) {
                        if (mounted) {
                          setState(() {
                            _selected = b;
                          });
                        }
                      } */
                      );
                    }
                  },
                  onHorizontalDragDown: (details) {
                    _controller.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta > 0) {
                      dir = 1;
                    } else {
                      dir = -1;
                    }

                    setState(() {
                      _dragX += details.delta.dx;
                    });
                  },
                  // onHorizontalDragStart: ,
                  onHorizontalDragEnd: (DragEndDetails details) async {
                    Offset per = details.velocity.pixelsPerSecond;

                    _animation = _controller.drive(
                      Tween(
                        begin: Offset(_dragX, 0),
                        end: Offset(0, 0),
                      ),
                    );

                    const spring = SpringDescription(
                        mass: 30.0, stiffness: 1.0, damping: 1.0);

                    final simulation = SpringSimulation(spring, 0, 1, per.dx);
                    _controller.animateWith(simulation);

                    //  水平滑动事件
                    if (onHozDrag != null) {
                      if (mounted) {
                        // 等待执行完成再更新 否则可能出现installed_apps 中 onHozDrag 异步没执行好
                        // setState 就执行的情况
                        await onHozDrag(dir);
                        // setState(() {
                        //   _selected = _commonModel.hasSelectedFile(path);
                        // });
                      }
                    }
                  },
                  child: tile,
                ),
        ),
      ),
    );

    return withAnimation
        ? AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 100),
            child: SlideAnimation(
              horizontalOffset: 50,
              child: FadeInAnimation(
                child: folderInstance,
              ),
            ),
          )
        : folderInstance;
  }
}

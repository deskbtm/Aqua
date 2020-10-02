import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/model/share.dart';
import 'package:lan_express/model/theme.dart';
import 'package:provider/provider.dart';

enum FileItemType { folder, file }

class FileItem extends StatefulWidget {
  final String subTitle;
  final int index;
  final Function onTap;
  final Color itemBgColor;
  final Color fontColor;
  final bool withAnimation;
  final String path;
  final String filename;
  final bool justDisplay;
  final double subTitleSize;
  final double titleSize;
  final bool autoWrap;

  /// -1 向右
  final Function(double) onHozDrag;
  final Function(LongPressStartDetails) onLongPress;
  final Widget leading;
  final FileItemType type;

  const FileItem({
    Key key,
    this.subTitle,
    this.index,
    this.onTap,
    this.itemBgColor,
    this.fontColor,
    this.withAnimation = false,
    this.onHozDrag,
    this.onLongPress,
    @required this.leading,
    @required this.type,
    this.justDisplay = false,
    @required this.path,
    @required this.filename,
    this.subTitleSize = 7,
    this.titleSize = 12,
    this.autoWrap = true,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FileItemState();
  }
}

class FileItemState extends State<FileItem>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  String get subTitle => widget.subTitle;
  Animation<Offset> _animation;
  AnimationController _controller;
  double _dragX = 0;
  bool _selected = false;
  double dir;

  int get index => widget.index;
  String get path => widget.path;
  Function get onTap => widget.onTap;
  Color get itemBgColor => widget.itemBgColor;
  Color get fontColor => widget.fontColor;
  bool get withAnimation => widget.withAnimation;
  Function get onHozDrag => widget.onHozDrag;
  FileItemType get type => widget.type;
  bool get justDisplay => widget.justDisplay;
  String get filename => widget.filename;
  double get subTitleSize => widget.subTitleSize;
  double get titleSize => widget.titleSize;
  bool get autoWrap => widget.autoWrap;

  ThemeProvider _themeProvider;
  ShareProvider _shareProvider;

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
    _themeProvider = Provider.of<ThemeProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    if (!justDisplay) {
      if (mounted) {
        setState(() {
          _selected = _shareProvider.has(path);
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void selectItem() {
    setState(() {
      _selected = true;
    });
  }

  void cancelSelectItem() {
    setState(() {
      _selected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    dynamic themeData = _themeProvider?.themeData;
    Color itemfontColor = fontColor ?? themeData?.itemFontColor;
    Color itemColor = itemBgColor ?? themeData?.itemColor;

    Widget tile = ListTile(
      leading: widget.leading,
      title: NoResizeText(
        filename,
        overflow: autoWrap
            ? filename.length > 30 ? TextOverflow.ellipsis : null
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
                  onTap: onTap,
                  onHorizontalDragDown: (details) {
                    _controller.stop();
                  },
                  onLongPressStart: widget.onLongPress,
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
                  onHorizontalDragEnd: (DragEndDetails details) {
                    Offset per = details.velocity.pixelsPerSecond;

                    _animation = _controller.drive(
                      Tween(
                        begin: Offset(_dragX, 0),
                        end: Offset(0, 0),
                      ),
                    );

                    const spring =
                        SpringDescription(mass: 30, stiffness: 1, damping: 1);

                    final simulation = SpringSimulation(spring, 0, 1, per.dx);
                    _controller.animateWith(simulation);

                    //  水平滑动事件
                    if (onHozDrag != null) {
                      if (mounted) {
                        onHozDrag(dir);
                        _shareProvider.has(path)
                            ? selectItem()
                            : cancelSelectItem();
                      }
                    }
                  },
                  child: tile),
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

  @override
  bool get wantKeepAlive => true;
}

// #ebebeb7d

//flag

import 'package:aqua/common/widget/custom_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';

import 'cache_file_info.dart';
import 'file_utils.dart';

enum FileItemType { folder, file }

class FileItem extends StatefulWidget {
  final int index;
  final String? subTitle;
  final VoidCallback? onTap;
  final Color? itemBgColor;
  final Color? fontColor;
  final bool withAnimation;
  final SelfFileEntity file;
  final bool justDisplay;
  final double? subTitleSize;
  final double? titleSize;
  final bool autoWrap;
  final Function(LongPressStartDetails)? onLongPress;
  final Function(double)? onHozDrag;
  final bool isDir;
  final Widget? leading;
  final FileManagerMode? mode;

  /// -1 向右

  const FileItem({
    Key? key,
    required this.index,
    this.onTap,
    this.fontColor,
    this.onHozDrag,
    this.itemBgColor,
    this.onLongPress,
    this.titleSize = 12,
    this.subTitleSize = 7,
    this.autoWrap = true,
    this.justDisplay = false,
    this.withAnimation = false,
    required this.leading,
    required this.isDir,
    this.mode,
    required this.file,
    this.subTitle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FileItemState();
  }
}

class FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late Animation<Offset> _animation;
  AnimationController? _controller;
  double _dragX = 0;
  bool _selected = false;
  late double _dir;

  SelfFileEntity get file => widget.file;
  int get index => widget.index;
  VoidCallback? get onTap => widget.onTap;
  Color? get itemBgColor => widget.itemBgColor;
  Color? get fontColor => widget.fontColor;
  bool get withAnimation => widget.withAnimation;
  Function? get onHozDrag => widget.onHozDrag;
  Function(LongPressStartDetails)? get onLongPress => widget.onLongPress;

  bool get justDisplay => widget.justDisplay;
  double? get subTitleSize => widget.subTitleSize;
  double? get titleSize => widget.titleSize;
  bool get autoWrap => widget.autoWrap;

  late ThemeModel _themeModel;
  late CommonModel _commonModel;
  late CacheFileInfo _cacheFileInfo;

  @override
  bool get wantKeepAlive => true;

  bool compareFile() {
    return _cacheFileInfo.path == file.path &&
        _cacheFileInfo.modified == MixUtils.formatFileTime(file.modified) &&
        _cacheFileInfo.size == file.humanSize;
  }

  @override
  void initState() {
    super.initState();
    _cacheFileInfo = CacheFileInfo();

    if (!justDisplay) {
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
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    AquaTheme themeData = _themeModel.themeData;
    Color itemfontColor = fontColor ?? themeData.itemFontColor;
    Color itemColor = itemBgColor ?? themeData.itemColor;

    /// [优化点]
    if (widget.justDisplay) {
      _selected = false;
    } else {
      if (widget.mode == FileManagerMode.pick) {
        _selected = _commonModel.hasPickFile(file.path)!;
      } else {
        _selected = _commonModel.hasSelectedFile(file.path)!;
      }
    }

    if (!compareFile()) {
      _cacheFileInfo = CacheFileInfo(
        path: file.path,
        modified: MixUtils.formatFileTime(file.modified),
        size: file.humanSize,
        leading: widget.leading,
        filename: file.filename,
      );
    }

    // ListTile();

    Widget tile = CustomListTile(
      leading: widget.isDir
          ? _cacheFileInfo.leading
          // 显示文件的大小
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _cacheFileInfo.leading!,
                SizedBox(height: 6),
                NoResizeText(
                  _cacheFileInfo.size!,
                  style: TextStyle(
                    fontSize: 8,
                    color: themeData.itemFontColor,
                  ),
                )
              ],
            ),
      title: NoResizeText(
        _cacheFileInfo.filename!,
        overflow: autoWrap
            ? _cacheFileInfo.filename!.length > 30
                ? TextOverflow.ellipsis
                : null
            : null,
        style: TextStyle(fontSize: titleSize, color: itemfontColor),
      ),
      subtitle: NoResizeText(
        widget.subTitle != null ? widget.subTitle! : _cacheFileInfo.modified!,
        style: TextStyle(fontSize: subTitleSize, color: itemfontColor),
      ),
      trailing: widget.isDir
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
                      onTap!();
                    }
                  },
                  onLongPressStart: (d) {
                    if (onLongPress != null) {
                      onLongPress!(d);
                    }
                  },
                  onHorizontalDragDown: (details) {
                    _controller?.stop();
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.primaryDelta is double &&
                        details.primaryDelta! > 0) {
                      _dir = 1;
                    } else {
                      _dir = -1;
                    }
                    setState(() {
                      _dragX += details.delta.dx;
                    });
                  },
                  // onHorizontalDragStart: ,
                  onHorizontalDragEnd: (DragEndDetails details) async {
                    Offset per = details.velocity.pixelsPerSecond;

                    _animation = _controller!.drive(
                      Tween(
                        begin: Offset(_dragX, 0),
                        end: Offset(0, 0),
                      ),
                    );

                    const spring = SpringDescription(
                        mass: 30.0, stiffness: 1.0, damping: 1.0);

                    final simulation = SpringSimulation(spring, 0, 1, per.dx);
                    _controller!.animateWith(simulation);

                    //  水平滑动事件
                    if (onHozDrag != null) {
                      if (mounted) {
                        // 等待执行完成再更新 否则可能出现installed_apps 中 onHozDrag 异步没执行好
                        // setState 就执行的情况
                        await onHozDrag!(_dir);
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

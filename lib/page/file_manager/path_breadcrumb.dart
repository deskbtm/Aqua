import 'dart:io';
import 'package:aqua/common/theme.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/external/breadcrumb/flutter_breadcrumb.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathLib;
import 'package:provider/provider.dart';

import 'package:unicons/unicons.dart';

class PathBreadCrumb extends StatefulWidget {
  final Function(Directory) onTap;
  PathBreadCrumb({Key? key, required this.onTap}) : super(key: key);

  @override
  _PathBreadCrumbState createState() => _PathBreadCrumbState();
}

class _PathBreadCrumbState extends State<PathBreadCrumb> {
  late ScrollController _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FileManagerModel fmModel =
        Provider.of<FileManagerModel>(context, listen: false);

    if (fmModel.currentDir == null || fmModel.entryDir == null) {
      return Container();
    }

    ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
    AquaTheme themeData = themeModel.themeData;

    String currentPath = fmModel.currentDir!.path;
    List<String> paths = pathLib
        .split(pathLib.relative(currentPath, from: fmModel.entryDir!.path));

    // RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }

    /// 如果相对路径第一个值替换成'/' ， 没有 '.' 则添加一个
    if (paths.first == '.') {
      paths[0] = '/';
    } else {
      paths.insert(0, '/');
    }

    return Container(
      padding: EdgeInsets.only(right: 15),
      child: Wrap(
        children: [
          BreadCrumb.builder(
            itemCount: paths.length,
            overflow: ScrollableOverflow(
              keepLastDivider: false,
              reverse: false,
              direction: Axis.horizontal,
              controller: _scrollController,
            ),
            builder: (index) {
              List list = paths.getRange(0, index + 1).toList();

              /// 删除 '/'
              list.remove('/');
              String absPath =
                  pathLib.joinAll([fmModel.entryDir!.path, ...list]);
              Directory target = Directory(absPath);

              return BreadCrumbItem(
                content: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onTap(target);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(top: 3, bottom: 3, right: 4, left: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: themeData.listTileColor,
                      ),
                      constraints: BoxConstraints(maxWidth: 100),
                      child: NoResizeText(
                        paths[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: themeData.itemFontColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            },
            divider: Icon(UniconsSolid.angle_right),
          ),
        ],
      ),
    );
  }
}

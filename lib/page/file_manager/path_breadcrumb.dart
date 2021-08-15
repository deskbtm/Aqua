import 'dart:io';
import 'package:aqua/common/theme.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/external/breadcrumb/flutter_breadcrumb.dart';
import 'package:aqua/model/associate_view_model.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/model/independent_view_model.dart';
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
  late ThemeModel _tm;
  late FileManagerModel _fm;
  late AssociateViewModel _avm;
  late IndependentViewModel _ivm;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = ScrollController();
    _tm = Provider.of<ThemeModel>(context);
    _avm = Provider.of<AssociateViewModel>(context);
    _ivm = Provider.of<IndependentViewModel>(context);
    _fm = Provider.of<FileManagerModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  AquaTheme get themeData => _tm.themeData;

  @override
  Widget build(BuildContext context) {
    String currentPath;
    if (_fm.entryDir == null) {
      return Container();
    }
    switch (_fm.viewMode) {
      case ViewMode.associate:
        if (_avm.currentDir == null) {
          return Container();
        }
        currentPath = _avm.currentDir!.path;
        break;
      case ViewMode.independent:
        if (_ivm.activeWindow == IndependentActiveWindow.first) {
          if (_ivm.firstCurrentDir == null) {
            return Container();
          }
          currentPath = _ivm.firstCurrentDir!.path;
        } else {
          if (_ivm.secondCurrentDir == null) {
            return Container();
          }
          currentPath = _ivm.secondCurrentDir!.path;
        }

        break;
      default:
        throw Exception('unkown view mode');
    }

    List<String> paths =
        pathLib.split(pathLib.relative(currentPath, from: _fm.entryDir!.path));

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
              String absPath = pathLib.joinAll([_fm.entryDir!.path, ...list]);
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

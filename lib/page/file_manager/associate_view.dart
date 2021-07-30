import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';

import 'fs_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/external/menu/menu.dart';
import 'package:aqua/page/file_manager/search_bar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/file_list.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:aqua/page/file_manager/path_breadcrumb.dart';
import 'package:path/path.dart' as pathLib;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssociateView extends StatefulWidget {
  final String? appointPath;
  final Widget Function(BuildContext)? trailingBuilder;
  final int? selectLimit;
  final FileManagerMode? mode;
  final GlobalKey<InnerDrawerState>? innerDrawerKey;

  const AssociateView({
    Key? key,
    this.appointPath,
    this.selectLimit = 1,
    this.trailingBuilder,
    this.mode = FileManagerMode.normal,
    this.innerDrawerKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return Associatetate();
  }
}

class Associatetate extends State<AssociateView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late ThemeModel _themeModel;
  late GlobalModel _globalModel;
  late FileManagerModel _fmModel;

  // late Directory? _rootDir;
  late bool _initMutex;
  // late

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _initMutex = true;

    WidgetsBinding.instance?.addObserver(this);
    BackButtonInterceptor.add(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
    _fmModel = Provider.of<FileManagerModel>(context);

    await _fmModel
        .setFirstList(context, _fmModel.entryDir!, update: true)
        .then((value) {
      _fmModel.setCurrentDir(_fmModel.entryDir!);
    });
  }

  LayoutMode getLayoutMode() {
    return _fmModel.layoutMode;
  }

  /// 拦截返回
  Future<bool> _willPopFileRoute(
      bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    if (_fmModel.isRelativeParentRoot) {
      _fmModel.setSecondListDirectly(context, null, update: true);
      _fmModel.setCurrentDir(_fmModel.currentDir!.parent);
      return false;
    }

    if (_fmModel.isRelativeRoot) {
      return false;
    }

    if (!_fmModel.isRelativeRoot &&
        !pathLib.isWithin(_fmModel.entryDir!.path, _fmModel.currentDir!.path)) {
      await _fmModel.setFirstList(context, _fmModel.entryDir!, update: true);
      return false;
    }

    _fmModel.setCurrentDir(_fmModel.currentDir!.parent);
    await _fmModel.setFirstList(context, _fmModel.currentDir!.parent);
    await _fmModel.setSecondList(context, _fmModel.currentDir!, update: true);

    return false;
  }

  List<Widget> _createAssociateList() {
    return <Widget>[
      Expanded(
        flex: 1,
        child: FileList(
          first: true,
          selectLimit: widget.selectLimit,
          mode: widget.mode!,
          onChangePopLocker: (val) {},
          list: _fmModel.firstList,
          onChangeCurrentDir: (dynamic a) {},
          onDirTileTap: (SelfFileEntity dir) async {
            await _fmModel
                .setSecondList(context, dir.entity as Directory, update: true)
                .then((value) {
              _fmModel.setCurrentDir(dir.entity as Directory);
            });
          },
        ),
      ),
      if (!_fmModel.isRelativeRoot && _fmModel.secondList != null) ...[
        if (getLayoutMode() == LayoutMode.vertical)
          Divider(color: Color(0xFF7BC4FF)),
        Expanded(
          flex: 1,
          child: FileList(
            first: false,
            selectLimit: widget.selectLimit,
            mode: widget.mode!,
            onChangeCurrentDir: (dynamic a) {},
            onChangePopLocker: (val) {},
            list: _fmModel.secondList,
            onDirTileTap: (dir) async {
              await _fmModel
                  .setSecondList(context, dir.entity as Directory)
                  .then((value) async {
                _fmModel.setCurrentDir(dir.entity as Directory);
                await _fmModel.setFirstList(context, dir.entity.parent,
                    update: true);
              });
            },
          ),
        ),
      ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Column(
        children: [
          SearchBar(),
          Expanded(
            child: getLayoutMode() == LayoutMode.vertical
                ? Column(children: _createAssociateList())
                : Row(children: _createAssociateList()),
          ),
        ],
      ),
    );
  }
}

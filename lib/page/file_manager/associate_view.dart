import 'dart:io';
import 'dart:ui';
import 'dart:developer';
import 'package:aqua/model/associate_view_model.dart';
import 'fs_utils.dart';
import 'package:aqua/model/global_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/file_list.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;

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
    return AssociateViewState();
  }
}

class AssociateViewState extends State<AssociateView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late FileManagerModel _fm;
  late AssociateViewModel _avm;
  late GlobalModel _gm;
  late bool _initMutex;

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
  dispose() {
    super.dispose();
    BackButtonInterceptor.remove(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    _fm = Provider.of<FileManagerModel>(context);
    _avm = Provider.of<AssociateViewModel>(context);
    _gm = Provider.of<GlobalModel>(context);

    if (_initMutex) {
      _initMutex = false;
      await _avm.setFirstList(context, getEntryDir!, update: true).then((_) {
        _avm.setCurrentDir(getEntryDir!);
      });
    }
  }

  LayoutMode get getLayoutMode => _fm.layoutMode;

  Directory? get getEntryDir => _fm.entryDir;

  Directory? get getCurrentDir => _avm.currentDir;

  bool get isRelativeRoot =>
      pathLib.equals(getEntryDir!.path, getCurrentDir!.path);

  bool get isRelativeParentRoot =>
      pathLib.equals(getEntryDir!.path, getCurrentDir!.parent.path);

  /// 拦截返回
  Future<bool> _willPopFileRoute(
      bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    if (isRelativeParentRoot) {
      _avm.setSecondListDirectly(context, null, update: true);
      _avm.setCurrentDir(_avm.currentDir!.parent);
      return false;
    }

    if (isRelativeRoot) {
      return false;
    }

    if (!isRelativeRoot &&
        !pathLib.isWithin(getEntryDir!.path, getCurrentDir!.path)) {
      await _avm.setFirstList(context, getEntryDir!, update: true);
      return false;
    }

    _avm.setCurrentDir(_avm.currentDir!.parent);
    await _avm.setFirstList(context, getCurrentDir!.parent);
    await _avm.setSecondList(context, getCurrentDir!, update: true);

    return false;
  }

  List<Widget> _createAssociateList() {
    return <Widget>[
      Expanded(
        flex: 1,
        child: FileList(
          first: true,
          selectLimit: widget.selectLimit,
          onChangePopLocker: (val) {},
          list: _avm.firstList,
          onDirTileTap: (SelfFileEntity dir) async {
            await _avm
                .setSecondList(context, dir.entity as Directory, update: true)
                .then((value) {
              _avm.setCurrentDir(dir.entity as Directory);
            });
          },
        ),
      ),
      if (!isRelativeRoot && _avm.secondList != null) ...[
        if (getLayoutMode == LayoutMode.vertical)
          Divider(color: Color(0xFF7BC4FF)),
        Expanded(
          flex: 1,
          child: FileList(
            first: false,
            selectLimit: widget.selectLimit,
            onChangePopLocker: (val) {},
            list: _avm.secondList,
            onDirTileTap: (dir) async {
              await _avm
                  .setSecondList(context, dir.entity as Directory)
                  .then((value) async {
                _avm.setCurrentDir(dir.entity as Directory);
                await _avm.setFirstList(context, dir.entity.parent,
                    update: true);
              });
            },
          ),
        ),
      ]
    ];
  }

  Future<bool> _handleManagerInstanceWillPop() async {
    log((getEntryDir!.path + '--------' + getCurrentDir!.path));
    return isRelativeRoot;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    log(getCurrentDir != null ? getCurrentDir!.path : '', name: 'current dir');
    log('root repaint', name: 'associcate view');

    if (getCurrentDir != null && getEntryDir != null) {
      if (isRelativeRoot) {
        _gm.setCanPopToDesktop(true);
      } else {
        _gm.setCanPopToDesktop(false);
      }
    }

    return WillPopScope(
      onWillPop: _handleManagerInstanceWillPop,
      child: getCurrentDir == null
          ? Container()
          : Expanded(
              child: getLayoutMode == LayoutMode.vertical
                  ? Column(children: _createAssociateList())
                  : Row(children: _createAssociateList()),
            ),
    );
  }
}

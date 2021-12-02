import 'dart:io';
import 'dart:ui';
import 'fs_utils.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:aqua/model/independent_view_model.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:aqua/common/widget/inner_drawer.dart';
import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/page/file_manager/file_list.dart';
import 'package:aqua/model/global_model.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;

class IndependentView extends StatefulWidget {
  final int? selectLimit;

  final GlobalKey<InnerDrawerState>? innerDrawerKey;

  ///  * [appointPath] 默认外存的根目录
  const IndependentView({
    Key? key,
    this.selectLimit = 1,
    this.innerDrawerKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IndependentViewState();
  }
}

class IndependentViewState extends State<IndependentView>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late GlobalModel _gm;
  late IndependentViewModel _ivm;
  late FileManagerModel _fm;
  late bool _initMutex;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initMutex = true;
    BackButtonInterceptor.add(_willPopFileRoute);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _gm = Provider.of<GlobalModel>(context);
    _ivm = Provider.of<IndependentViewModel>(context);
    _fm = Provider.of<FileManagerModel>(context);

    if (_initMutex) {
      _initMutex = false;
      await _ivm.setFirstList(context, getEntryDir!).then((_) {
        _ivm.setFirstCurrentDir(getEntryDir!);
      });

      await _ivm.setSecondList(context, getEntryDir!, update: true).then((_) {
        _ivm.setSecondCurrentDir(getEntryDir!);
      });
    }
  }

  @override
  dispose() {
    super.dispose();
    BackButtonInterceptor.remove(_willPopFileRoute);
  }

  LayoutMode get getLayoutMode => _fm.layoutMode;

  Directory? get getEntryDir => _fm.entryDir;

  Directory? get getFirstCurrentDir => _ivm.firstCurrentDir;

  Directory? get getSecondCurrentDir => _ivm.secondCurrentDir;

  FileManagerMode get getVisitMode => _fm.visitMode;

  bool get isFirstRelativeParentRoot =>
      pathLib.equals(getEntryDir!.path, getFirstCurrentDir!.parent.path);

  bool get isSecondRelativeParentRoot =>
      pathLib.equals(getEntryDir!.path, getFirstCurrentDir!.parent.path);

  // 第一个窗口是否相对是相对根目录
  bool get isFirstRelativeRoot =>
      pathLib.equals(getEntryDir!.path, getFirstCurrentDir!.path);

  // 第二个窗口是否相对是相对根目录
  bool get isSecondRelativeRoot =>
      pathLib.equals(getEntryDir!.path, getSecondCurrentDir!.path);

  /// 拦截返回
  Future<bool> _willPopFileRoute(
      bool stopDefaultButtonEvent, RouteInfo routeInfo) async {
    if (_ivm.activeWindow == IndependentActiveWindow.first) {
      if (isFirstRelativeRoot) {
        return false;
      }

      if (!isFirstRelativeRoot &&
          !pathLib.isWithin(getEntryDir!.path, getFirstCurrentDir!.path)) {
        await _ivm.setFirstList(context, getEntryDir!, update: true);
        return false;
      }

      await _ivm
          .setFirstList(context, getFirstCurrentDir!.parent, update: true)
          .then((_) {
        _ivm.setFirstCurrentDir(getFirstCurrentDir!.parent);
      });
    }

    if (_ivm.activeWindow == IndependentActiveWindow.second) {
      if (isSecondRelativeRoot) {
        return false;
      }

      if (!isSecondRelativeRoot &&
          !pathLib.isWithin(getEntryDir!.path, getSecondCurrentDir!.path)) {
        await _ivm.setSecondList(context, getEntryDir!, update: true);
        return false;
      }

      await _ivm
          .setSecondList(context, getSecondCurrentDir!.parent, update: true)
          .then((_) {
        _ivm.setSecondCurrentDir(getSecondCurrentDir!.parent);
      });
    }

    return false;
  }

  List<Widget> _createIndependentList() {
    return <Widget>[
      Expanded(
        flex: 1,
        child: FileList(
          first: true,
          selectLimit: widget.selectLimit,
          shadowLeft: IndependentActiveWindow.first == _ivm.activeWindow,
          onChangePopLocker: (val) {},
          list: _ivm.firstList,
          onTapEmpty: () {
            _ivm.setActiveWindow(IndependentActiveWindow.first);
          },
          onScorll: () {
            if (IndependentActiveWindow.second == _ivm.activeWindow) {
              _ivm.setActiveWindow(IndependentActiveWindow.first);
            }
          },
          onItemHozDrag: () {
            _ivm.setActiveWindow(IndependentActiveWindow.first);
          },
          onItemLongPressStart: () {
            _ivm.setActiveWindow(IndependentActiveWindow.first);
          },
          onDirTileTap: (SelfFileEntity dir) async {
            _ivm.setActiveWindow(IndependentActiveWindow.first);
            await _ivm
                .setFirstList(context, dir.entity as Directory, update: true)
                .then((value) {
              _ivm.setFirstCurrentDir(dir.entity as Directory);
            });
          },
        ),
      ),
      // if (getLayoutMode == LayoutMode.vertical)
      //   Divider(color: Color(0xFF7BC4FF)),
      // Expanded(
      //   flex: 1,
      //   child: FileList(
      //     first: false,
      //     selectLimit: widget.selectLimit,
      //     list: _ivm.secondList,
      //     shadowLeft: IndependentActiveWindow.second == _ivm.activeWindow,
      //     onChangePopLocker: (val) {},
      //     onTapEmpty: () {
      //       _ivm.setActiveWindow(IndependentActiveWindow.second);
      //     },
      //     onScorll: () {
      //       if (IndependentActiveWindow.first == _ivm.activeWindow) {
      //         _ivm.setActiveWindow(IndependentActiveWindow.second);
      //       }
      //     },
      //     onItemHozDrag: () {
      //       _ivm.setActiveWindow(IndependentActiveWindow.second);
      //     },
      //     onItemLongPressStart: () {
      //       _ivm.setActiveWindow(IndependentActiveWindow.second);
      //     },
      //     onDirTileTap: (dir) async {
      //       _ivm.setActiveWindow(IndependentActiveWindow.second);
      //       await _ivm
      //           .setSecondList(context, dir.entity as Directory, update: true)
      //           .then((value) async {
      //         _ivm.setSecondCurrentDir(dir.entity as Directory);
      //       });
      //     },
      //   ),
      // ),
    ];
  }

  Future<void> _handlePathNavigate(Directory dir) async {
    if (pathLib.equals(dir.path, getEntryDir?.path ?? '')) {
      await _ivm.setFirstList(context, dir, update: true);
    } else if (pathLib.isWithin(getEntryDir?.path ?? '', dir.path)) {
      _ivm.setSecondList(context, dir).then((value) async {
        await _ivm.setFirstList(context, dir.parent, update: true);
      });
    }

    _ivm.setCurrentDir(dir);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    log('root repaint', name: 'independent view');

    if (getVisitMode == FileManagerMode.normal) {
      if (_ivm.firstCurrentDir != null &&
          _ivm.secondCurrentDir != null &&
          getEntryDir != null) {
        if (isFirstRelativeRoot && isSecondRelativeRoot) {
          _gm.setCanPopToDesktop(true);
        } else {
          _gm.setCanPopToDesktop(false);
        }
      }
    }

    // bool shouldLoad = _ivm.

    return _ivm.currentDir == null
        ? Container()
        : Expanded(
            child: getLayoutMode == LayoutMode.vertical
                ? Column(children: _createIndependentList())
                : Row(children: _createIndependentList()),
          );
  }
}

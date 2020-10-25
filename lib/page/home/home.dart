import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lan_express/common/socket/socket.dart';
import 'package:lan_express/common/widget/checkbox.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/model/file_model.dart';
import 'package:lan_express/page/file_manager/file_manager.dart';
import 'package:lan_express/page/lan/lan.dart';
import 'package:lan_express/page/setting/setting.dart';
import 'package:lan_express/model/common_model.dart';
import 'package:lan_express/model/theme_model.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/store.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:intent/intent.dart' as intent;
import 'package:intent/action.dart' as action;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeModel _themeModel;
  CupertinoTabController _tabController;
  CommonModel _commonModel;
  bool _mutex;
  bool _updateModalMutex;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController();
    _mutex = true;
    _updateModalMutex = true;
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  Future<void> showUpdateModal(Map data) async {
    PackageInfo pkgInfo = await PackageInfo.fromPlatform();
    String packageName = pkgInfo.packageName;
    String remoteVersion = data['mobile']['latest']['version'];
    List desc = data['mobile']['latest']['desc'];
    String url = data['mobile']['latest']['url'];
    bool forceUpdate = data['mobile']['latest']['forceUpdate'];

    bool isNotTip = await Store.getBool(REMEMBER_NO_UPDATE_TIP) ?? false;

    if (isNotTip) {
      if (!forceUpdate) {
        /// 强制更新 不显示
        return;
      } else {
        await Store.setBool(REMEMBER_NO_UPDATE_TIP, false);
      }
    }

    String descMsg = desc.map((e) => e + '\n').toList().join('');
    if (Version.parse(remoteVersion) > Version.parse(pkgInfo.version)) {
      bool checked = false;
      await showTipTextModal(
        context,
        _themeModel,
        tip: '发现新版本 v$remoteVersion\n$descMsg',
        title: '更新',
        defaultOkText: '下载',
        defaultCancelText: '应用市场',
        additionList: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              StatefulBuilder(builder: (context, changeState) {
                return SizedBox(
                  height: 30,
                  child: LanCheckBox(
                    value: checked,
                    borderColor: _themeModel.themeData.itemFontColor,
                    onChanged: (val) async {
                      await Store.setBool(REMEMBER_NO_UPDATE_TIP, val);
                      if (mounted) {
                        changeState(() {
                          checked = val;
                        });
                      }
                    },
                  ),
                );
              }),
              NoResizeText(
                '不再提示, 遇到强制更新则提示',
                style: TextStyle(
                  color: _themeModel.themeData.itemFontColor,
                ),
              )
            ],
          ),
        ],
        onCancel: () async {
          intent.Intent()
            ..setAction(action.Action.ACTION_VIEW)
            ..setData(Uri.parse('market://details?id=' + packageName))
            ..startActivity().catchError((e) => print(e));
        },
        onOk: () async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            showText('链接打开失败');
          }
        },
      );
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    Map data = _commonModel.gWebData;

    if (_updateModalMutex && data.isNotEmpty) {
      _updateModalMutex = false;
      // 显示更新弹窗
      await showUpdateModal(data);
    }

    if (_mutex) {
      _mutex = false;

      // PermissionStatus status = await PermissionHandler()
      //     .checkPermissionStatus(PermissionGroup.microphone);
      if (_commonModel.isAppInit) {
        //   if (PermissionStatus.granted != status) {
        //     // 提示用户 需要麦克风 权限 否则 无法进入
        //     await _requestMicphonePermissionModal(context);
        //   }
        //   // 强制阅读使用教程 跳转后取消
        //   // await _forceReadTutorialModal(context);
      }

      if (_commonModel.enableConnect) {
        // 延迟一秒 不阻塞UI
        // Timer(Duration(seconds: 1), () async {
        //   await SocketConnecter(_commonModel).searchDevicesAndConnect(
        //     context,
        //     themeProvider: _themeModel,
        //     onNotExpected: (String msg) {
        //       showText(msg);
        //     },
        //   );
        // });
      }
    }
  }

  Future<void> _requestMicphonePermissionModal(context) async {
    await showTipTextModal(
      context,
      _themeModel,
      title: '权限请求',
      tip: '由于软件支持录屏功能, 需要麦克风的权限',
      defaultOkText: '获取权限',
      onOk: () async {
        await PermissionHandler()
            .requestPermissions(<PermissionGroup>[PermissionGroup.microphone]);
      },
      onCancel: () {
        MixUtils.safePop(context);
      },
    );
  }

  Future<void> _forceReadTutorialModal(context) async {
    await showScopeModal(
      context,
      _themeModel,
      title: '请仔细阅读教程',
      tip: '该界面无返返回, 需前往教程后, 方可消失',
      withCancel: false,
      defaultOkText: '前往教程',
      onOk: () async {
        if (await canLaunch(TUTORIAL_BASIC_URL)) {
          await launch(TUTORIAL_BASIC_URL);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel?.themeData;
    return themeData == null
        ? Container()
        : CupertinoTabScaffold(
            controller: _tabController,
            tabBar: CupertinoTabBar(
              onTap: (index) {},
              backgroundColor: themeData.bottomNavColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: '文件',
                  icon: Icon(OMIcons.folder),
                ),
                BottomNavigationBarItem(
                  label: '更多',
                  icon: Icon(Icons.devices),
                ),
                BottomNavigationBarItem(
                  label: '设置',
                  icon: Icon(OMIcons.settings),
                )
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return CupertinoTabView(
                    builder: (context) => ChangeNotifierProvider(
                      create: (context) => FileModel(),
                      child: FileManagerPage(),
                    ),
                  );
                case 1:
                  return CupertinoTabView(
                    builder: (context) => LanPage(),
                  );
                case 2:
                  return CupertinoTabView(
                    builder: (context) => SettingPage(
                      gTabController: _tabController,
                    ),
                  );
                default:
                  assert(false, 'Unexpected tab');
                  return null;
              }
            },
          );
  }
}

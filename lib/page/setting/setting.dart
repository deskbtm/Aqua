import 'dart:io';

import 'package:aqua/model/file_manager_model.dart';
import 'package:aqua/model/select_file_model.dart';
import 'package:aqua/plugin/archive/archive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/modal/show_specific_modal.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/constant/constant_var.dart';

import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/page/lan/code_server/utils.dart';
import 'package:aqua/page/purchase/purchase.dart';
import 'package:aqua/page/setting/code_setting.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:version/version.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'about.dart';

class SettingPage extends StatefulWidget {
  // final CupertinoTabController gTabController;

  const SettingPage({
    Key? key,
    /* required this.gTabController */
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  late ThemeModel _tm;
  late GlobalModel _gm;
  late SelectFileModel _sfm;
  late bool _willUpdate;
  late Map _mSetting;
  late String _version;
  late bool _updateLocker;

  // CupertinoTabController get gTabController => widget.gTabController;

  @override
  void initState() {
    super.initState();
    _mSetting = {};
    _willUpdate = false;
    _updateLocker = true;
    _version = '';
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);
    _sfm = Provider.of<SelectFileModel>(context);

    _mSetting = _gm.gWebData['mobile'] != null ? _gm.gWebData['mobile'] : {};
    if (_updateLocker) {
      _updateLocker = false;
      await checkUpdate();
      setState(() {});
    }
  }

  Future setTheme(bool val) async {
    if (val) {
      _tm.setTheme(DARK_THEME);
    } else {
      _tm.setTheme(LIGHT_THEME);
    }
  }

  Future<void> checkUpdate() async {
    PackageInfo pkgInfo = await PackageInfo.fromPlatform();
    if (_mSetting.isNotEmpty) {
      Version cur = Version.parse(pkgInfo.version);
      Version remote = Version.parse(_mSetting['latest']['version']);
      if (remote > cur) {
        _willUpdate = true;
        _version = remote.toString();
      } else {
        _willUpdate = false;
        _version = pkgInfo.version;
      }
    } else {
      _willUpdate = false;
      _version = pkgInfo.version;
    }
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _tm.themeData;

    List<Widget> settingList = [
      if (!_gm.isPurchased)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle(S.of(context)!.sponsor),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (BuildContext context) {
                      return PurchasePage();
                    },
                  ),
                );
              },
              child: ListTile(
                trailing: Icon(Icons.hdr_weak, color: themeData.itemFontColor),
                title: ThemedText(S.of(context)!.sponsorTitle),
                subtitle: ThemedText(
                  '5￥ ${S.of(context)!.sponsorText}',
                  small: true,
                ),
                contentPadding: EdgeInsets.only(left: 15, right: 25),
              ),
            ),
          ],
        ),
      if (_gm.username != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle(S.of(context)!.user),
            SizedBox(height: 15),
            ListTile(
              title: ThemedText(S.of(context)!.username),
              subtitle: ThemedText(
                '${_gm.username}',
                small: true,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText(S.of(context)!.exit),
                onPressed: () async {
                  await showTipTextModal(
                    context,
                    title: S.of(context)!.exit,
                    tip: S.of(context)!.exitTip,
                    onOk: () async {
                      await _gm.logout();
                    },
                    onCancel: () {},
                  );
                },
              ),
            ),
          ],
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(S.of(context)!.appearance),
          SizedBox(height: 15),
          ListTile(
            title: ThemedText(S.of(context)!.dark),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: AquaSwitch(
              value: _tm.isDark,
              onChanged: (val) async {
                await setTheme(val);
              },
            ),
          ),
          ListTile(
            title: ThemedText(S.of(context)!.staticServerTheme),
            subtitle:
                ThemedText(S.of(context)!.subStaticServerTheme, small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: Container(
              width: 42,
              child: ThemedText(_tm.isDark ? 'dark' : 'light', small: true),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(S.of(context)!.staticServer),
          SizedBox(height: 15),
          InkWell(
            onTap: () {},
            child: ListTile(
              title: ThemedText(S.of(context)!.savePath),
              subtitle: ThemedText('${_gm.staticUploadSavePath}'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText('更换'),
                onPressed: () {
                  showSingleTextFieldModal(
                    context,
                    title: S.of(context)!.savePath,
                    initText: _gm.storageRootPath + '/',
                    placeholder: '以 ${_gm.storageRootPath}/ 开头',
                    onOk: (String? val) async {
                      try {
                        if (val != null) {
                          return;
                        }
                        if (!Directory(val!).existsSync()) {
                          await Directory(val).create(recursive: true);
                        }
                        await _gm.setStaticUploadSavePath(val.trim());
                      } catch (e, s) {
                        await Sentry.captureException(
                          e,
                          stackTrace: s,
                        );
                      }
                    },
                    onCancel: () {},
                  );
                },
              ),
            ),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(S.of(context)!.codeServer),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return FileManagerPage(
                      appointPath: _gm.storageRootPath,
                      selectLimit: 1,
                      displayLeading: false,
                      mode: FileManagerMode.pick,
                      // 这里是FileManager的context
                      trailingBuilder: (fileCtx) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              MixUtils.safePop(fileCtx);
                              if (!_gm.isPurchased) {
                                Fluttertoast.showToast(
                                    msg: '请先购买 "IOS管理器" for developer');
                                return;
                              }

                              if (_sfm.pickedFiles.isEmpty) {
                                Fluttertoast.showToast(msg: '请先选中资源');
                                return;
                              }
                              SelfFileEntity file = _sfm.pickedFiles[0];

                              _sfm.clearPickedFiles();

                              CodeSrvUtils cutils = await CodeSrvUtils().init();
                              await cutils.rmAllResource().catchError((err) {
                                Fluttertoast.showToast(msg: '删除出现异常');
                                // FLog.error(
                                //   text: '删除安装资源出现异常',
                                //   className: 'SettingPageState',
                                // );
                              });

                              if (file != null && file.ext == '.zip') {
                                LocalNotification.showNotification(
                                  index: 10,
                                  name: 'CODE_INSTALL',
                                  title: '安装中.....',
                                  onlyAlertOnce: true,
                                  showProgress: true,
                                  indeterminate: true,
                                );

                                CodeSrvUtils cutils =
                                    await CodeSrvUtils().init();
                                await Archive.unzip(
                                  file.entity.path,
                                  cutils.filesPath,
                                );
                                if (await File(
                                        '${cutils.filesPath}/${cutils.tarName}')
                                    .exists()) {
                                  bool installed =
                                      await cutils.installResource();

                                  if (installed != true) {
                                    await cutils.rmAllResource().catchError(
                                          (err) {},
                                        );
                                    Fluttertoast.showToast(msg: '资源安装失败 已删除');
                                    MixUtils.safePop(context);
                                    return;
                                  }

                                  await cutils.installNodeJs().catchError(
                                    (err) {
                                      Fluttertoast.showToast(msg: 'node 安装失败');
                                    },
                                  );
                                  Fluttertoast.showToast(
                                      msg: S.of(context)!.setSuccess);
                                  LocalNotification.plugin?.cancel(10);
                                }
                              } else {
                                Fluttertoast.showToast(msg: '资源包必须名为zip格式');
                              }
                            },
                            child: NoResizeText(
                              S.of(context)!.sure,
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
            child: ListTile(
              title: ThemedText(S.of(context)!.installManually),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              CodeSrvUtils cutils = await CodeSrvUtils().init();
              // await cutils.init();
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return CodeSettingPage(
                      cutils: cutils,
                    );
                  },
                ),
              );
              if (!(await cutils.existsAllResource())) {
                // gTabController.index = 1;
                // 确保删除干净了
                await cutils.rmAllResource();
                Fluttertoast.showToast(msg: S.of(context)!.installRes);
              }
            },
            child: ListTile(
                leading: Icon(Icons.hdr_weak, color: themeData.itemFontColor),
                title: ThemedText(S.of(context)!.moreSetting, alignX: -1.15),
                contentPadding: EdgeInsets.only(left: 15, right: 25),
                trailing: Icon(Icons.hdr_weak)),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('WebDAV'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await showSingleTextFieldModal(
                context,
                title: S.of(context)!.webDavServer,
                placeholder: _gm.webDavAddr,
                onOk: (val) {
                  _gm.setWebDavAddr(val.replaceFirst(RegExp(r'/*$'), ''));
                  Fluttertoast.showToast(msg: S.of(context)!.setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(Icons.hdr_weak, color: themeData.itemFontColor),
              title: ThemedText(S.of(context)!.webDavServer),
              subtitle: ThemedText(_gm.webDavAddr == null
                  ? S.of(context)!.notSetting
                  : _gm.webDavAddr!),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                title: S.of(context)!.webDavAccount,
                placeholder: _gm.webDavUsername,
                onOk: (val) {
                  _gm.setWebDavUsername(val);
                  Fluttertoast.showToast(msg: S.of(context)!.setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(Icons.hdr_weak, color: themeData.itemFontColor),
              title: ThemedText(
                S.of(context)!.webDavAccount,
              ),
              subtitle: ThemedText(
                _gm.webDavUsername == null
                    ? S.of(context)!.notSetting
                    : _gm.webDavUsername!,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                title: S.of(context)!.password,
                onOk: (val) {
                  _gm.setWebDavPwd(val);
                  Fluttertoast.showToast(msg: S.of(context)!.setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              title: ThemedText(S.of(context)!.password),
              subtitle: ThemedText(
                _gm.webDavPwd == null
                    ? S.of(context)!.notSetting
                    : List.filled(_gm.webDavPwd!.length, null, growable: false)
                        .map((e) => '*')
                        .toList()
                        .join(''),
                small: true,
              ),
              trailing: Icon(Icons.hdr_weak, color: themeData.itemFontColor),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(S.of(context)!.others),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await showSelectModal(
                context,
                popPreviousWindow: true,
                options: [
                  {'title': '中文', 'code': 'zh'},
                  {'title': 'English', 'code': 'en'},
                ],
                title: S.of(context)!.languageTip,
                item: (index, data) => Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: themeData.listTileColor,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  margin: EdgeInsets.only(top: 4, bottom: 4),
                  child: NoResizeText(
                    data['title'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onSelected: (index, data) async {
                  _gm.setLanguage(data['code']);
                },
              );
            },
            child: ListTile(
              title: ThemedText(S.of(context)!.language),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return AboutPage();
                  },
                ),
              );
            },
            child: ListTile(
                title: ThemedText(S.of(context)!.about),
                contentPadding: EdgeInsets.only(left: 15, right: 25),
                trailing: Icon(Icons.hdr_weak)),
          ),
          // InkWell(
          //   onTap: () async {
          //     Navigator.of(context, rootNavigator: true).push(
          //       CupertinoPageRoute(
          //         builder: (BuildContext context) {
          //           return HelperPage();
          //         },
          //       ),
          //     );
          //   },
          //   child: ListTile(
          //       title: ThemedText(S.of(context)!.help),
          //       contentPadding: EdgeInsets.only(left: 15, right: 25),
          //       trailing: Icon(FontAwesomeIcons.chevronRight)),
          // ),
          InkWell(
            onTap: () async {
              await showUpdateModal(
                context,
                _tm,
                _gm.gWebData,
                tipRemember: false,
              );
            },
            child: ListTile(
              title: ThemedText(S.of(context)!.update),
              subtitle: ThemedText('v$_version', small: true),
              trailing: _willUpdate
                  ? Icon(Icons.hdr_weak, color: Colors.redAccent)
                  : CupertinoButton(
                      child: NoResizeText(S.of(context)!.latest),
                      onPressed: () {}),
              contentPadding:
                  EdgeInsets.only(left: 15, right: _willUpdate ? 25 : 10),
            ),
          ),
          SizedBox(height: 30)
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          S.of(context)!.settingLabel,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData.navTitleColor,
          ),
        ),
        backgroundColor: themeData.navBackgroundColor,
        border: null,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: settingList.length,
            itemBuilder: (BuildContext context, int index) {
              return settingList[index];
            },
          ),
        ),
      ),
    );
  }
}

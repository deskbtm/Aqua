import 'dart:io';

import 'package:android_mix/android_mix.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/show_modal_entity.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/show_modal.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/external/bot_toast/bot_toast.dart';
import 'package:aqua/page/file_manager/file_manager.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/page/lan/code_server/utils.dart';
import 'package:aqua/page/purchase/purchase.dart';
import 'package:aqua/page/setting/code_setting.dart';
import 'package:aqua/page/setting/helper_setting.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/notification.dart';
import 'package:aqua/utils/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:version/version.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'about.dart';

class SettingPage extends StatefulWidget {
  final CupertinoTabController gTabController;

  const SettingPage({Key key, this.gTabController}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  bool _willUpdate;
  Map _mSetting;
  String _version;
  bool _updateLocker;

  CupertinoTabController get gTabController => widget.gTabController;

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
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

    _mSetting = _commonModel.gWebData['mobile'] != null
        ? _commonModel.gWebData['mobile']
        : {};
    if (_updateLocker) {
      _updateLocker = false;
      await checkUpdate();
      setState(() {});
    }
  }

  void showText(String content,
      {Duration duration = const Duration(seconds: 3)}) {
    BotToast.showText(
      text: content,
      duration: duration,
    );
  }

  Future setTheme(bool val) async {
    if (val) {
      _themeModel.setTheme(DARK_THEME);
    } else {
      _themeModel.setTheme(LIGHT_THEME);
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
    AquaTheme themeData = _themeModel?.themeData;

    List<Widget> settingList = [
      if (!_commonModel.isPurchased)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle(AppLocalizations.of(context).sponsor),
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
                trailing: Icon(OMIcons.addShoppingCart,
                    color: themeData?.itemFontColor),
                title: LanText(AppLocalizations.of(context).sponsorTitle),
                subtitle: LanText(
                  '5￥ ${AppLocalizations.of(context).sponsorText}',
                  small: true,
                ),
                contentPadding: EdgeInsets.only(left: 15, right: 25),
              ),
            ),
          ],
        ),
      if (_commonModel.username != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle(AppLocalizations.of(context).user),
            SizedBox(height: 15),
            ListTile(
              title: LanText(AppLocalizations.of(context).username),
              subtitle: LanText(
                '${_commonModel.username}',
                small: true,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText(AppLocalizations.of(context).exit),
                onPressed: () async {
                  await showTipTextModal(
                    context,
                    title: AppLocalizations.of(context).exit,
                    tip: AppLocalizations.of(context).exitTip,
                    onOk: () async {
                      await _commonModel.logout();
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
          blockTitle(AppLocalizations.of(context).appearance),
          SizedBox(height: 15),
          ListTile(
            title: LanText(AppLocalizations.of(context).dark),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _themeModel.isDark,
              onChanged: (val) async {
                await setTheme(val);
              },
            ),
          ),
          ListTile(
            title: LanText(AppLocalizations.of(context).staticServerTheme),
            subtitle: LanText(AppLocalizations.of(context).subStaticServerTheme,
                small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: Container(
              width: 42,
              child:
                  LanText(_themeModel.isDark ? 'dark' : 'light', small: true),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(AppLocalizations.of(context).staticServer),
          SizedBox(height: 15),
          InkWell(
            onTap: () {},
            child: ListTile(
              title: LanText(AppLocalizations.of(context).savePath),
              subtitle: LanText('${_commonModel.staticUploadSavePath}'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText('更换'),
                onPressed: () {
                  showSingleTextFieldModal(
                    context,
                    title: AppLocalizations.of(context).savePath,
                    initText: _commonModel.storageRootPath + '/',
                    placeholder: '以 ${_commonModel.storageRootPath}/ 开头',
                    onOk: (String val) async {
                      try {
                        if (!Directory(val).existsSync()) {
                          await Directory(val).create(recursive: true);
                        }
                        await _commonModel.setStaticUploadSavePath(val?.trim());
                      } catch (e) {}
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
          blockTitle(AppLocalizations.of(context).codeServer),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return FileManagerPage(
                      appointPath: _commonModel.storageRootPath,
                      selectLimit: 1,
                      mode: FileManagerMode.pick,
                      // 这里是FileManager的context
                      trailingBuilder: (fileCtx) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              MixUtils.safePop(fileCtx);
                              if (!_commonModel.isPurchased) {
                                showText('请先购买 "IOS管理器" for developer');
                                return;
                              }

                              if (_commonModel.pickedFiles.isEmpty) {
                                showText('请先选中资源');
                                return;
                              }
                              SelfFileEntity file = _commonModel.pickedFiles[0];

                              await _commonModel.clearPickedFiles();

                              CodeSrvUtils cutils = await CodeSrvUtils().init();
                              await cutils.rmAllResource().catchError((err) {
                                showText('删除出现异常');
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
                                await AndroidMix.archive.unzip(
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
                                    showText('资源安装失败 已删除');
                                    MixUtils.safePop(context);
                                    return;
                                  }

                                  await cutils.installNodeJs().catchError(
                                    (err) {
                                      showText('node 安装失败');
                                    },
                                  );
                                  showText(
                                      AppLocalizations.of(context).setSuccess);
                                  LocalNotification.plugin?.cancel(10);
                                }
                              } else {
                                showText('资源包必须名为zip格式');
                              }
                            },
                            child: NoResizeText(
                              AppLocalizations.of(context).sure,
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
              title: LanText(AppLocalizations.of(context).installManually),
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
                gTabController.index = 1;
                // 确保删除干净了
                await cutils.rmAllResource();
                showText(AppLocalizations.of(context).installRes);
              }
            },
            child: ListTile(
              leading: Icon(OMIcons.code, color: themeData?.itemFontColor),
              title: LanText(AppLocalizations.of(context).moreSetting,
                  alignX: -1.15),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
              trailing: Icon(
                OMIcons.chevronRight,
                color: themeData?.itemFontColor,
                size: 16,
              ),
            ),
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
                title: AppLocalizations.of(context).webDavServer,
                placeholder: _commonModel.webDavAddr,
                onOk: (val) {
                  _commonModel
                      .setWebDavAddr(val.replaceFirst(RegExp(r'/*$'), ''));
                  showText(AppLocalizations.of(context).setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(OMIcons.web, color: themeData?.itemFontColor),
              title: LanText(AppLocalizations.of(context).webDavServer),
              subtitle: LanText(_commonModel.webDavAddr == null
                  ? AppLocalizations.of(context).notSetting
                  : _commonModel.webDavAddr),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                title: AppLocalizations.of(context).webDavAccount,
                placeholder: _commonModel.webDavUsername,
                onOk: (val) {
                  _commonModel.setWebDavUsername(val);
                  showText(AppLocalizations.of(context).setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(OMIcons.face, color: themeData?.itemFontColor),
              title: LanText(
                AppLocalizations.of(context).webDavAccount,
              ),
              subtitle: LanText(
                _commonModel.webDavUsername == null
                    ? AppLocalizations.of(context).notSetting
                    : _commonModel.webDavUsername,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                title: AppLocalizations.of(context).password,
                onOk: (val) {
                  _commonModel.setWebDavPwd(val);
                  showText(AppLocalizations.of(context).setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              title: LanText(AppLocalizations.of(context).password),
              subtitle: LanText(
                _commonModel.webDavPwd == null
                    ? AppLocalizations.of(context).notSetting
                    : List(_commonModel.webDavPwd.length)
                        .map((e) => '*')
                        .toList()
                        .join(''),
                small: true,
              ),
              trailing: Icon(OMIcons.lock, color: themeData?.itemFontColor),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(AppLocalizations.of(context).others),
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
                title: AppLocalizations.of(context).languageTip,
                item: (index, data) => Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: themeData.itemColor,
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  margin: EdgeInsets.only(top: 4, bottom: 4),
                  child: NoResizeText(
                    data['title'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onSelected: (index, data) async {
                  _commonModel.setLanguage(data['code']);

                  // Navigator.pop(context);
                },
              );
            },
            child: ListTile(
              title: LanText(AppLocalizations.of(context).language),
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
              title: LanText(AppLocalizations.of(context).about),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
              trailing: Icon(
                OMIcons.chevronRight,
                color: themeData?.itemFontColor,
                size: 16,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return HelperPage();
                  },
                ),
              );
            },
            child: ListTile(
              title: LanText(AppLocalizations.of(context).help),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
              trailing: Icon(
                OMIcons.chevronRight,
                color: themeData?.itemFontColor,
                size: 16,
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await showUpdateModal(
                context,
                _themeModel,
                _commonModel.gWebData,
                tipRemember: false,
              );
            },
            child: ListTile(
              title: LanText(AppLocalizations.of(context).update),
              subtitle: LanText('v$_version', small: true),
              trailing: _willUpdate
                  ? Icon(OMIcons.update, color: Colors.redAccent)
                  : CupertinoButton(
                      child: NoResizeText(AppLocalizations.of(context).latest),
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
          AppLocalizations.of(context).settingLabel,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData?.navTitleColor,
          ),
        ),
        backgroundColor: themeData?.navBackgroundColor,
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

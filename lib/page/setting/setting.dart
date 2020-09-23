import 'package:android_mix/android_mix.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/page/purchase/purchase.dart';
import 'package:lan_express/page/setting/code_setting.dart';
import 'package:lan_express/page/setting/control_setting.dart';
import 'package:lan_express/page/setting/express_setting.dart';
import 'package:lan_express/page/setting/privacy_policy.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class SettingPage extends StatefulWidget {
  final CupertinoTabController gTabController;

  const SettingPage({Key key, this.gTabController}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
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
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);

    _mSetting = _commonProvider.gWebData['mobile'] != null
        ? _commonProvider.gWebData['mobile']
        : {};
    if (_updateLocker) {
      _updateLocker = false;
      await checkUpdate();
      setState(() {});
    }
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  Future setTheme(bool val) async {
    if (val) {
      _themeProvider.setTheme(DARK_THEME);
    } else {
      _themeProvider.setTheme(LIGHT_THEME);
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
    dynamic themeData = _themeProvider?.themeData;

    List<Widget> settingList = [
      if (!_commonProvider.isPurchased)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle('购买'),
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
                title: LanText('购买'),
                subtitle: LanText(
                  '价格${_commonProvider?.gWebData['amount'] ?? DEF_AMOUNT}元 购买后此选项不再显示',
                  small: true,
                ),
                contentPadding: EdgeInsets.only(left: 15, right: 25),
              ),
            ),
          ],
        ),
      if (_commonProvider.username != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30),
            blockTitle('用户'),
            SizedBox(height: 15),
            ListTile(
              title: LanText('用户名'),
              subtitle: LanText(
                '${_commonProvider.username}',
                small: true,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText('退出'),
                onPressed: () async {
                  await showTipTextModal(
                    context,
                    _themeProvider,
                    title: '用户退出',
                    tip: '确定退出？退出后购买也会被删除',
                    onOk: () async {
                      await _commonProvider.logout();
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
          blockTitle('外观'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('暗黑模式'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _themeProvider.isDark,
              onChanged: (val) async {
                await setTheme(val);
              },
            ),
          ),
          ListTile(
            title: LanText('静态服务主题'),
            subtitle: LanText('跟随软件', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: Container(
              width: 42,
              child: LanText(_themeProvider.isDark ? '暗黑' : '浅白', small: true),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('传输'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('本机IP'),
            subtitle: LanText('${_commonProvider?.internalIp}'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          ListTile(
            title: LanText('传输服务'),
            subtitle: LanText('关闭后 需要与pc连接的服务将无法使用', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonProvider.enableConnect,
              onChanged: (val) async {
                await _commonProvider.setEnableConnect(val);
              },
            ),
          ),
          ListTile(
            title: LanText('服务端口'),
            subtitle: LanText('内网快递, 静态服务端口', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: CupertinoButton(
              child: NoResizeText('${_commonProvider.filePort}'),
              onPressed: () async {
                await showSingleTextFieldModal(
                  context,
                  _themeProvider,
                  title: '更改端口',
                  placeholder: _commonProvider.filePort,
                  onOk: (val) async {
                    String port = val.toString();
                    showText('请更改pc端口为 $port 并重启软件');
                    await _commonProvider.setFilePort(port);
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
          blockTitle('内网快递'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('自动连接'),
            subtitle: LanText('App开启时 自动至连接pc', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonProvider.autoConnectExpress,
              onChanged: (val) async {
                await _commonProvider.setAutoConnectExpress(val);
              },
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return ExpressSettingPage();
                  },
                ),
              );
            },
            child: ListTile(
              leading: Icon(OMIcons.share, color: themeData?.itemFontColor),
              title: LanText('详细设置', alignX: -1.15),
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
          blockTitle('静态服务'),
          SizedBox(height: 15),
          InkWell(
            onTap: () {},
            child: ListTile(
              title: LanText('上传保存路径'),
              subtitle: LanText('${_commonProvider.staticUploadSavePath}'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              trailing: CupertinoButton(
                child: NoResizeText('更换'),
                onPressed: () {
                  showSingleTextFieldModal(
                    context,
                    _themeProvider,
                    title: '静态上传保存路径',
                    onOk: (String val) async {
                      await _commonProvider
                          .setStaticUploadSavePath(val?.trim());
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
          blockTitle('Code Server&沙盒'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {},
            child: ListTile(
              title: LanText('手动安装'),
              subtitle: LanText('手动添加下载好的压缩包', small: true),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              CodeSrvUtils cutils = CodeSrvUtils();
              await cutils.init();

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
                showText('请先安装完整的环境');
              }
            },
            child: ListTile(
              leading: Icon(OMIcons.code, color: themeData?.itemFontColor),
              title: LanText('详细设置', alignX: -1.15),
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
          blockTitle('剪贴板'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('开启剪贴板'),
            subtitle: LanText('开启后可直接(ctrl+v)', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonProvider.enableClipboard,
              onChanged: (val) async {
                await _commonProvider.setEnableClipboard(val);
              },
            ),
          ),
          InkWell(
            onTap: () async {
              if (await canLaunch(FIX_CLIPBOARD_URL)) {
                await launch(FIX_CLIPBOARD_URL);
              } else {
                showText('链接打开失败');
              }
            },
            child: ListTile(
              title: LanText('问题解决'),
              subtitle: LanText('安卓10以上用户', small: true),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          )
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('控制'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(
                  maintainState: false,
                  builder: (BuildContext context) {
                    return ControlSettingPage();
                  },
                ),
              );
            },
            child: ListTile(
              leading:
                  Icon(OMIcons.settingsRemote, color: themeData?.itemFontColor),
              title: LanText('详细设置', alignX: -1.15),
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
          blockTitle('WebDAV', subtitle: '(推荐使用坚果云)'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              await showSingleTextFieldModal(
                context,
                _themeProvider,
                title: '服务器地址',
                placeholder: _commonProvider.webDavAddr,
                onOk: (val) {
                  _commonProvider
                      .setWebDavAddr(val.replaceFirst(RegExp(r'/*$'), ''));
                  showText('设置成功');
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(OMIcons.web, color: themeData?.itemFontColor),
              title: LanText('服务器'),
              subtitle: LanText(_commonProvider.webDavAddr == null
                  ? '未设置'
                  : _commonProvider.webDavAddr),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                _themeProvider,
                title: '账号',
                placeholder: _commonProvider.webDavUsername,
                onOk: (val) {
                  _commonProvider.setWebDavUsername(val);
                  showText('设置成功');
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              trailing: Icon(OMIcons.face, color: themeData?.itemFontColor),
              title: LanText(
                '账号',
              ),
              subtitle: LanText(
                _commonProvider.webDavUsername == null
                    ? '未设置'
                    : _commonProvider.webDavUsername,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
          ),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                _themeProvider,
                title: '密码',
                onOk: (val) {
                  _commonProvider.setWebDavPwd(val);
                  showText('设置成功');
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              title: LanText('密码'),
              subtitle: LanText(
                _commonProvider.webDavPwd == null
                    ? '未设置'
                    : List(_commonProvider.webDavPwd.length)
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
          blockTitle('其他'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('关于'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (BuildContext context) {
                    return PrivacyPolicyPage();
                  },
                ),
              );
            },
            child: ListTile(
              title: LanText('隐私政策'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              if (await canLaunch(TUTORIAL_URL)) {
                await launch(TUTORIAL_URL);
              } else {
                showText('链接打开失败');
              }
            },
            child: ListTile(
              title: LanText('使用教程'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () {},
            child: ListTile(
              title: LanText('检查更新'),
              subtitle: LanText('$_version', small: true),
              trailing: _willUpdate
                  ? Icon(OMIcons.update, color: Colors.redAccent)
                  : CupertinoButton(
                      child: NoResizeText('最新'), onPressed: () {}),
              contentPadding:
                  EdgeInsets.only(left: 15, right: _willUpdate ? 25 : 10),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('日志'),
          SizedBox(height: 15),
          InkWell(
            onTap: () async {
              final MailOptions mailOptions = MailOptions(
                body: (await FLog.getAllLogs())
                    .map((e) => e.text)
                    .toList()
                    .join(''),
                subject: '局域网.文件.更多 日志',
                recipients: ['wanghan9423@outlook.com'],
                isHTML: false,
              );

              await FlutterMailer.send(mailOptions);
            },
            child: ListTile(
              title: LanText('发送日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.clearLogs();
              showText('删除完成');
            },
            child: ListTile(
              title: LanText('删除日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.exportLogs();
              String externalDir = await AndroidMix.storage.getStorageDirectory;
              showText('日志导出至: $externalDir');
            },
            child: ListTile(
              title: LanText('导出日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
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
          '设置',
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
              return StatefulBuilder(builder: (context, changeState) {
                return settingList[index];
              });
            },
          ),
        ),
      ),
    );
  }
}

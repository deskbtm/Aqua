import 'dart:io';

import 'package:android_mix/android_mix.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingPageState();
  }
}

class SettingPageState extends State<SettingPage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
  bool _darkSwitch;

  @override
  void initState() {
    super.initState();
    _darkSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider?.themeData?.toastColor);
  }

  Future setTheme(bool val) async {
    if (val) {
      _themeProvider.setTheme(DARK_THEME);
    } else {
      _themeProvider.setTheme(LIGHT_THEME);
    }
  }

  Widget blockTitle(String title, {String subtitle}) => Container(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          NoResizeText(
            title,
            style: TextStyle(fontSize: 18, color: Color(0xFF007AFF)),
          ),
          SizedBox(width: 5),
          if (subtitle != null) LanText(subtitle, small: true)
        ]),
      );

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;

    List<Widget> settingList = [
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
            subtitle: LanText('默认跟随软件', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: Container(
              width: 42,
              child: LanText('暗黑', small: true),
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('局域网'),
          SizedBox(height: 15),
          ListTile(
            title: LanText('自动连接'),
            subtitle: LanText('App开启时 自动至连接pc', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _themeProvider.isDark,
              onChanged: (val) async {
                await setTheme(val);
              },
            ),
          ),
          ListTile(
            title: LanText('当前IP'),
            subtitle: LanText('${_commonProvider?.internalIp}'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: CupertinoButton(
              child: NoResizeText('历史'),
              onPressed: () {},
            ),
          ),
          ListTile(
            title: LanText('内网快递端口'),
            subtitle: LanText('更改后pc端会自动更改 如有错误请手动更改', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          ListTile(
            title: LanText('静态服务端口'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
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
              value: _themeProvider.isDark,
              onChanged: (val) async {},
            ),
          ),
          ListTile(
            title: LanText('问题解决'),
            subtitle: LanText('安卓10以上用户', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('文件管理器'),
          SizedBox(height: 15),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('WebDAV', subtitle: '(推荐使用坚果云)'),
          SizedBox(height: 15),
          InkWell(
            onTap: () {
              print('demodeo');
            },
            child: ListTile(
              leading: Icon(OMIcons.web, color: themeData?.itemFontColor),
              title: LanText('服务器', alignX: -1.15),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () {
              print('demodeo');
            },
            child: ListTile(
              leading: Icon(OMIcons.face, color: themeData?.itemFontColor),
              title: LanText('账号', alignX: -1.15),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            leading: Icon(OMIcons.lock, color: themeData?.itemFontColor),
            title: LanText('密码', alignX: -1.15),
            subtitle: LanText('************', small: true, alignX: -1.16),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
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
            leading:
                Icon(OMIcons.addShoppingCart, color: themeData?.itemFontColor),
            title: LanText('购买', alignX: -1.15),
            subtitle: LanText(
              '价格6元 移动+PC',
              small: true,
              alignX: -1.2,
            ),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          ListTile(
            title: LanText('关于'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          ListTile(
            title: LanText('使用教程'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          ListTile(
            title: LanText('检查更新'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          InkWell(
            onTap: () async {
              await FLog.exportLogs();
              String externalDir = await AndroidMix.storage.getStorageDirectory;
              Directory('$externalDir/FLogs');
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
        leading: Container(),
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
              return settingList[index];
            },
          ),
        ),
      ),
    );
  }
}

// Future setTheme() async {
//   String theme = await Store.getString(THEME_KEY);
//   if (theme == DARK_THEME) {
//     _themeProvider.setTheme(LIGHT_THEME);
//     await Store.setString(THEME_KEY, LIGHT_THEME);
//   } else {
//     _themeProvider.setTheme(DARK_THEME);
//     await Store.setString(THEME_KEY, DARK_THEME);
//   }
// }

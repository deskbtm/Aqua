import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/common/widget/switch.dart';
import 'package:lan_file_more/constant/constant_var.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/external/menu/menu.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:provider/provider.dart';

String repoChineseName(String mirror) {
  String name;
  switch (mirror) {
    case TSINGHUA_REPO:
      name = '清华';
      break;
    case ALIYUN_REPO:
      name = '阿里云';
      break;
    case USTC_REPO:
      name = '中科大';
      break;
    case ALPINE_REPO:
      name = 'alpine 官方';
      break;
    default:
      name = mirror;
  }
  return name;
}

class CodeSettingPage extends StatefulWidget {
  final CodeSrvUtils cutils;

  const CodeSettingPage({Key key, this.cutils}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CodeSettingPageState();
  }
}

class CodeSettingPageState extends State<CodeSettingPage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;

  CodeSrvUtils get cutils => widget.cutils;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  // Future<String> copyResolveClipboard() async {
  //   String pkg = PackageInfo().packageName;
  //   return """
  //   adb -d shell appops set $pkg SYSTEM_ALERT_WINDOW allow
  //   adb -d shell pm grant $pkg android.permission.READ_LOGS
  //   adb shell am force-stop $pkg
  //   """;
  // }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel?.themeData;
    String repo = _commonModel.linuxRepo;
    Directory rootfs = Directory('${cutils.filesPath}/rootfs');

    List<Widget> settingList = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('Code Server'),
          SizedBox(height: 15),
          InkWell(
            onTap: () {
              showSingleTextFieldModal(
                context,
                _themeModel,
                title: '登录密码',
                onOk: (val) async {
                  await _commonModel.setCodeSrvPwd(val);
                  showText('设置成功');
                },
                onCancel: () async {
                  await _commonModel.setCodeSrvPwd(null);
                  showText('设置成功');
                },
                defaultCancelText: '设置为无密码',
              );
            },
            child: ListTile(
              title: LanText('登录密码'),
              subtitle: LanText(
                _commonModel.codeSrvPwd != null
                    ? List(_commonModel.codeSrvPwd.length)
                        .map((e) => '*')
                        .toList()
                        .join('')
                    : '默认无',
                small: true,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            title: LanText('端口'),
            // subtitle: LanText(_commonModel.codeSrvPort),
            trailing: CupertinoButton(
                child: NoResizeText('${_commonModel.codeSrvPort}'),
                onPressed: () async {
                  showSingleTextFieldModal(
                    context,
                    _themeModel,
                    title: '更改端口',
                    placeholder: _commonModel.codeSrvPort,
                    onOk: (val) {
                      _commonModel.setCodeSrvPort(val);
                      showText('设置成功');
                    },
                    onCancel: () {},
                  );
                }),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          InkWell(
            onTap: () async {
              await cutils.killNodeServer();
            },
            child: ListTile(
              title: LanText('结束code server进程'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            title: LanText('Telemetry'),
            subtitle: LanText('用于帮助了解如何改进vscode', small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonModel.codeSrvTelemetry,
              onChanged: (val) async {
                _commonModel.setCodeSrvTelemetry(val);
              },
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle('沙盒', subtitle: 'alpine linux'),
          SizedBox(height: 15),
          InkWell(
            child: ListTile(
              title: LanText('沙盒目录'),
              subtitle: LanText(rootfs.existsSync() ? rootfs.path : '沙盒不存在',
                  small: true),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            title: LanText('更换仓库'),
            subtitle: LanText(repoChineseName(repo), small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: FocusedMenuHolder(
              menuWidth: MediaQuery.of(context).size.width * 0.40,
              menuItemExtent: 45,
              duration: Duration(milliseconds: 100),
              animateMenuItems: true,
              menuOffset: 10.0,
              bottomOffsetHeight: 80.0,
              menuItems: <FocusedMenuItem>[
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('清华'),
                    onPressed: () async {
                      await cutils.setChineseRepo(TSINGHUA_REPO);
                      await _commonModel.setLinuxRepo(TSINGHUA_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('阿里云'),
                    onPressed: () async {
                      await cutils.setChineseRepo(ALIYUN_REPO);
                      await _commonModel.setLinuxRepo(ALIYUN_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('中科大'),
                    onPressed: () async {
                      await cutils.setChineseRepo(USTC_REPO);
                      await _commonModel.setLinuxRepo(USTC_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('Alpine(不推荐)'),
                    onPressed: () async {
                      await cutils.setChineseRepo(ALPINE_REPO);
                      await _commonModel.setLinuxRepo(ALPINE_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('自定义'),
                    onPressed: () {}),
              ],
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: NoResizeText(
                  '选择源',
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await cutils.clearProotTmp();
              showText('删除完成');
            },
            child: ListTile(
              title: LanText(
                '删除沙盒临时文件',
                style: TextStyle(color: Colors.redAccent),
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              showTipTextModal(
                context,
                _themeModel,
                title: '删除沙盒',
                tip: '确定删除沙盒以及code server?',
                confirmedView: loadingIndicator(context, _themeModel),
                onOk: () async {
                  await cutils.rmAllResource().catchError((err) {
                    showText('删除出现异常');
                    recordError(text: 'rm all resource');
                  });
                  showText('删除完成');
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              title: LanText(
                '删除沙盒',
                style: TextStyle(color: Colors.redAccent),
              ),
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
          'Code Server&沙盒',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData?.navTitleColor,
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

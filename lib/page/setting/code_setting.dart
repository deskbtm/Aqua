import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/external/menu/menu.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:package_info/package_info.dart';
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
  @override
  State<StatefulWidget> createState() {
    return CodeSettingPageState();
  }
}

class CodeSettingPageState extends State<CodeSettingPage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;

  CodeSrvUtils _cutils;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);

    _cutils = await CodeSrvUtils().init();
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  Future<String> copyResolveClipboard() async {
    String pkg = PackageInfo().packageName;
    return """
    adb -d shell appops set $pkg SYSTEM_ALERT_WINDOW allow
    adb -d shell pm grant $pkg android.permission.READ_LOGS
    adb shell am force-stop $pkg
    """;
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;
    String repo = _commonProvider.linuxRepo;

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
                _themeProvider,
                title: '登录密码',
                onOk: (val) async {
                  await _commonProvider.setCodeSrvPwd(val);
                  showText('设置成功');
                },
                onCancel: () async {
                  await _commonProvider.setCodeSrvPwd(null);
                  showText('设置成功');
                },
                defaultCancelText: '设置为无密码',
              );
            },
            child: ListTile(
              title: LanText('登录密码'),
              subtitle: LanText(
                _commonProvider.codeSrvPwd != null
                    ? List(_commonProvider.codeSrvPwd.length)
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
            // subtitle: LanText(_commonProvider.codeSrvPort),
            trailing: CupertinoButton(
                child: NoResizeText('${_commonProvider.codeSrvPort}'),
                onPressed: () async {
                  showSingleTextFieldModal(
                    context,
                    _themeProvider,
                    title: '更改端口',
                    placeholder: _commonProvider.codeSrvPort,
                    onOk: (val) {
                      _commonProvider.setCodeSrvPort(val);
                      showText('设置成功');
                    },
                    onCancel: () {},
                  );
                }),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
          InkWell(
            onTap: () async {
              await _cutils.killNodeServer();
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
              value: _commonProvider.codeSrvTelemetry,
              onChanged: (val) async {
                _commonProvider.setCodeSrvTelemetry(val);
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
            onTap: () async {
              // setStorageRootPath
              showText('切换完成');
            },
            child: ListTile(
              title: LanText('沙盒目录'),
              subtitle: LanText('文件管理器切换到沙盒根目录', small: true),
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
                      await _cutils.setChineseRepo(TSINGHUA_REPO);
                      await _commonProvider.setLinuxRepo(TSINGHUA_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('阿里云'),
                    onPressed: () async {
                      await _cutils.setChineseRepo(ALIYUN_REPO);
                      await _commonProvider.setLinuxRepo(ALIYUN_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('中科大'),
                    onPressed: () async {
                      await _cutils.setChineseRepo(USTC_REPO);
                      await _commonProvider.setLinuxRepo(USTC_REPO);
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData?.menuItemColor,
                    title: LanText('Alpine(不推荐)'),
                    onPressed: () async {
                      await _cutils.setChineseRepo(ALPINE_REPO);
                      await _commonProvider.setLinuxRepo(ALPINE_REPO);
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
              await _cutils.clearProotTmp();
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
                _themeProvider,
                title: '删除沙盒',
                tip: '确定删除沙盒以及code server?',
                confirmedView: loadingIndicator(context, _themeProvider),
                onOk: () async {
                  await _cutils.rmAllResource().catchError((err) {
                    showText('删除出现异常');
                    FLog.error(text: 'rm all resource', stacktrace: err);
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

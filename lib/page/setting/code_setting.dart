import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/external/menu/menu.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/page/lan/code_server/utils.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      name = 'alpine';
      break;
    default:
      name = mirror;
  }
  return name;
}

class CodeSettingPage extends StatefulWidget {
  final CodeSrvUtils cutils;

  const CodeSettingPage({Key? key, required this.cutils}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return CodeSettingPageState();
  }
}

class CodeSettingPageState extends State<CodeSettingPage> {
  late ThemeModel _themeModel;
  late GlobalModel _globalModel;

  CodeSrvUtils get cutils => widget.cutils;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel.themeData;
    String repo = _globalModel.alpineRepo!;
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
                title: AppLocalizations.of(context)!.password,
                onOk: (val) async {
                  await _globalModel.setCodeSrvPwd(val);
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.setSuccess);
                },
                onCancel: () async {
                  await _globalModel.setCodeSrvPwd(null);
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.setSuccess);
                },
                defaultCancelText: '设置为无密码',
              );
            },
            child: ListTile(
              title: ThemedText(AppLocalizations.of(context)!.password),
              subtitle: ThemedText(
                _globalModel.codeSrvPwd != null
                    ? List.filled(_globalModel.codeSrvPwd!.length, null,
                            growable: false)
                        .map((e) => '*')
                        .toList()
                        .join('')
                    : 'none',
                small: true,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            title: ThemedText(AppLocalizations.of(context)!.port),
            // subtitle: ThemedText(_globalModel.codeSrvPort),
            trailing: CupertinoButton(
                child: NoResizeText('${_globalModel.codeSrvPort}'),
                onPressed: () async {
                  showSingleTextFieldModal(
                    context,
                    title: AppLocalizations.of(context)!.port,
                    placeholder: _globalModel.codeSrvPort,
                    onOk: (val) {
                      _globalModel.setCodeSrvPort(val);
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!.setSuccess);
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
              title:
                  ThemedText(AppLocalizations.of(context)!.terminalCodeServer),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          // 帮助改善vscode
          ListTile(
            title: ThemedText('Telemetry'),
            subtitle: ThemedText(AppLocalizations.of(context)!.helpCodeServer,
                small: true),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: AquaSwitch(
              value: _globalModel.codeSrvTelemetry!,
              onChanged: (val) async {
                _globalModel.setCodeSrvTelemetry(val);
              },
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          blockTitle(AppLocalizations.of(context)!.sandbox,
              subtitle: 'alpine linux'),
          SizedBox(height: 15),
          InkWell(
            child: ListTile(
              title: ThemedText(AppLocalizations.of(context)!.sandbox),
              subtitle: ThemedText(
                  rootfs.existsSync()
                      ? rootfs.path
                      : AppLocalizations.of(context)!.sandboxNotExist,
                  small: true),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          ListTile(
            title: ThemedText(AppLocalizations.of(context)!.modifyRepo),
            subtitle: ThemedText(repoChineseName(repo), small: true),
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
                    backgroundColor: themeData.menuItemColor,
                    title: ThemedText('清华'),
                    onPressed: () async {
                      await cutils
                          .setChineseRepo(TSINGHUA_REPO)
                          .then((value) async {
                        await _globalModel.setAplineRepo(TSINGHUA_REPO);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.setFail);
                      });
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData.menuItemColor,
                    title: ThemedText('阿里云'),
                    onPressed: () async {
                      await cutils
                          .setChineseRepo(ALIYUN_REPO)
                          .then((value) async {
                        await _globalModel.setAplineRepo(ALIYUN_REPO);
                        setState(() {});
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.setFail);
                      });
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData.menuItemColor,
                    title: ThemedText('中科大'),
                    onPressed: () async {
                      await cutils.setChineseRepo(USTC_REPO).then((val) async {
                        await _globalModel.setAplineRepo(USTC_REPO);
                        setState(() {});
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.setFail);
                      });
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData.menuItemColor,
                    title: ThemedText('Alpine'),
                    onPressed: () async {
                      await cutils
                          .setChineseRepo(ALPINE_REPO)
                          .then((value) async {
                        await _globalModel.setAplineRepo(ALPINE_REPO);
                        setState(() {});
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: AppLocalizations.of(context)!.setFail);
                      });
                    }),
                FocusedMenuItem(
                    backgroundColor: themeData.menuItemColor,
                    title: ThemedText(AppLocalizations.of(context)!.custom),
                    onPressed: () async {
                      await showSingleTextFieldModal(
                        context,
                        title: 'alpine',
                        onOk: (val) async {
                          await cutils.setChineseRepo(val).then((value) async {
                            await _globalModel.setAplineRepo(val);
                          }).catchError((e) {
                            Fluttertoast.showToast(
                                msg: AppLocalizations.of(context)!.setFail);
                          });
                        },
                        onCancel: () {},
                      );
                    }),
              ],
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: NoResizeText(
                  AppLocalizations.of(context)!.selectSource,
                  style: TextStyle(color: Color(0xFF007AFF)),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await cutils.clearProotTmp();
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.setSuccess);
            },
            child: ListTile(
              title: ThemedText(
                AppLocalizations.of(context)!.deleteSandboxTemp,
                style: TextStyle(color: Colors.redAccent),
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              showTipTextModal(
                context,
                title: AppLocalizations.of(context)!.deleteSandbox,
                tip: AppLocalizations.of(context)!.deleteSandboxTip,
                confirmedView: loadingIndicator(context, _themeModel),
                onOk: () async {
                  await cutils.rmAllResource().catchError((err) {
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.setFail);
                  });
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context)!.setSuccess);
                },
                onCancel: () {},
              );
            },
            child: ListTile(
              title: ThemedText(
                AppLocalizations.of(context)!.deleteSandbox,
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
          AppLocalizations.of(context)!.codeServer,
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

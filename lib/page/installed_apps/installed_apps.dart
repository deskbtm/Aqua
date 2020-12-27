import 'dart:io';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/loading_flipping.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_item.dart';

import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:intent/action.dart' as action;
import 'package:intent/intent.dart' as intent;

class InstalledAppsPage extends StatefulWidget {
  @override
  _InstalledAppsPageState createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  bool _showSystemApps = false;
  List<Application> apps = [];
  bool _mutex = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    if (_mutex) {
      _mutex = false;
      apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: _showSystemApps,
        onlyAppsWithLaunchIntent: false,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    apps = null;
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel.themeData;

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: themeData?.scaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: themeData?.navBackgroundColor,
          middle: NoResizeText(
            '本机应用',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: themeData?.navTitleColor,
            ),
          ),
          trailing: InkWell(
            onTap: () async {
              apps = null;
              if (mounted) {
                setState(() {
                  apps = [];
                  _showSystemApps = !_showSystemApps;
                });
                apps = await DeviceApps.getInstalledApplications(
                  includeAppIcons: true,
                  includeSystemApps: _showSystemApps,
                  onlyAppsWithLaunchIntent: false,
                );
                if (mounted) {
                  setState(() {});
                }
              }
            },
            child: NoResizeText(
              _showSystemApps ? '普通应用' : '系统应用',
              style: TextStyle(
                color: Color(0xFF007AFF),
              ),
            ),
          ),
          border: null,
          automaticallyImplyLeading: false,
        ),
        child: apps.isEmpty
            ? Center(
                child: LoadingDoubleFlipping.square(
                  size: 30,
                  backgroundColor: Color(0xFF007AFF),
                ),
              )
            : Scrollbar(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    Application app = apps[index];
                    File file = File(app.apkFilePath);
                    String ext = pathLib.extension(app.apkFilePath);
                    SelfFileEntity fileEntity = SelfFileEntity(
                      modified: file.statSync().modified,
                      entity: file,
                      path: app.apkFilePath,
                      filename: '${app.appName} (${app.packageName})',
                      ext: ext,
                      humanSize: '',
                      apkIcon: app is ApplicationWithIcon ? app.icon : null,
                      isDir: file.statSync().type ==
                          FileSystemEntityType.directory,
                      modeString: null,
                      type: null,
                    );

                    return Column(
                      children: <Widget>[
                        FileItem(
                          isDir: false,
                          leading: app is ApplicationWithIcon
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(app.icon),
                                  backgroundColor: Colors.white,
                                )
                              : null,
                          withAnimation: index < 15,
                          index: index,
                          subTitle: '\n版本: ${app.versionName}\n'
                              '系统应用: ${app.systemApp}\n'
                              'APK 位置: ${app.apkFilePath}\n'
                              '数据目录: ${app.dataDir}\n'
                              '安装时间: ${DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis).toString()}\n'
                              '更新时间: ${DateTime.fromMillisecondsSinceEpoch(app.updateTimeMillis).toString()}\n',
                          onLongPress: (details) async {
                            showCupertinoModal(
                              filter:
                                  ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, changeState) {
                                    return SplitSelectionModal(
                                      rightChildren: <Widget>[
                                        ActionButton(
                                          content: '卸载',
                                          onTap: () async {
                                            await showTipTextModal(
                                                context, _themeModel,
                                                title: '卸载',
                                                tip: '确定卸载${app.packageName}',
                                                onOk: () {
                                              intent.Intent()
                                                ..setAction(
                                                    action.Action.ACTION_DELETE)
                                                ..setData(Uri.parse(
                                                    "package:${app.packageName}"))
                                                ..startActivityForResult().then(
                                                  (data) {
                                                    print(data);
                                                  },
                                                  onError: (e) {
                                                    recordError(text: '$e');
                                                  },
                                                );
                                            }, onCancel: () {});
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          onTap: () {
                            DeviceApps.openApp(app.packageName);
                          },
                          subTitleSize: 12,
                          titleSize: 16,
                          autoWrap: false,
                          file: fileEntity,
                          // path: app.apkFilePath,
                          // filename: '${app.appName} (${app.packageName})',
                          onHozDrag: (dir) async {
                            if (await file.exists()) {
                              if (dir == 1) {
                                _commonModel.addSelectedFile(fileEntity);
                              } else if (dir == -1) {
                                _commonModel.removeSelectedFile(fileEntity);
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                  itemCount: apps.length,
                ),
              ),
      ),
    );
  }
}

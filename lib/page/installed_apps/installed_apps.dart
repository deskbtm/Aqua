import 'dart:io';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;

class InstalledAppsPage extends StatefulWidget {
  @override
  _InstalledAppsPageState createState() => _InstalledAppsPageState();
}

// class _InstalledAppsPageState extends State<InstalledAppsPage> {
//   bool _showSystemApps = false;
//   bool _onlyLaunchableApps = false;

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       child: _ListAppsPagesContent(
//         includeSystemApps: _showSystemApps,
//         onlyAppsWithLaunchIntent: _onlyLaunchableApps,
//       ),
//     );
//   }
// }

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  ThemeProvider _themeProvider;
  ShareProvider _shareProvider;
  bool _showSystemApps = false;
  List<Application> apps = [];
  bool locker = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    if (locker) {
      locker = false;
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
    dynamic themeData = _themeProvider.themeData;

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
            ? Center(child: loadingIndicator(context, _themeProvider))
            : Scrollbar(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    Application app = apps[index];
                    File file = File(app.apkFilePath);
                    String ext = pathLib.extension(app.apkFilePath);
                    SelfFileEntity fileEntity = SelfFileEntity(
                      modified: file.statSync().modified,
                      entity: file,
                      filename: '${app.appName} (${app.packageName})',
                      ext: ext,
                      apkIcon: app is ApplicationWithIcon ? app.icon : null,
                      isDir: file.statSync().type ==
                          FileSystemEntityType.directory,
                      modeString: null,
                      type: null,
                    );

                    return Column(
                      children: <Widget>[
                        FileItem(
                          type: FileItemType.file,
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
                          // fileEntity: file,
                          // lastModifiedTime: MixUtils.formatFileTime(file.modified),
                          onLongPress: (details) {},
                          onTap: () {
                            DeviceApps.openApp(app.packageName);
                          },
                          subTitleSize: 12,
                          titleSize: 16,
                          autoWrap: false,
                          path: app.apkFilePath,
                          filename: '${app.appName} (${app.packageName})',
                          onHozDrag: (dir) async {
                            if (await file.exists()) {
                              if (dir == 1) {
                                _shareProvider.addFile(fileEntity);
                              } else if (dir == -1) {
                                _shareProvider.removeFile(fileEntity);
                              }
                            }
                          },
                        ),
                        // ),
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

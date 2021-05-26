import 'dart:io';
import 'dart:ui';

import 'package:aqua/utils/mix_utils.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/loading_flipping.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/page/file_manager/file_item.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InstalledAppsPage extends StatefulWidget {
  @override
  _InstalledAppsPageState createState() => _InstalledAppsPageState();
}

class _InstalledAppsPageState extends State<InstalledAppsPage> {
  late ThemeModel _themeModel;
  late CommonModel _commonModel;
  bool _showSystemApps = false;
  List<Application>? _apps = [];
  bool _mutex = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    if (_mutex) {
      _mutex = false;
      _apps = await DeviceApps.getInstalledApplications(
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
    _apps = null;
  }

  Future<void> showAppActions(Application app) async {
    showCupertinoModal(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, changeState) {
            return SplitSelectionModal(
              rightChildren: <Widget>[
                ActionButton(
                  content: AppLocalizations.of(context)!.uninstall,
                  onTap: () async {
                    await showTipTextModal(
                      context,
                      title: AppLocalizations.of(context)!.uninstall,
                      tip:
                          '${AppLocalizations.of(context)!.uninstall} ${app.packageName}?',
                      onOk: () {
                        // intent.Intent()
                        //   ..setAction(
                        //       action.Action.ACTION_DELETE)
                        //   ..setData(Uri.parse(
                        //       "package:${app.packageName}"))
                        //   ..startActivityForResult().then(
                        //     (data) {
                        //       print(data);
                        //     },
                        //     onError: (e) {},
                        //   );
                      },
                      onCancel: () {},
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: themeData.navBackgroundColor,
          middle: NoResizeText(
            '本机应用',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: themeData.navTitleColor,
            ),
          ),
          trailing: InkWell(
            onTap: () async {
              _apps = null;
              if (mounted) {
                setState(() {
                  _apps = [];
                  _showSystemApps = !_showSystemApps;
                });
                _apps = await DeviceApps.getInstalledApplications(
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
        child: _apps!.isEmpty
            ? Center(
                child: LoadingDoubleFlipping.square(
                  size: 30,
                  backgroundColor: Color(0xFF007AFF),
                ),
              )
            : Scrollbar(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    Application app = _apps![index];
                    File file = File(app.apkFilePath);
                    FileStat stat = file.statSync();
                    String ext = pathLib.extension(app.apkFilePath);
                    SelfFileEntity fileEntity = SelfFileEntity(
                      modified: file.statSync().modified,
                      entity: file,
                      path: app.apkFilePath,
                      filename: '${app.appName} (${app.packageName})',
                      ext: ext,
                      apkIcon: app is ApplicationWithIcon ? app.icon : null,
                      isDir: file.statSync().type ==
                          FileSystemEntityType.directory,
                      modeString: stat.modeString(),
                      type: stat.type,
                      accessed: stat.accessed,
                      changed: stat.changed,
                      humanSize:
                          MixUtils.humanStorageSize(stat.size.toDouble()),
                      isFile: stat.type == FileSystemEntityType.file,
                      isLink: stat.type == FileSystemEntityType.link,
                      pureName: '',
                      size: stat.size,
                      mode: stat.mode,
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
                          subTitle:
                              '\n${AppLocalizations.of(context)!.version}: ${app.versionName}\n'
                              '${AppLocalizations.of(context)!.sysApps}: ${app.systemApp}\n'
                              'APK ${AppLocalizations.of(context)!.position}: ${app.apkFilePath}\n'
                              '${AppLocalizations.of(context)!.dataDir}: ${app.dataDir}\n'
                              '${AppLocalizations.of(context)!.installTimestamp}: ${DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis).toString()}\n'
                              '${AppLocalizations.of(context)!.updateTimestamp}: ${DateTime.fromMillisecondsSinceEpoch(app.updateTimeMillis).toString()}\n',
                          onLongPress: (details) async {
                            showAppActions(app);
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
                  itemCount: _apps!.length,
                ),
              ),
      ),
    );
  }
}

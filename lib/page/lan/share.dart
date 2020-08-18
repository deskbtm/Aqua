import 'dart:io';

import 'package:android_mix/android_mix.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_express/common/widget/images.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/external/menu/menu.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/page/file_manager/file_item.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/device.dart';
import 'package:lan_express/provider/share.dart';
import 'package:lan_express/provider/theme.dart';

import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/web/web_handler.dart';
import 'package:provider/provider.dart';
import 'package:shelf/shelf_io.dart' as shelf;

class StaticSharePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StaticSharePageState();
  }
}

class _StaticSharePageState extends State<StaticSharePage> {
  ThemeProvider _themeProvider;
  ShareProvider _shareProvider;
  NativeProvider _nativeProvider;
  CommonProvider _commonProvider;
  bool _shareSwitch;
  HttpServer _server;

  @override
  void initState() {
    super.initState();
    _shareSwitch = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _shareProvider = Provider.of<ShareProvider>(context);
    _nativeProvider = Provider.of<NativeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);

    if (mounted) {
      setState(() {});
    }
  }

  moreThanOneDir() {}

  Future<void> createStaticServer() async {
    var handler;
    if (_shareProvider.selectedFiles.isNotEmpty) {
      SelfFileEntity first = _shareProvider.selectedFiles.first;
      if (first.isDir) {
        handler =
            createWebHandler(first.entity.path, isDark: _themeProvider.isDark);
      } else {
        handler = createFilesHandler(
            _shareProvider.selectedFiles.map((e) => e.entity.path).toList(),
            isDark: _themeProvider.isDark);
      }
    } else {
      handler = createWebHandler(_nativeProvider.externalStorageRootPath,
          isDark: _themeProvider.isDark);
    }

    if (_shareSwitch) {
      BotToast.showText(
          text: '开始共享', contentColor: _themeProvider?.themeData?.toastColor);
      _server = await shelf.serve(
          handler, _commonProvider?.internalIp, _commonProvider?.staticPort);
      debugPrint('Serving at http://${_server.address.host}:${_server.port}');
    } else {
      _server?.close();
      BotToast.showText(
          text: '共享关闭', contentColor: _themeProvider?.themeData?.toastColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    String internalIp = _commonProvider?.internalIp;
    int staticPort = _commonProvider?.staticPort;
    String firstAliveIp = _commonProvider.aliveIps.isNotEmpty
        ? '${_commonProvider.aliveIps.first}:${_commonProvider.expressPort}'
        : '暂未连接';

    // print(_commonProvider.aliveIps);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            flex: 1,
            child: Scrollbar(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 1,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      ListTile(
                        title: LanText('静态文件服务'),
                        subtitle:
                            LanText('$internalIp: $staticPort', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        trailing: LanSwitch(
                          value: _shareSwitch,
                          onChanged: (val) async {
                            if (mounted) {
                              setState(() {
                                _shareSwitch = !_shareSwitch;
                              });
                            }
                            await createStaticServer().catchError((err) {
                              FLog.error(
                                  text: err.toString(),
                                  methodName: 'createStaticServer');
                              debugPrint(err);
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: LanText('VScode Server'),
                        subtitle:
                            LanText('$internalIp: $staticPort', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        trailing: LanSwitch(
                          value: _shareSwitch,
                          onChanged: (val) async {
                            String root = await AndroidMix
                                .storage.getExternalStorageDirectory;
                            AndroidMix.archive
                                .zip([root + '/AcFun'], root + '/AcFun.zip',
                                    onZip: (a) {
                              print(a);
                            }, onZipSuccess: () {
                              print('dsadsadas');
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: LanText('快递服务'),
                        subtitle: LanText('$firstAliveIp', small: true),
                        contentPadding: EdgeInsets.only(left: 15, right: 10),
                        trailing: FocusedMenuHolder(
                          menuWidth: MediaQuery.of(context).size.width * 0.30,
                          blurSize: 5.0,
                          menuItemExtent: 45,
                          // blurBackgroundColor: Colors.red,
                          duration: Duration(milliseconds: 100),
                          animateMenuItems: true,
                          menuOffset:
                              10.0, // Offset value to show menuItem from the selected item
                          bottomOffsetHeight:
                              80.0, // Offset height to consider, for showing the menu item ( for example bottom navigation bar), so that the popup menu will be shown on top of selected item.
                          menuItems: <FocusedMenuItem>[
                            // Add Each FocusedMenuItem  for Menu Options
                            FocusedMenuItem(
                                title: Text("Open"),
                                // trailingIcon: Icon(Icons.open_in_new),
                                onPressed: (index, value) {}),
                            FocusedMenuItem(
                                title: Text("Share"),
                                // trailingIcon: Icon(Icons.share),
                                onPressed: (index, value) {}),
                            FocusedMenuItem(
                                title: Text("Favorite"),
                                // trailingIcon: Icon(Icons.favorite_border),
                                onPressed: (index, value) {}),
                          ],
                          // onPressed: (index, a) {},
                          child: Container(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: NoResizeText(
                              '全部',
                              style: TextStyle(color: Color(0xFF007AFF)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _shareProvider.selectedFiles.isEmpty
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.share,
                        size: 57,
                      ),
                      SizedBox(height: 20),
                      LanText('默认分享根目录', alignX: 0, fontSize: 14)
                    ],
                  ))
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _shareProvider.selectedFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      SelfFileEntity file =
                          _shareProvider.selectedFiles.elementAt(index);

                      Widget previewIcon = getPreViewIcon(file);

                      return Dismissible(
                        key: ObjectKey(file),
                        onDismissed: (direction) {
                          _shareProvider.selectedFiles.remove(file);
                        },
                        child: FileItem(
                          type: FileItemType.file,
                          leading: previewIcon,
                          withAnimation: index < 15,
                          index: index,
                          subTitle: MixUtils.formatFileTime(file.modified),
                          justDisplay: true,
                          filename: file.filename,
                          path: file.entity.path,
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}

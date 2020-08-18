import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/page/file_manager/file_manager.dart';
import 'package:lan_express/page/lan/lan.dart';
import 'package:lan_express/page/setting/setting.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;
    return themeData == null
        ? Container()
        : CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              onTap: (index) {},
              backgroundColor: themeData.bottomNavColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  title: NoResizeText("文件"),
                  icon: Icon(Icons.folder),
                ),
                BottomNavigationBarItem(
                  title: NoResizeText("网络"),
                  icon: Icon(Icons.laptop),
                ),
                BottomNavigationBarItem(
                  title: NoResizeText("设置"),
                  icon: Icon(Icons.settings),
                )
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return CupertinoTabView(
                    builder: (context) => FileManagerPage(),
                  );
                case 1:
                  return CupertinoTabView(
                    builder: (context) => LanPage(),
                  );
                case 2:
                  return CupertinoTabView(
                    builder: (context) => SettingPage(),
                  );
                default:
                  assert(false, 'Unexpected tab');
                  return null;
              }
            },
          );
  }
}

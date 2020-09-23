import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:provider/provider.dart';

class ExpressSettingPage extends StatefulWidget {
  final CodeSrvUtils cutils;

  const ExpressSettingPage({Key key, this.cutils}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ExpressSettingPageState();
  }
}

class ExpressSettingPageState extends State<ExpressSettingPage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;

    List<Widget> settingList = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          ListTile(
            title: LanText('自动连接常用IP'),
            subtitle: LanText('发现多个IP 不会弹出选择框'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonProvider.enableAutoConnectCommonIp,
              onChanged: (val) async {
                _commonProvider.setEnableAutoConnectCommonIp(val);
              },
            ),
          ),
          ListTile(
            title: LanText('常用IP列表'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '控制',
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

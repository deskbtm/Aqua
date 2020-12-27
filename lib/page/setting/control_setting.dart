import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/switch.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/page/lan/code_server/utils.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:provider/provider.dart';

class ControlSettingPage extends StatefulWidget {
  final CodeSrvUtils cutils;

  const ControlSettingPage({Key key, this.cutils}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ControlSettingPageState();
  }
}

class ControlSettingPageState extends State<ControlSettingPage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  void showText(String content) {
    BotToast.showText(
      text: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel?.themeData;

    List<Widget> settingList = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          ListTile(
            title: LanText('触摸震动'),
            subtitle: LanText('触摸按钮震动反馈'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonModel.codeSrvTelemetry,
              onChanged: (val) async {
                _commonModel.setCodeSrvTelemetry(val);
              },
            ),
          ),
          InkWell(
            onTap: () async {},
            child: ListTile(
              title: LanText('按键映射表'),
              contentPadding: EdgeInsets.only(left: 15, right: 25),
            ),
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

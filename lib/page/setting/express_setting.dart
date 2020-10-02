import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/common/widget/switch.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/model/common.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/model/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
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
            title: LanText('自动搜索常用IP'),
            subtitle: LanText('多台PC设备 3s后自动选择 弹窗消失'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: LanSwitch(
              value: _commonProvider.enableAutoConnectCommonIp,
              onChanged: (val) async {
                _commonProvider.setEnableAutoConnectCommonIp(val);
              },
            ),
          ),
          InkWell(
            onTap: () async {
              List<MapEntry<dynamic, dynamic>> ipStatistics =
                  _commonProvider.commonIps.entries.toList();
              List<Widget> ipStatisticsWidget = ipStatistics.isEmpty
                  ? [
                      Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          alignment: Alignment.center,
                          child: NoResizeText('暂无连接',
                              style: TextStyle(color: Color(0xFF007AFF))))
                    ]
                  : ipStatistics
                      .map(
                        (e) => Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: themeData.itemColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              NoResizeText(
                                '${e.key}',
                                style:
                                    TextStyle(color: themeData.itemFontColor),
                              ),
                              NoResizeText(
                                '${e.value}',
                                style:
                                    TextStyle(color: themeData.itemFontColor),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList();

              showSelectModal(
                context,
                _themeProvider,
                title: '常用IP列表',
                subTitle: '长按移除',
                options: ipStatisticsWidget,
                leadingList: ipStatistics.isEmpty
                    ? null
                    : <Widget>[
                        Container(
                          padding:
                              EdgeInsets.only(top: 10, bottom: 10, left: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              NoResizeText(
                                'IP',
                                style: TextStyle(color: Color(0xFF007AFF)),
                              ),
                              NoResizeText(
                                '连接次数',
                                style: TextStyle(color: Color(0xFF007AFF)),
                              )
                            ],
                          ),
                        )
                      ],
                onLongPressDeleteItem: (index, tmpOptions) {
                  _commonProvider.removeFromCommonIps(ipStatistics[index].key);
                },
              );
            },
            child: ListTile(
              title: LanText('常用IP列表'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          )
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '内网传输更多',
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

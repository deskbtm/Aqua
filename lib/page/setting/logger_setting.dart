import 'package:android_mix/android_mix.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/model/common.dart';
import 'package:lan_express/page/lan/code_server/utils.dart';
import 'package:lan_express/model/theme.dart';
import 'package:provider/provider.dart';

class LoggerSettingPage extends StatefulWidget {
  final CodeSrvUtils cutils;

  const LoggerSettingPage({Key key, this.cutils}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LoggerSettingPageState();
  }
}

class LoggerSettingPageState extends State<LoggerSettingPage> {
  ThemeProvider _themeProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
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
          InkWell(
            onTap: () async {
              final MailOptions mailOptions = MailOptions(
                body: (await FLog.getAllLogs())
                    .map((e) => e.text)
                    .toList()
                    .join(''),
                subject: '局域网.文件.更多 日志',
                recipients: ['wanghan9423@outlook.com'],
                isHTML: false,
              );

              await FlutterMailer.send(mailOptions);
            },
            child: ListTile(
              title: LanText('发送日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.clearLogs();
              showText('删除完成');
            },
            child: ListTile(
              title: LanText('删除日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
          InkWell(
            onTap: () async {
              await FLog.exportLogs();
              String externalDir = await AndroidMix.storage.getStorageDirectory;
              showText('日志导出至: $externalDir');
            },
            child: ListTile(
              title: LanText('导出日志'),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
            ),
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '日志',
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

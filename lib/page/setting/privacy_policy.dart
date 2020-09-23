import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/bot_toast.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/req.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PrivacyPolicyPageState();
  }
}

class PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
  bool _mutex;
  String _html;

  @override
  void initState() {
    super.initState();
    _mutex = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    if (_mutex) {
      try {
        dio.Response res =
            await req().get(_commonProvider.baseUrl + '/assets/privacy.html');
        if (res.data != null) {
          setState(() {
            _html = res.data;
          });
        }
      } catch (e) {
        showText('隐私政策加载失败');
      }
    }
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeProvider.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider?.themeData;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '隐私政策',
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
      child: _html == null
          ? Center(child: loadingIndicator(context, _themeProvider))
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Html(
                  data: _html,
                  onLinkTap: (url) async {
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      showText('链接打开失败');
                      FLog.error(text: 'privacy policy url');
                    }
                  },
                );
              },
            ),
    );
  }
}

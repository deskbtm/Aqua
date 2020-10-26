import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/external/bot_toast/bot_toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/error.dart';
import 'package:lan_file_more/utils/req.dart';
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
  ThemeModel _themeModel;
  CommonModel _commonModel;
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
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    if (_mutex) {
      try {
        dio.Response res =
            await req().get(_commonModel.baseUrl + '/assets/privacy.html');
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
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel?.themeData;

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
          ? Center(child: loadingIndicator(context, _themeModel))
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
                      recordError(text: 'privacy policy url');
                    }
                  },
                );
              },
            ),
    );
  }
}

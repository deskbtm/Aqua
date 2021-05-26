import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/common/widget/no_resize_text.dart';

import 'package:aqua/model/theme_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:aqua/utils/req.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late ThemeModel _themeModel;
  late bool _mutex;
  late String _html;

  @override
  void initState() {
    super.initState();
    _mutex = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    if (_mutex) {
      try {
        dio.Response res = await req().get('/assets/privacy.html');
        if (res.data != null) {
          setState(() {
            _html = res.data;
          });
        }
      } catch (e) {
        Fluttertoast.showToast(msg: AppLocalizations.of(context)!.privacyError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel?.themeData;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          AppLocalizations.of(context)!.privacyProtocol,
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
                return Container();

                //  Html(
                //   data: _html,
                //   onLinkTap: (url) async {
                //     if (await canLaunch(url)) {
                //       await launch(url);
                //     } else {
                //       showText(AppLocalizations.of(context)!.setFail);
                //     }
                //   },
                // );
              },
            ),
    );
  }
}

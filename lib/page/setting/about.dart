import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/constant/constant.dart';

import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/setting/privacy_policy.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutPageState();
  }
}

class _AboutPageState extends State<AboutPage> {
  late ThemeModel _themeModel;
  late CommonModel _commonModel;
  late String _version;
  late bool _locker;
  late String _qqGroupNumber;
  late String _qqGroupKey;
  late String _authorEmail;
  late String _authorAvatar;

  @override
  void initState() {
    super.initState();
    _version = '';
    _locker = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);

    if (_commonModel.gWebData.isNotEmpty) {
      _authorEmail = _commonModel.gWebData['mobile']['config']['author_email'];
      _qqGroupNumber =
          _commonModel.gWebData['mobile']['config']['qq_group_num'];
      _qqGroupKey = _commonModel.gWebData['mobile']['config']['qq_group_key'];
      _authorAvatar =
          _commonModel.gWebData['mobile']['config']['author_avatar'];
    } else {
      _authorEmail = DEFAULT_AUTHOR_EMAIL;
      _qqGroupNumber = DEFAULT_QQ_GROUP_NUM;
      _qqGroupKey = DEFAULT_QQ_GROUP_KEY;
      _authorAvatar = DEFAULT_AUTHOR_AVATAR;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_locker) {
      _locker = false;
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        backgroundColor: themeData?.navBackgroundColor,
        border: null,
        middle: NoResizeText(
          '关于',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData?.navTitleColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ThemedText('Aqua', fontSize: 18),
                              ThemedText(
                                  '${AppLocalizations.of(context)!.version}: v$_version',
                                  small: true),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                    return PrivacyPolicyPage();
                                  },
                                ),
                              );
                            },
                            child: ListTile(
                              title: ThemedText(AppLocalizations.of(context)!
                                  .privacyProtocol),
                              contentPadding:
                                  EdgeInsets.only(left: 15, right: 10),
                              trailing: FaIcon(FontAwesomeIcons.chevronRight),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              String url =
                                  "mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26jump_from%3Dwebapi%26k%3D$_qqGroupKey";
                              if (await canLaunch(url)) {
                                launch(url);
                              }
                            },
                            child: ListTile(
                              title: ThemedText(
                                  AppLocalizations.of(context)!.concat),
                              subtitle: ThemedText(
                                'QQ: $_qqGroupNumber',
                                small: true,
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 15, right: 10),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (await canLaunch(GITHUB)) {
                                launch(GITHUB);
                              }
                            },
                            child: ListTile(
                              title: ThemedText('Github'),
                              subtitle: ThemedText(
                                GITHUB,
                                small: true,
                              ),
                              contentPadding:
                                  EdgeInsets.only(left: 15, right: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  height: 20,
                  decoration: BoxDecoration(color: themeData.divideColor),
                ),
                Container(
                  // padding: EdgeInsets.only(left: 10, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          child: ClipOval(
                            child: Image.network(
                              _authorAvatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: ThemedText('maxcalibur'),
                        subtitle: ThemedText('develop&design', small: true),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: _authorEmail));
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.copied);
                              },
                              child: NoResizeText('Email: $_authorEmail'),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: 'maxcalibur9423'),
                                );
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.copied);
                              },
                              child: NoResizeText('wechat: maxcalibur9423'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

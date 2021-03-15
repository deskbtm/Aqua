import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/external/bot_toast/src/toast.dart';
import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PurchasePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PurchasePageState();
  }
}

class _PurchasePageState extends State<PurchasePage> {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  void showText(String content, {int duration = 4}) {
    BotToast.showText(
      text: content,
      duration: Duration(seconds: duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '购买',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: themeData?.navTitleColor,
          ),
        ),
        backgroundColor: themeData?.navBackgroundColor,
        border: null,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return StatefulBuilder(
                builder: (context, changeState) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 50),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    LanText('Aqua', fontSize: 18),
                                    SizedBox(width: 4),
                                  ],
                                ),
                                LanText(
                                    _commonModel.isPurchased
                                        ? AppLocalizations.of(context)
                                            .hasSponsored
                                        : AppLocalizations.of(context)
                                            .notSponsored,
                                    small: true),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              LanText(
                                AppLocalizations.of(context).hasSponsoredUsers,
                                fontSize: 22,
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.code,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText(
                                    'Code Server(${AppLocalizations.of(context).experiment})'),
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.favoriteBorder,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText(AppLocalizations.of(context)
                                    .continuousUpdate),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Image.asset('assets/images/alipay.jpg'),
                            ),
                            Expanded(
                              flex: 1,
                              child: Image.asset('assets/images/wechat_pay.jpg'),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 30),
                            CupertinoButton(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Color(0xFF007AFF),
                              child: NoResizeText('直接跳转支付'),
                              onPressed: () async {
                                if (await canLaunch(AUTHOR_ALIPAY)) {
                                  await launch(AUTHOR_ALIPAY);
                                } else {
                                  showText('链接打开失败');
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            CupertinoButton(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              child: NoResizeText('关注知乎'),
                              color: Color(0xFF007AFF),
                              onPressed: () async {
                                if (await canLaunch(ZHIHU_SPACE)) {
                                  await launch(ZHIHU_SPACE);
                                } else {
                                  showText('链接打开失败');
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            CupertinoButton(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              child: NoResizeText('关注bilibili'),
                              color: Color(0xFFFB7299),
                              onPressed: () async {
                                if (await canLaunch(BILIBILI_SPACE)) {
                                  await launch(BILIBILI_SPACE);
                                } else {
                                  showText('链接打开失败');
                                }
                              },
                            ),
                            CupertinoButton(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              child: NoResizeText('设置为赞助状态'),
                              onPressed: () async {
                                _commonModel.setPurchase(true);
                              },
                            ),
                            SizedBox(height: 40),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

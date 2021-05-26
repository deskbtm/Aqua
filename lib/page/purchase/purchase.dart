import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/constant/constant.dart';
import 'package:aqua/constant/constant_var.dart';

import 'package:aqua/model/common_model.dart';
import 'package:aqua/model/theme_model.dart';

import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/req.dart';
import 'package:aqua/utils/store.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';

class PurchasePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PurchasePageState();
  }
}

class _PurchasePageState extends State<PurchasePage> {
  late ThemeModel _themeModel;
  late CommonModel _commonModel;
  late Map _qrcodeData;
  late bool _mutex;

  @override
  void initState() {
    super.initState();
    _qrcodeData = {'data': {}};
    _mutex = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
    if (_commonModel.username != null) {
      if (_mutex) {
        _mutex = false;
        _qrcodeData = await _fetchQrcode();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  Future<Map> _followBilibiliStatus(val) async {
    Response rec = await req().post('/user/follow_bilibili', data: {
      'uid': val,
    }).catchError((err) {
      Fluttertoast.showToast(msg: '请求失败');
    });
    if (rec.data['data'] != null) {
      Fluttertoast.showToast(msg: rec.data['message']);
      if (rec.data['data']['isFollowing']) {
        _qrcodeData = await _fetchQrcode();
        if (mounted) {
          setState(() {});
        }
      }
    }
    return rec.data['data'] ?? {};
  }

  Future<Map> _fetchQrcode() async {
    Response rec = await req().get('/pay/qrcode', queryParameters: {
      'app_name': APP_NAME,
      'android_id': await MixUtils.getAndroidId(),
    }).catchError((err) {
      Fluttertoast.showToast(msg: '登录失败');
    });
    return rec.data['data'] ?? {'data': {}};
  }

  Uint8List? loadQrcode() {
    if (_qrcodeData['qrcode'] != null) {
      List s = (_qrcodeData['qrcode'] as String).split(',');
      if (s != null) {
        return base64Decode(s[1]);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Widget activeButton(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoButton(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: NoResizeText('激活'),
            color: Color(0xFF007AFF),
            onPressed: () async {
              await req().post('/pay/active', data: {
                'app_name': APP_NAME,
                ...?(await MixUtils.deviceInfo()),
              }).then((value) {
                dynamic data = value.data;
                if (data['data'] != null) {
                  if (data['data']['purchased']) {
                    _commonModel.setPurchase(true);
                    Fluttertoast.showToast(msg: '购买成功, 即将前往下载pc端');

                    MixUtils.safePop(context);

                    Timer(Duration(seconds: 1), () async {
                      String url;
                      if (_commonModel.gWebData['pc'] == null) {
                        url = PC_BAK_DOWNLOAD_URL;
                      } else {
                        url = _commonModel.gWebData['pc']['latest']['url'];
                      }

                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        Fluttertoast.showToast(msg: '链接打开失败');
                      }
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: MixUtils.webMessage(data['message']));
                  }
                }
              }).catchError((err) {
                Fluttertoast.showToast(msg: '激活失败');
              });
            },
          ),
        ],
      );

  Widget _followBilibiliButton(ThemeModel provider) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoButton(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: NoResizeText(
                '关注bilibili 可享${_qrcodeData['favour'] ?? DEF_FAVOUR}元优惠'),
            padding: EdgeInsets.only(left: 20, right: 20),
            color: Color(0xFFFB7299),
            onPressed: () async {
              await showSingleTextFieldModal(
                context,
                title: '确认关注',
                tip: '个人主页 详情按钮 长按复制',
                defaultCancelText: '跳转bilibili',
                placeholder: 'uid',
                onOk: _followBilibiliStatus,
                onCancel: () async {
                  if (await canLaunch(BILIBILI_SPACE)) {
                    await launch(BILIBILI_SPACE);
                  } else {
                    Fluttertoast.showToast(msg: '链接打开失败');
                  }
                },
              );
            },
          ),
        ],
      );

  Widget payButton() => CupertinoButton(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: NoResizeText('直接跳转支付'),
        padding: EdgeInsets.only(left: 20, right: 20),
        color: Color(0xFF007AFF),
        onPressed: () async {
          String url =
              'alipayqr://platformapi/startapp?saId=10000007&qrcode=${_qrcodeData['details']['alipay_trade_precreate_response']['qr_code']}';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            Fluttertoast.showToast(msg: '链接打开失败');
          }
        },
      );

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
            color: themeData.navTitleColor,
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
                                    ThemedText('IOS管理器', fontSize: 18),
                                    SizedBox(width: 4),
                                    ThemedText('for developer', fontSize: 12),
                                  ],
                                ),
                                ThemedText(
                                    _commonModel.isPurchased ? '已购买' : '暂未购买',
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
                              ThemedText(
                                '普通用户',
                                fontSize: 22,
                              ),
                              ListTile(
                                leading: FaIcon(
                                  FontAwesomeIcons.user,
                                  color: themeData.topNavIconColor,
                                ),
                                title: ThemedText('免费使用大部功能'),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ThemedText(
                                    '付费用户',
                                    fontSize: 22,
                                  ),
                                  CupertinoButton(
                                    onPressed: () async {
                                      await _commonModel.setPurchase(true);
                                      Fluttertoast.showToast(
                                          msg: '无限试用 但每次使用都需要重新操作');
                                    },
                                    child: NoResizeText('点击试用'),
                                  ),
                                ],
                              ),
                              ListTile(
                                leading: FaIcon(
                                  FontAwesomeIcons.code,
                                  color: themeData.topNavIconColor,
                                ),
                                title: ThemedText('Code Server(不稳定)'),
                              ),
                              ListTile(
                                leading: FaIcon(
                                  FontAwesomeIcons.heart,
                                  color: themeData.topNavIconColor,
                                ),
                                title: ThemedText('对作者的支持'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        if (_qrcodeData.isNotEmpty &&
                            _qrcodeData['purchased'] == false) ...[
                          ThemedText(
                            '立刻购买(${_qrcodeData['amount'] ?? DEF_AMOUNT}￥)',
                            fontSize: 22,
                          ),
                          SizedBox(height: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: loadQrcode() != null
                                    ? Image.memory(
                                        loadQrcode()!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                              ),
                              ThemedText(
                                '仅支持支付宝',
                                alignX: 0,
                                small: true,
                              ),
                              ThemedText(
                                '单号: ${_qrcodeData['details']['alipay_trade_precreate_response']['out_trade_no']}',
                                alignX: 0,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 60,
                              ),
                              SizedBox(height: 10),
                              ThemedText(
                                '或',
                                fontSize: 22,
                                alignX: 0,
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  payButton(),
                                  _followBilibiliButton(_themeModel)
                                ],
                              ),
                              SizedBox(height: 10),
                              ThemedText(
                                '请在支付后激活',
                                alignX: 0,
                                fontSize: 20,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ThemedText('激活', fontSize: 22),
                          activeButton(context),
                        ],
                        if (_qrcodeData.isNotEmpty &&
                            _qrcodeData['purchased'] == true) ...[
                          ThemedText(
                            '你已经拥有此软件, 请手动激活',
                            fontSize: 20,
                          ),
                          SizedBox(height: 10),
                          activeButton(context),
                        ],
                        if (_commonModel.username == null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ThemedText(
                                '立刻购买(${_qrcodeData['amount'] ?? DEF_AMOUNT}￥)',
                                fontSize: 22,
                              ),
                              ThemedText('登录后显示优惠'),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              CupertinoButton(
                                child: NoResizeText('登录'),
                                onPressed: () async {
                                  await showTwoTextFieldModal(
                                    context,
                                    fPlaceholder: '邮箱',
                                    sPlaceholder: '密码',
                                    title: '登录',
                                    onOk: (f, s) async {
                                      if (f == '' && s == '') {
                                        Fluttertoast.showToast(msg: '邮箱密码不为空');
                                        return;
                                      }
                                      if (!MixUtils.isEmail(f)) {
                                        Fluttertoast.showToast(msg: '邮箱格式不正确');
                                        return;
                                      }
                                      if (!MixUtils.isPassword(s)) {
                                        Fluttertoast.showToast(msg: '密码格式不正确');
                                        return;
                                      }

                                      await req().post('/user/login', data: {
                                        'username': f.trim(),
                                        'password': s.trim()
                                      }).then((value) async {
                                        dynamic data = value.data;
                                        Fluttertoast.showToast(
                                            msg: '${data['message']}');
                                        if (data['data']['access_token'] !=
                                            null) {
                                          // 如果注册 存jwt 否则 二位码无法请求
                                          await Store.setString(LOGIN_TOKEN,
                                              data['data']['access_token']);
                                          await _commonModel.setUsernameGlobal(
                                              data['data']['username']);
                                        }
                                      }).catchError((err) {
                                        Fluttertoast.showToast(msg: '登录失败');
                                      });
                                    },
                                  );
                                },
                              ),
                              CupertinoButton(
                                child: NoResizeText('注册'),
                                onPressed: () async {
                                  await showTwoTextFieldModal(
                                    context,
                                    fPlaceholder: '使用邮箱',
                                    sPlaceholder: '密码(数字加英文)',
                                    title: '注册',
                                    onOk: (String f, String s) async {
                                      if (f == '' && s == '') {
                                        Fluttertoast.showToast(msg: '邮箱密码不为空');
                                        return;
                                      }
                                      if (!MixUtils.isEmail(f)) {
                                        Fluttertoast.showToast(msg: '邮箱格式不正确');
                                        return;
                                      }
                                      if (!MixUtils.isPassword(s)) {
                                        Fluttertoast.showToast(msg: '密码格式不正确');
                                        return;
                                      }
                                      await req().post('/user/register', data: {
                                        'username': f.trim(),
                                        'password': s.trim(),
                                        ...?(await MixUtils.deviceInfo()),
                                      }).then((value) {
                                        dynamic data = value.data;
                                        Fluttertoast.showToast(
                                            msg: MixUtils.webMessage(
                                                data['message']));
                                      }).catchError((err) {
                                        Fluttertoast.showToast(msg: '注册出错');
                                      });
                                    },
                                    onCancel: () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                        Column(
                          children: [
                            SizedBox(height: 10),
                            CupertinoButton(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Color(0xFF007AFF),
                              child: NoResizeText('打赏'),
                              onPressed: () async {
                                if (await canLaunch(AUTHOR_ALIPAY)) {
                                  await launch(AUTHOR_ALIPAY);
                                } else {
                                  Fluttertoast.showToast(msg: '链接打开失败');
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            NoResizeText('打赏大于等于购买价, 可直接联系本人激活')
                          ],
                        ),
                        SizedBox(height: 20),
                        ThemedText('注意', fontSize: 22),
                        SizedBox(height: 10),
                        ThemedText(
                          '1. 已经购买过的直接登录',
                        ),
                        ThemedText(
                          '2. 购买完成返回pc端下载链接',
                        ),
                        ThemedText(
                          '3. 务必记住用户名,密码',
                        ),
                        ThemedText(
                          '4. 每个账号只支持两台设备',
                        ),
                        ThemedText(
                          '5. 如果更换设备, 联系我',
                        ),
                        SizedBox(height: 20),
                        ThemedText('其他', fontSize: 22),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            CupertinoButton(
                              child: NoResizeText('复制android_id到剪贴板'),
                              onPressed: () async {
                                String id = await MixUtils.getAndroidId();
                                await Clipboard.setData(
                                    ClipboardData(text: id));
                                Fluttertoast.showToast(msg: '复制成功 $id');
                              },
                            )
                          ],
                        )
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

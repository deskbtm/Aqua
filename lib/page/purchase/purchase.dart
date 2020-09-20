import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/common/widget/show_modal.dart';
import 'package:lan_express/constant/constant.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/provider/common.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:lan_express/utils/mix_utils.dart';
import 'package:lan_express/utils/req.dart';
import 'package:lan_express/utils/store.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchasePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PurchasePageState();
  }
}

class PurchasePageState extends State<PurchasePage> {
  ThemeProvider _themeProvider;
  CommonProvider _commonProvider;
  Map _qrcodeData = {};
  bool _mutex = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeProvider = Provider.of<ThemeProvider>(context);
    _commonProvider = Provider.of<CommonProvider>(context);
    if (_commonProvider.username != null) {
      if (mounted) {
        _qrcodeData = await fetchQrcode();
        if (_qrcodeData.isNotEmpty) {
          if (_mutex) {
            _mutex = false;
            // await _commonProvider.setPurchase(true);
          }
        }
        setState(() {});
      }
    }
  }

  Future<Map> fetchQrcode() async {
    Response rec = await req()
        .get(_commonProvider.baseUrl + '/pay/qrcode', queryParameters: {
      'app_name': APP_NAME,
      'device_id': await MixUtils.getAndroidId(),
    }).catchError((err) {
      showText('登录失败');
      FLog.error(text: '$err');
    });
    return rec?.data;
  }

  void showText(String content, {int duration = 4}) {
    BotToast.showText(
      text: content,
      contentColor: _themeProvider.themeData?.toastColor,
      duration: Duration(seconds: duration),
    );
  }

  Uint8List loadQrcode() {
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

  Widget activeButton() => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoButton(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: NoResizeText('激活'),
            color: Color(0xFF007AFF),
            onPressed: () async {
              await req().get(_commonProvider.baseUrl + '/pay/own_app',
                  queryParameters: {
                    'app_name': APP_NAME,
                    'device_id': await MixUtils.getAndroidId(),
                  }).then((value) {
                dynamic data = value.data;
                if (data['purchased']) {
                  _qrcodeData = {};
                  _commonProvider.setPurchase(true);
                  showText('购买成功');
                } else {
                  String msg;
                  if (data['message'] is List) {
                    msg = (data['message'] as List).join(',');
                  } else {
                    msg = data['message'];
                  }
                  showText('$msg 未购买');
                }
              });
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeProvider.themeData;
    String baseUrl = _commonProvider.baseUrl;

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
                                LanText('局域网.文件.更多', fontSize: 18),
                                LanText(
                                    _commonProvider.isPurchased
                                        ? '已购买'
                                        : '暂未购买',
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
                                '普通的用户',
                                fontSize: 22,
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.people,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText('免费使用大部功能'),
                              ),
                              SizedBox(height: 10),
                              LanText(
                                '付费用户',
                                fontSize: 22,
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.code,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText('Code Server'),
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.cloudUpload,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText('内网快递'),
                              ),
                              ListTile(
                                leading: Icon(
                                  OMIcons.games,
                                  color: themeData?.topNavIconColor,
                                ),
                                title: LanText('远程游戏手柄, 键盘'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        if (_qrcodeData.isNotEmpty &&
                            _qrcodeData['purchased'] == false) ...[
                          LanText(
                            '立刻购买(${_commonProvider?.gWebData['amount'] ?? DEF_AMOUNT}￥)',
                            fontSize: 22,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: loadQrcode() != null
                                    ? Image.memory(
                                        loadQrcode(),
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                              ),
                              LanText(
                                '仅支持支付宝',
                                alignX: 0,
                                small: true,
                              ),
                              LanText(
                                '单号: ${_qrcodeData['details']['alipay_trade_precreate_response']['out_trade_no']}',
                                alignX: 0,
                                maxWidth:
                                    MediaQuery.of(context).size.width - 60,
                              ),
                              SizedBox(height: 10),
                              LanText(
                                '或',
                                fontSize: 22,
                                alignX: 0,
                              ),
                              SizedBox(height: 10),
                              CupertinoButton(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: NoResizeText('直接跳转支付'),
                                color: Color(0xFF007AFF),
                                onPressed: () async {
                                  String url =
                                      'alipayqr://platformapi/startapp?saId=10000007&qrcode=${_qrcodeData['details']['alipay_trade_precreate_response']['qr_code']}';
                                  if (await canLaunch(url)) {
                                    await launch(url);
                                  } else {
                                    showText('链接打开失败');
                                    FLog.error(text: 'markdown url');
                                  }
                                },
                              ),
                              SizedBox(height: 10),
                              LanText(
                                '请在支付后激活',
                                alignX: 0,
                                fontSize: 20,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          LanText(
                            '激活',
                            fontSize: 22,
                          ),
                          activeButton(),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     CupertinoButton(
                          //       borderRadius:
                          //           BorderRadius.all(Radius.circular(5)),
                          //       child: NoResizeText('激活'),
                          //       color: Color(0xFF007AFF),
                          //       onPressed: () async {
                          //         await req().get(
                          //             _commonProvider.baseUrl + '/pay/own_app',
                          //             queryParameters: {
                          //               'app_name': APP_NAME,
                          //               'device_id':
                          //                   await MixUtils.getAndroidId(),
                          //             }).then((value) {
                          //           dynamic data = value.data;
                          //           if (data['purchased']) {
                          //             _qrcodeData = {};
                          //             _commonProvider.setPurchase(true);
                          //             showText('购买成功');
                          //           } else {
                          //             String msg;
                          //             if (data['message'] is List) {
                          //               msg =
                          //                   (data['message'] as List).join(',');
                          //             } else {
                          //               msg = data['message'];
                          //             }
                          //             showText('$msg 未购买');
                          //           }
                          //         });
                          //       },
                          //     ),
                          //   ],
                          // ),
                        ],
                        if (_qrcodeData.isNotEmpty &&
                            _qrcodeData['purchased'] == true) ...[
                          LanText(
                            '你已经拥有此软件, 请手动激活',
                            fontSize: 20,
                          ),
                          SizedBox(height: 10),
                          activeButton(),
                        ],
                        if (_commonProvider.username == null) ...[
                          LanText(
                            '立刻购买',
                            fontSize: 22,
                          ),
                          Row(
                            children: <Widget>[
                              CupertinoButton(
                                child: NoResizeText('登录'),
                                onPressed: () async {
                                  await showTwoTextFieldModal(
                                    context,
                                    _themeProvider,
                                    fPlaceholder: '邮箱',
                                    sPlaceholder: '密码',
                                    title: '登录',
                                    onOk: (f, s) async {
                                      if (f == '' && s == '') {
                                        showText('邮箱密码不为空');
                                        return;
                                      }
                                      if (!MixUtils.isEmail(f)) {
                                        showText('邮箱格式不正确');
                                        return;
                                      }
                                      if (!MixUtils.isPassword(s)) {
                                        showText('密码格式不正确');
                                        return;
                                      }
                                      await req().post(baseUrl + '/auth/login',
                                          data: {
                                            'username': f.trim(),
                                            'password': s.trim()
                                          }).then((value) async {
                                        dynamic data = value.data;
                                        showText('${data['message']}');
                                        if (data['data']['access_token'] !=
                                            null) {
                                          await Store.setString(LOGIN_TOKEN,
                                              data['data']['access_token']);
                                          await _commonProvider.setUsername(
                                              data['data']['username']);
                                        }
                                      }).catchError((err) {
                                        showText('登录失败');
                                        FLog.error(text: '$err');
                                      });
                                    },
                                    onCancel: () {},
                                  );
                                },
                              ),
                              CupertinoButton(
                                child: NoResizeText('注册'),
                                onPressed: () async {
                                  await showTwoTextFieldModal(
                                    context,
                                    _themeProvider,
                                    fPlaceholder: '使用邮箱',
                                    sPlaceholder: '密码(数字加英文)',
                                    title: '注册',
                                    onOk: (String f, String s) async {
                                      if (f == '' && s == '') {
                                        showText('邮箱密码不为空');
                                        return;
                                      }
                                      if (!MixUtils.isEmail(f)) {
                                        showText('邮箱格式不正确');
                                        return;
                                      }
                                      if (!MixUtils.isPassword(s)) {
                                        showText('密码格式不正确');
                                        return;
                                      }
                                      await req().post(
                                          baseUrl + '/user/register',
                                          data: {
                                            'username': f.trim(),
                                            'password': s.trim()
                                          }).then((value) {
                                        dynamic data = value.data;
                                        showText('${data['message']}');
                                      }).catchError((err) {
                                        showText('注册出错');
                                        FLog.error(text: '$err');
                                      });
                                    },
                                    onCancel: () {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 20),
                        LanText(
                          '注意',
                          fontSize: 22,
                        ),
                        SizedBox(height: 10),
                        LanText(
                          '1. 已经购买过的直接登录',
                        ),
                        LanText(
                          '2. 购买完成返回pc端下载链接',
                        ),
                        LanText(
                          '3. 务必记住用户名,密码',
                        ),
                        LanText(
                          '4. 每个账号只能激活一台设备',
                        ),
                        LanText(
                          '5. 如果更换设备, 联系我',
                        ),
                        SizedBox(height: 20),
                        LanText(
                          '其他',
                          fontSize: 22,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            CupertinoButton(
                              child: NoResizeText('复制android_id到剪贴板'),
                              onPressed: () async {
                                String id = await MixUtils.getAndroidId();
                                await Clipboard.setData(
                                    ClipboardData(text: id));
                                showText('复制成功 $id');
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

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:joystick_editor/joystick_board.dart';
import 'package:lan_file_more/constant/constant.dart';

import 'package:lan_file_more/page/lan/control/image_leading_tile.dart';
import 'package:provider/provider.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/model/common_model.dart';
import 'package:lan_file_more/model/theme_model.dart';

class LanControlPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LanControlPageState();
  }
}

class _LanControlPageState extends State<LanControlPage>
    with AutomaticKeepAliveClientMixin {
  ThemeModel _themeModel;
  CommonModel _commonModel;
  bool _shareSwitch;
  bool _vscodeSwitch;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    _mutex = true;
    _shareSwitch = false;
    _vscodeSwitch = false;
    BotToast.showText(text: '本页 功能未实现 敬请期待', duration: Duration(seconds: 4));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _commonModel = Provider.of<CommonModel>(context);
  }

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  Widget build(BuildContext context) {
    String internalIp = _commonModel.internalIp;
    String filePort = _commonModel.filePort ?? FILE_DEFAULT_PORT;
    String codeSrvPort = _commonModel.codeSrvPort ?? CODE_SERVER_DEFAULT_PORT;
    dynamic themeData = _themeModel.themeData;

    String fileAddr = internalIp == null
        ? '$LOOPBACK_ADDR:$filePort'
        : '$internalIp:$filePort';

    String codeAddr = internalIp == null
        ? '$LOOPBACK_ADDR:$codeSrvPort'
        : '$internalIp:$codeSrvPort';

    // String codeSrvIp = _commonModel.codeSrvIp;

    String firstAliveIp =
        // ignore: null_aware_in_logical_operator
        _commonModel.currentConnectIp != null &&
                (_commonModel.socket?.connected != null ||
                    _commonModel.socket?.connected == true)
            ? '${_commonModel.currentConnectIp}:${_commonModel.filePort}'
            : '未连接';

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Scrollbar(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        SizedBox(height: 18),
                        Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          child: ImageLeadingTile(
                            title: '游戏',
                            imgUrl: 'assets/images/3.png',
                            onTap: () {
                              Navigator.of(context, rootNavigator: true).push(
                                CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                    return JoystickBoard();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          child: ImageLeadingTile(
                            title: '键盘',
                            imgUrl: 'assets/images/1.png',
                            onTap: () {},
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          padding: EdgeInsets.only(left: 18, right: 18),
                          child: ImageLeadingTile(
                            title: '鼠标',
                            imgUrl: 'assets/images/2.png',
                            onTap: () {},
                          ),
                        ),
                        // ListTile(
                        //   leading: Image.asset(
                        //     'assets/images/2.png',
                        //     height: 100,
                        //   ),
                        //   contentPadding: EdgeInsets.only(left: 15, right: 25),
                        //   trailing: NoResizeText('鼠标'),
                        // ),
                        // ListTile(
                        //   leading: Image.asset('assets/images/1.png'),
                        //   contentPadding: EdgeInsets.only(left: 15, right: 25),
                        //   trailing: NoResizeText('键盘'),
                        // ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

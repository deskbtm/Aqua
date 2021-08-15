import 'dart:developer';

import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/setting/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeftQuickBoard extends StatefulWidget {
  LeftQuickBoard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LeftQuickBoardState();
  }
}

class LeftQuickBoardState extends State<LeftQuickBoard> {
  late ThemeModel _tm;
  late GlobalModel _gm;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tm = Provider.of<ThemeModel>(context);
    _gm = Provider.of<GlobalModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    log('left quick board painting', name: 'Paint');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: NoResizeText(
          '目录',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            // color: themeData.navTitleColor,
          ),
        ),
        // backgroundColor: themeData.navBackgroundColor,
        border: null,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Container();
              // return InkWell(
              //   onTap: () {
              //     Navigator.of(context, rootNavigator: true).push(
              //       CupertinoPageRoute(
              //         builder: (BuildContext context) {
              //           return Container();
              //         },
              //       ),
              //     );
              //   },
              //   child: ListTile(
              //       title: ThemedText(S.of(context)!.about),
              //       contentPadding: EdgeInsets.only(left: 15, right: 25),
              //       trailing: Icon(Icons.hdr_weak)),
              // );
            },
          ),
        ),
      ),
    );
  }
}

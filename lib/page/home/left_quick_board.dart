import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/switch.dart';
import 'package:aqua/constant/constant_var.dart';
import 'package:aqua/model/global_model.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LeftQuickBoard extends StatefulWidget {
  LeftQuickBoard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LeftQuickBoardState();
  }
}

class LeftQuickBoardState extends State<LeftQuickBoard> {
  late ThemeModel _themeModel;
  late GlobalModel _globalModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
    _globalModel = Provider.of<GlobalModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
          child: Column(
        children: [
          ListTile(
            title: ThemedText('dsadsadsa'),
            contentPadding: EdgeInsets.only(left: 15, right: 10),
            trailing: AquaSwitch(
              value: _themeModel.isDark,
              onChanged: (val) async {
                if (val) {
                  _themeModel.setTheme(DARK_THEME);
                } else {
                  _themeModel.setTheme(LIGHT_THEME);
                }
              },
            ),
          ),
          Text(_globalModel.alpineRepo!)
        ],
      )),
    );
  }
}

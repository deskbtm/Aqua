import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/point_tab.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/lan/control/control.dart';
import 'package:lan_file_more/page/lan/share/share.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

class LanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LanPageState();
  }
}

class LanPageState extends State<LanPage> {
  ThemeModel _themeModel;
  TabController _controller;
  List<Tab> _tabs;

  @override
  void initState() {
    super.initState();
    final QuickActions quickActions = QuickActions();

    quickActions.initialize((String shortcutType) {
      switch (shortcutType) {
        case 'static-server':
          break;
        case 'vscode-server':
          break;
        default:
      }
    });

    _tabs = [
      Tab(child: LanText('传输', alignX: 0)),
      Tab(child: LanText('控制', alignX: 0)),
      // Tab(child: LanText('控制', alignX: 0)),
      // Tab(child: LanText('清理', alignX: 0)),
    ];
    _controller = TabController(
      length: _tabs.length,
      vsync: ScrollableState(),
    );
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel?.themeData;

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: TabBar(
            tabs: _tabs,
            controller: _controller,
            indicatorPadding: EdgeInsets.all(0),
            isScrollable: true,
            indicator: PointTabIndicator(
              position: PointTabIndicatorPosition.bottom,
              color: Color(0xFF007AFF),
              insets: EdgeInsets.only(bottom: 3),
            ),
          ),
          backgroundColor: themeData?.navBackgroundColor,
          border: null,
        ),
        child: TabBarView(
          controller: _controller,
          children: <Widget>[
            LanSharePage(),
            LanControlPage(),
          ],
        ),
      ),
    );
  }
}

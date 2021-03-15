import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/page/lan/share/share.dart';
import 'package:quick_actions/quick_actions.dart';

class LanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LanPageState();
  }
}

class LanPageState extends State<LanPage> {
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
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: CupertinoPageScaffold(child: LanSharePage()));
  }
}

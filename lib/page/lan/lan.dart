import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aqua/page/lan/share.dart';

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

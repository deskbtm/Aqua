import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/progress.dart';

// ignore: must_be_immutable
class StorageCard extends StatelessWidget {
  final double totalSize;
  final double validSize;

  const StorageCard(
      {Key key, @required this.totalSize, @required this.validSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CupertinoThemeData themeData = CupertinoTheme.of(context);

    return CupertinoTheme(
      data: CupertinoThemeData(textTheme: themeData.textTheme),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 3),
        child: ProgressBar(
          padding: 5,
          barColor: Color(0xFF727272),
          backgroundColor: Color(0xB0503838f),
          barHeight: 7,
          barWidth: MediaQuery.of(context).size.width,
          numerator: totalSize - validSize,
          denominator: totalSize,
          title: '内部储存',
          dialogTextStyle: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF444444),
          ),
          boarderColor: Colors.grey,
        ),
      ),
    );
  }
}

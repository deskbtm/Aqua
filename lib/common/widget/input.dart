import 'package:flutter/cupertino.dart';

BorderSide kDefaultRoundedBorderSide(color) => BorderSide(
      color: color,
      // CupertinoDynamicColor.withBrightness(
      //   color: Color(0x33000000),
      //   darkColor: Color(0x33FFFFFF),
      // ),
      style: BorderStyle.solid,
      width: 0.0,
    );
Border defaultRoundedBorder({color}) => Border(
      top: kDefaultRoundedBorderSide(color),
      bottom: kDefaultRoundedBorderSide(color),
      left: kDefaultRoundedBorderSide(color),
      right: kDefaultRoundedBorderSide(color),
    );

BoxDecoration inputDecoration(
        {color = CupertinoColors.white, required Color borderColor}) =>
    BoxDecoration(
      color: color,
      border: defaultRoundedBorder(color: borderColor),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );

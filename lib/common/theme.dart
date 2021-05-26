import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AquaTheme {
  late Color iconColor;
  late Color bottomNavColor;
  late Color scaffoldBackgroundColor;
  late Color navBackgroundColor;
  late Color topNavIconColor;
  late Color actionButtonColor;
  late Color itemColor;
  late Color itemFontColor = Colors.black54;
  late Color navTitleColor = Colors.black87;
  late Color dialogBgColor;
  late Color inputColor;
  late Color inputBorderColor;
  late Color menuItemColor;
  late Color photoNavColor;
  late Brightness systemNavigationBarIconBrightness;
  late Color systemNavigationBarColor;
  late Color divideColor;
  Color modalColor(context);
}

class LightTheme implements AquaTheme {
  Color iconColor = Color(0xFF007AFF);
  Color inactiveIconColor = Color(0xFF959596);
  Color bottomNavColor = Color(0x94F3ECEC);
  Color scaffoldBackgroundColor = Color(0xFFFFFFFFF);
  Color navBackgroundColor = Color(0xFFFFFFFFF);
  Color topNavIconColor = Color(0x94535353);
  Color actionButtonColor = Color(0x22181717);
  Color itemColor = Color(0x83EBEBEB);
  Color itemFontColor = Colors.black54;
  Color navTitleColor = Colors.black87;
  Color dialogBgColor = Color(0xC0FFFFFF);
  Color inputColor = Color(0xC0FFFFFF);
  Color inputBorderColor = Color(0x33000000);
  Color menuItemColor = Color(0xDEFFFFFF);
  Color photoNavColor = Color(0x4BF3ECEC);
  Brightness systemNavigationBarIconBrightness = Brightness.dark;
  Color systemNavigationBarColor = Colors.white;
  Color divideColor = Color(0xfff5f5f5);

  Color modalColor(context) {
    return CupertinoDynamicColor.resolve(
      CupertinoDynamicColor.withBrightness(
        color: Color(0x2A9B9B9B),
        darkColor: Color(0x5D8F8F8F),
      ),
      context,
    );
  }
}

class DarkTheme implements AquaTheme {
  Color iconColor = Color(0xFF007AFF);
  Color inactiveIconColor = Color(0xFF959596);
  Color bottomNavColor = Color(0xB00E0D0D);
  Color scaffoldBackgroundColor = Color(0xFF0000000);
  Color navBackgroundColor = Color(0xFF0000000);
  Color topNavIconColor = Color(0xFF007AFF);
  Color actionButtonColor = Color(0x22ffffff);
  Color itemColor = Color(0xff222222);
  Color itemFontColor = Color(0xFFFFFFFFF);
  Color navTitleColor = Color(0xFFFFFFFFF);
  Color dialogBgColor = Color(0x9F000000);
  Color inputColor = Color(0xFF000000);
  Color inputBorderColor = Color(0x4FFFFFFF);
  Color menuItemColor = Color(0xCC0000000);
  Color photoNavColor = Color(0xCC0000000);
  Brightness systemNavigationBarIconBrightness = Brightness.light;
  Color systemNavigationBarColor = Colors.black;
  Color divideColor = Color(0xff222222);
  Color modalColor(context) {
    return CupertinoDynamicColor.resolve(
      CupertinoDynamicColor.withBrightness(
        color: Color(0x17000000),
        darkColor: Color(0x33000000),
      ),
      context,
    );
  }
}

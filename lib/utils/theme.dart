import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class LanFileMoreTheme {
  Color bottomNavColor;
  Color scaffoldBackgroundColor;
  Color navBackgroundColor;
  Color topNavIconColor;
  Color actionButtonColor;
  Color itemColor;
  Color itemFontColor = Colors.black54;
  Color navTitleColor = Colors.black87;
  Color dialogBgColor;
  Color inputColor;
  Color inputBorderColor;
  Color menuItemColor;
  Color photoNavColor;
  Brightness systemNavigationBarIconBrightness;
  Color systemNavigationBarColor;
  Color divideColor;
}

class LightTheme implements LanFileMoreTheme {
  Color activeIconColor = Color(0xFF007AFF);
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
  Color divideColor = Colors.grey[100];
}

class DarkTheme implements LanFileMoreTheme {
  Color activeIconColor = Color(0xFF007AFF);
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
}

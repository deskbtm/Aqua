import 'package:flutter/material.dart';

class ToolItem {
  VoidCallback? press;

  String symbol;

  ToolItem({
    required this.press,
    required this.symbol,
  });
}

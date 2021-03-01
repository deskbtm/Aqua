import 'package:flutter/material.dart';

class ToolItem {
  Function press;

  String symbol;

  ToolItem({
    @required this.press,
    this.symbol,
  });
}

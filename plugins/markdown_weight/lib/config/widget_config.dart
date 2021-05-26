import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m;

/// you can use [WidgetConfig] to custom your tag widget
class WidgetConfig {
  WidgetBuilder p;
  WidgetBuilder pre;
  WidgetBuilder ul;
  WidgetBuilder ol;
  WidgetBuilder block;
  WidgetBuilder hr;
  WidgetBuilder table;

  WidgetConfig({
    required this.p,
    required this.pre,
    required this.ul,
    required this.ol,
    required this.block,
    required this.hr,
    required this.table,
  });
}

typedef Widget WidgetBuilder(m.Element node);

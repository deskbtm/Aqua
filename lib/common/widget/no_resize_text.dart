import 'package:flutter/material.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:provider/provider.dart';

class NoResizeText extends Text {
  NoResizeText(
    String data, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double textScaleFactor = 1,
    int? maxLines,
    String? semanticsLabel,
  }) : super(
          data,
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          semanticsLabel: semanticsLabel,
        );
}

class ThemedText extends StatefulWidget {
  final String content;
  final TextStyle? style;
  final bool small;
  final double alignX;
  final double? fontSize;
  final bool? softWrap;
  final double maxWidth;
  // final Color color;

  const ThemedText(
    this.content, {
    Key? key,
    this.style,
    this.small = false,
    this.alignX = -1,
    this.fontSize,
    this.softWrap,
    this.maxWidth = double.infinity,
    // this.color,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return LanTextState();
  }
}

class LanTextState extends State<ThemedText> {
  late ThemeModel _themeModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    dynamic themeData = _themeModel.themeData;

    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Align(
        alignment: Alignment(widget.alignX, 0),
        child: NoResizeText(
          widget.content,
          softWrap: widget.softWrap,
          style: widget.style ??
              TextStyle(
                color: themeData?.itemFontColor,
                fontSize: widget.small ? 13 : widget.fontSize,
              ),
        ),
      ),
    );
  }
}

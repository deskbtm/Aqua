import 'package:aqua/common/theme.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'input.dart';

class AquaTextField extends StatefulWidget {
  final TextStyle? style;
  final BoxDecoration? decoration;
  final TextEditingController? controller;
  final String? placeholder;
  final int maxLines;
  final Function(String)? onSubmitted;
  final TextStyle? textStyle;
  final FocusNode? focusNode;

  const AquaTextField({
    Key? key,
    this.style,
    this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.onSubmitted,
    this.decoration,
    this.textStyle,
    this.focusNode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AquaTextFieldState();
  }
}

class _AquaTextFieldState extends State<AquaTextField> {
  late ThemeModel _themeModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme theme = _themeModel.themeData;

    return CupertinoTextField(
      focusNode: widget.focusNode,
      cursorHeight: 24,
      style: widget.style,
      controller: widget.controller,
      maxLines: widget.maxLines,
      placeholder: widget.placeholder,
      onSubmitted: widget.onSubmitted,
      decoration: widget.decoration ??
          inputDecoration(
            color: theme.inputBgColor,
            borderColor: theme.inputBorderColor,
          ),
      placeholderStyle: widget.textStyle ??
          TextStyle(
            fontWeight: FontWeight.w400,
            color: theme.itemFontColor,
          ),
    );
  }
}

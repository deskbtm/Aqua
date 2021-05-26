import 'package:aqua/common/theme.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'input.dart';

class AquaTextField extends StatefulWidget {
  final TextStyle? style;
  final TextEditingController? controller;
  final String? placeholder;
  final int maxLines;
  final Function(String)? onSubmitted;

  const AquaTextField({
    Key? key,
    this.style,
    this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.onSubmitted,
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
      style: widget.style,
      controller: widget.controller,
      maxLines: widget.maxLines,
      placeholder: widget.placeholder,
      onSubmitted: widget.onSubmitted,
      decoration: inputDecoration(
        color: theme.inputColor,
        borderColor: theme.inputBorderColor,
      ),
      placeholderStyle: TextStyle(
        fontWeight: FontWeight.w400,
        color: theme.itemFontColor,
      ),
    );
  }
}

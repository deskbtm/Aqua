import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LanCheckBox extends StatelessWidget {
  final bool value;
  final Color? borderColor;
  final void Function(bool?)? onChanged;

  const LanCheckBox(
      {Key? key, required this.value, this.borderColor, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: ThemeData(unselectedWidgetColor: borderColor),
        child: Checkbox(
          onChanged: onChanged,
          value: value,
        ),
      ),
    );
  }
}

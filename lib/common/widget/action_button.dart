import 'package:aqua/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:provider/provider.dart';
import 'package:aqua/model/theme_model.dart';

class ActionButton extends StatefulWidget {
  final Color? color;
  final Color? fontColor;
  final dynamic content;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Widget? trailing;
  final Widget? leading;

  const ActionButton({
    Key? key,
    this.color,
    this.fontColor = Colors.cyanAccent,
    this.content,
    this.onTap,
    this.margin = const EdgeInsets.only(left: 10, right: 10, bottom: 18),
    this.trailing,
    this.leading,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ActionButtonState();
  }
}

class _ActionButtonState extends State<ActionButton> {
  late ThemeModel _themeModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;

    return Container(
      width: 170,
      child: Card(
        elevation: 0,
        color: widget.color ?? themeData.actionButtonColor,
        margin: widget.margin,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            }
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: widget.content is Widget
                  ? widget.content
                  : Stack(
                      clipBehavior: Clip.hardEdge,
                      children: <Widget>[
                        if (widget.leading != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: widget.leading,
                          ),
                        Align(
                          child: NoResizeText(
                            widget.content,
                            style: TextStyle(
                                color: widget.fontColor,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        if (widget.trailing != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: widget.trailing,
                          )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

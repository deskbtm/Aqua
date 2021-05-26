import 'package:flutter/material.dart';
import 'package:aqua/common/widget/no_resize_text.dart';

class OptionItem extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Color color;
  final VoidCallback? onPress;
  final double height;
  final Widget? extend;
  final List<BoxShadow> shadow;
  final double marginBottom;
  final double marginTop;
  final Color titleColor;
  final Color subTitleColor;
  final EdgeInsetsGeometry padding;
  final Border? border;
  final double outSidePadding;

  OptionItem({
    required this.title,
    this.subTitle,
    this.color = const Color(0xFFEEEEEEE),
    this.onPress,
    this.height = 60,
    this.extend,
    this.shadow = const [
      BoxShadow(
        color: Colors.black38,
        blurRadius: 15.0,
        offset: Offset(6.0, 6.0),
        spreadRadius: -6,
      )
    ],
    this.marginBottom = 13,
    this.titleColor = const Color(0xFFF5F5F5),
    this.subTitleColor = const Color(0xffeeeeeee),
    this.padding = const EdgeInsets.only(right: 15, left: 23),
    this.border,
    this.outSidePadding = 0,
    this.marginTop = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.grey),
      child: GestureDetector(
        onTap: onPress,
        child: Padding(
          padding: EdgeInsets.only(bottom: marginBottom, top: marginTop),
          child: Container(
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: border,
              boxShadow: shadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (title != null)
                          Container(
                            child: NoResizeText(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                color: titleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (subTitle != null)
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width -
                                  outSidePadding,
                            ),
                            child: NoResizeText(
                              subTitle!,
                              style: TextStyle(
                                fontSize: 14,
                                color: subTitleColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                if (extend != null) extend!
              ],
            ),
          ),
        ),
      ),
    );
  }
}

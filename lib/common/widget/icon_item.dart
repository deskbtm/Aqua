import 'package:flutter/material.dart';
import 'package:aqua/common/widget/no_resize_text.dart';

class IconItem extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String title;

  const IconItem(
      {Key? key, required this.icon, required this.title, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              child: icon,
            ),
            SizedBox(height: 4),
            NoResizeText(title)
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CircleView extends StatelessWidget {
  final double size;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Border border;
  final double opacity;
  final Image buttonImage;
  final Icon buttonIcon;
  final Widget buttonText;
  final double rotate;
  final TextStyle textStyle;

  CircleView({
    this.size,
    this.color = Colors.transparent,
    this.boxShadow,
    this.border,
    this.opacity,
    this.buttonImage,
    this.buttonIcon,
    this.buttonText,
    this.rotate = 0.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        width: size,
        height: size,
        child: Center(
          child: buttonIcon != null
              ? buttonIcon
              : (buttonImage != null)
                  ? buttonImage
                  : (buttonText != null)
                      ? buttonText
                      : null,
        ),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border,
          boxShadow: boxShadow,
        ),
      ),
    );
  }

  factory CircleView.joystickCircle(double size, Color color) => CircleView(
        size: size,
        color: color,
        border: Border.all(
          color: Color(0x98007BFF),
          width: 1,
          style: BorderStyle.solid,
        ),
      );

  factory CircleView.joystickInnerCircle(double size, Color color) =>
      CircleView(
        size: size,
        color: color,
        border: Border.all(
          color: Colors.black12,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 4.0,
            blurRadius: 4.0,
          )
        ],
      );

  factory CircleView.padBackgroundCircle(
          double size, Color backgroundColour, borderColor, Color shadowColor,
          {double opacity}) =>
      CircleView(
        size: size,
        color: backgroundColour,
        opacity: opacity,
        border: Border.all(
          color: borderColor,
          width: 4.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            spreadRadius: 8.0,
            blurRadius: 8.0,
          )
        ],
      );

  factory CircleView.padButtonCircle(
    double size,
    Color color,
    Image image,
    Icon icon,
    Widget text, {
    double rotate = 0.0,
  }) =>
      CircleView(
        size: size,
        color: color,
        rotate: rotate,
        buttonImage: image,
        buttonIcon: icon,
        buttonText: text,
        border: Border.all(
          color: Color(0x98007BFF),
          width: 1.0,
          style: BorderStyle.solid,
        ),
      );
}

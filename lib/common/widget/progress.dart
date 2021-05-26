library progress_bar;

import 'package:flutter/material.dart';
import 'package:aqua/utils/mix_utils.dart';

class ProgressBar extends StatelessWidget {
  final String title;
  final double numerator;
  final double denominator;
  final double barWidth;
  final double barHeight;
  final Color barColor;
  final TextStyle titleStyle;
  final TextStyle dialogTextStyle;
  final double padding;
  final Color backgroundColor;
  final Color boarderColor;
  final bool showRemainder;
  late final double extraSize;

  ProgressBar({
    required this.title,
    required this.numerator,
    required this.denominator,
    required this.barWidth,
    required this.barHeight,
    required this.barColor,
    required this.titleStyle,
    required this.dialogTextStyle,
    this.padding = 0.0,
    this.backgroundColor = Colors.white,
    this.boarderColor = Colors.grey,
    this.showRemainder = true,
    this.extraSize = 0,
  });

  @override
  Widget build(BuildContext context) {
    double barWithoutPadding = this.barWidth - this.padding - extraSize;

    double percentageWidth =
        (this.numerator / this.denominator) * barWithoutPadding;
    double displayPercentage = (this.numerator / this.denominator) * 100;
    double precentageBarWithoutPadding = percentageWidth - this.padding;
    if (percentageWidth.isNaN) {
      percentageWidth = 0.0;
    }
    if (displayPercentage.isNaN) {
      displayPercentage = 0.0;
    }

    if (precentageBarWithoutPadding.isNaN) {
      precentageBarWithoutPadding = 0.0;
    }

    if (barWithoutPadding.isNaN) {
      barWithoutPadding = 0.0;
    }
    return Padding(
        padding: EdgeInsets.all(this.padding),
        child: Container(
          width: barWithoutPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    this.title,
                    style: this.titleStyle,
                  ),
                  Text(
                      MixUtils.humanStorageSize(numerator) +
                          ' / ' +
                          MixUtils.humanStorageSize(denominator),
                      style: this.titleStyle)
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Stack(
                children: <Widget>[
                  //full bar
                  Container(
                    height: this.barHeight,
                    width: barWithoutPadding,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: this.backgroundColor,
                      border: Border.all(
                        color: this.boarderColor,
                        width: 0.3,
                      ),
                    ),
                  ),
                  // percentage
                  Container(
                    height: this.barHeight,
                    width: (precentageBarWithoutPadding) < 0
                        ? percentageWidth
                        : (precentageBarWithoutPadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: this.barColor,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 0.1,
              ),
              // Padding(
              //   padding: EdgeInsets.only(
              //     left: ((precentageBarWithoutPadding) / 2) < 0
              //         ? percentageWidth / 2
              //         : (precentageBarWithoutPadding) / 2,
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: <Widget>[
              //       CustomPaint(
              //           size: Size(10, 8),
              //           painter: DrawTriangle(this.barColor)),
              //       Container(
              //           padding: EdgeInsets.all(2.5),
              //           decoration: BoxDecoration(
              //             color: this.barColor,
              //             borderRadius: BorderRadius.only(
              //                 topRight: Radius.circular(5),
              //                 bottomLeft: Radius.circular(5),
              //                 bottomRight: Radius.circular(5)),
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: <Widget>[
              //               Text(
              //                 displayPercentage.toStringAsFixed(1) + ' %',
              //                 overflow: TextOverflow.clip,
              //                 style: this.dialogTextStyle,
              //               ),
              //               this.showRemainder == true
              //                   ? Text(
              //                       '剩余 : ' +
              //                           MixUtils.humanStorageSize(
              //                               this.denominator - this.numerator),
              //                       overflow: TextOverflow.clip,
              //                       style: this.dialogTextStyle,
              //                     )
              //                   : SizedBox(
              //                       width: 0,
              //                       height: 0,
              //                     ),
              //             ],
              //           ))
              //     ],
              //   ),
              // ),
            ],
          ),
        ));
  }
}

class DrawTriangle extends CustomPainter {
  late Paint _paint;
  late Color backgroundColor;

  DrawTriangle(backgroundColor) {
    _paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.height, size.width);
    path.close();
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

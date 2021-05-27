// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:aqua/common/widget/no_resize_text.dart';
// import 'package:aqua/model/theme_model.dart';
// import 'package:aqua/common/theme.dart';
// import 'package:open_file/open_file.dart';
// import 'package:provider/provider.dart';

// class NotSupportPage extends StatefulWidget {
//   final String content;
//   final bool withOpenWay;
//   final String path;

//   const NotSupportPage({
//     Key? key,
//     this.content = '不支持该类型',
//     this.withOpenWay = true,
//     this.path,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return _NotSupportPageState();
//   }
// }

// class _NotSupportPageState extends State<NotSupportPage> {
//   ThemeModel _themeModel;
//   Timer _timer;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _themeModel = Provider.of<ThemeModel>(context);
//     if (widget.withOpenWay) {
//       _timer = Timer(Duration(milliseconds: 1500), () {
//         OpenFile.open(widget.path);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer?.cancel();
//     _timer = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     AquaTheme themeData = _themeModel.themeData;
//     return CupertinoPageScaffold(
//       backgroundColor: themeData.scaffoldBackgroundColor,
//       child: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error,
//               color: themeData.iconColor,
//             ),
//             SizedBox(height: 10),
//             NoResizeText(
//               widget.content,
//               style: TextStyle(color: themeData.itemFontColor),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

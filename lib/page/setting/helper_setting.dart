// import 'dart:io';

// import 'package:aqua/plugin/storage/storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_mailer/flutter_mailer.dart';
// import 'package:aqua/common/widget/function_widget.dart';
// import 'package:aqua/common/widget/no_resize_text.dart';
// import 'package:aqua/constant/constant.dart';

// import 'package:aqua/model/global_model.dart';
// import 'package:aqua/model/theme_model.dart';
// import 'package:aqua/common/theme.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:package_info/package_info.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path/path.dart' as pathLib;

// class HelperPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _HelperPageState();
//   }
// }

// class _HelperPageState extends State<HelperPage> {
//   late ThemeModel _tm;
//   late GlobalModel _gm;
//   late String _version;
//   late bool _locker;
//   late String _qqGroupNumber;
//   late String _qqGroupKey;
//   late String _authorEmail;
//   late String _authorAvatar;

//   @override
//   void initState() {
//     super.initState();
//     _version = '';
//     _locker = true;
//   }

//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//     _tm = Provider.of<ThemeModel>(context);
//     _gm = Provider.of<GlobalModel>(context);

//     if (_gm.gWebData.isNotEmpty) {
//       _authorEmail = _gm.gWebData['mobile']['config']['author_email'];
//       _qqGroupNumber =
//           _gm.gWebData['mobile']['config']['qq_group_num'];
//       _qqGroupKey = _gm.gWebData['mobile']['config']['qq_group_key'];
//       _authorAvatar =
//           _gm.gWebData['mobile']['config']['author_avatar'];
//     } else {
//       _authorEmail = DEFAULT_AUTHOR_EMAIL;
//       _qqGroupNumber = DEFAULT_QQ_GROUP_NUM;
//       _qqGroupKey = DEFAULT_QQ_GROUP_KEY;
//       _authorAvatar = DEFAULT_AUTHOR_AVATAR;
//     }

//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     if (_locker) {
//       _locker = false;
//       setState(() {
//         _version = packageInfo.version;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     AquaTheme themeData = _tm.themeData;

//     List<Widget> helperSettingItem = [
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(height: 30),
//           blockTitle('教程'),
//           SizedBox(height: 15),
//           InkWell(
//             onTap: () async {
//               if (await canLaunch(TUTORIAL_URL)) {
//                 await launch(TUTORIAL_URL);
//               } else {
//                 Fluttertoast.showToast(msg: '链接打开失败');
//               }
//             },
//             child: ListTile(
//               title: ThemedText('使用教程'),
//               contentPadding: EdgeInsets.only(left: 15, right: 10),
//             ),
//           ),
//         ],
//       ),
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           SizedBox(height: 30),
//           blockTitle('日志'),
//           SizedBox(height: 15),
//           InkWell(
//             onTap: () async {
//               String externalDir = await ExtraStorage.getStorageDirectory;
//               String logFilePath = pathLib.join(externalDir, 'FLogs/flog.txt');

//               if (await File(logFilePath).exists()) {
//                 await sendMail(logFilePath);
//               } else {
//                 // await FLog.exportLogs();
//                 await sendMail(logFilePath);
//               }
//             },
//             child: ListTile(
//               title: ThemedText('发送日志'),
//               contentPadding: EdgeInsets.only(left: 15, right: 10),
//             ),
//           ),
//           InkWell(
//             onTap: () async {
//               // await FLog.clearLogs();
//               Fluttertoast.showToast(msg: '删除完成');
//             },
//             child: ListTile(
//               title: ThemedText('删除日志'),
//               contentPadding: EdgeInsets.only(left: 15, right: 10),
//             ),
//           ),
//           InkWell(
//             onTap: () async {
//               // await FLog.exportLogs();
//               String externalDir = await AndroidMix.storage.getStorageDirectory;
//               Fluttertoast.showToast(msg: '日志导出至: $externalDir');
//             },
//             child: ListTile(
//               title: ThemedText('导出日志'),
//               contentPadding: EdgeInsets.only(left: 15, right: 10),
//             ),
//           ),
//           SizedBox(height: 30)
//         ],
//       ),
//     ];

//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: themeData.navBackgroundColor,
//         border: null,
//         middle: NoResizeText(
//           '帮助',
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 20,
//             color: themeData.navTitleColor,
//           ),
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: ListView.builder(
//           itemCount: helperSettingItem.length,
//           itemBuilder: (context, index) {
//             return helperSettingItem[index];
//           },
//         ),
//       ),
//     );
//   }
// }

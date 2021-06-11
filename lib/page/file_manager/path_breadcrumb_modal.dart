// import 'dart:ui';

// import 'package:aqua/common/theme.dart';
// import 'package:aqua/common/widget/dialog.dart';
// import 'package:aqua/common/widget/modal/show_modal.dart';
// import 'package:aqua/common/widget/no_resize_text.dart';
// import 'package:aqua/external/breadcrumb/src/breadcrumb.dart';
// import 'package:aqua/external/breadcrumb/src/breadcrumb_item.dart';
// import 'package:aqua/utils/mix_utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// Future<void> _showBreadcrumb() async {
//   AquaTheme themeData = _themeModel.themeData;
//   List<String> paths = pathLib.split(_fileManagerModel.currentDir!.path);
//   return showCupertinoModal(
//     context: context,
//     filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//     builder: (BuildContext context) {
//       return AquaDialog(
//         fontColor: themeData.itemFontColor,
//         bgColor: themeData.dialogBgColor,
//         title: AquaDialogTitle(title: AppLocalizations.of(context)!.select),
//         action: true,
//         withOk: false,
//         withCancel: false,
//         children: <Widget>[
//           BreadCrumb.builder(
//             itemCount: paths.length,
//             builder: (index) {
//               return BreadCrumbItem(
//                 margin: EdgeInsets.only(top: 5, bottom: 5),
//                 content: InkWell(
//                   onTap: () async {
//                     List<String> willNav =
//                         paths.getRange(0, index + 1).toList();
//                     String path = pathLib.joinAll(willNav);
//                     Directory dir = Directory(path);

//                     if (pathLib.equals(path, _rootDir?.path ?? '')) {
//                       _leftFileList = await readdir(dir);
//                       _rightFileList = [];
//                       _fileManagerModel.setCurrentDir(dir);
//                     } else if (pathLib.isWithin(_rootDir?.path ?? '', path)) {
//                       _leftFileList = await readdir(dir.parent);
//                       _rightFileList = await readdir(dir);
//                       // _fileManagerModel.currentDir = dir;
//                       _fileManagerModel.setCurrentDir(dir);
//                     }
//                     // setState(() {});
//                     MixUtils.safePop(context);
//                   },
//                   child: Container(
//                     padding:
//                         EdgeInsets.only(top: 4, bottom: 4, right: 6, left: 6),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(5)),
//                       color: themeData.listTileColor,
//                     ),
//                     constraints: BoxConstraints(maxWidth: 100),
//                     child: NoResizeText(
//                       paths[index],
//                       style: TextStyle(
//                           fontSize: 16, color: themeData.itemFontColor),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),
//               );
//             },
//             divider: Icon(Icons.chevron_right),
//           ),
//           SizedBox(height: 25),
//         ],
//       );
//     },
//   );
// }

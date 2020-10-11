// import 'dart:io';

// import 'package:android_mix/android_mix.dart';
// import 'package:android_mix/archive/enums.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:lan_express/page/file_manager/create_archive.dart';
// import 'package:lan_express/page/file_manager/file_action.dart';
// import 'package:lan_express/utils/mix_utils.dart';
// import 'package:lan_express/utils/notification.dart';

// Future<void> handleExtractArchive(BuildContext context) async {
//   bool result = false;

//   if (_shareModel.selectedFiles.length > 1) {
//     showText('只允许操作单个文件');
//   } else {
//     SelfFileEntity first = _shareModel.selectedFiles.first;
//     String archivePath = first.entity.path;
//     String name = FileAction.getName(archivePath);

//     if (Directory(pathLib.join(_currentDir.path, name)).existsSync()) {
//       showText('目录重名, 请更换');
//       return;
//     }

//     switch (first.ext) {
//       case 'zip':
//         if (await AndroidMix.archive.isZipEncrypted(archivePath)) {
//           await showSingleTextFieldModal(
//             context,
//             _themeModel,
//             title: '输入密码',
//             onOk: (val) async {
//               showWaitForArchiveNotification('解压中...');
//               result = await AndroidMix.archive
//                   .unzip(archivePath, _currentDir.path, pwd: val);
//             },
//             onCancel: () {
//               MixUtils.safePop(context);
//             },
//           );
//         } else {
//           showWaitForArchiveNotification('解压中...');
//           result =
//               await AndroidMix.archive.unzip(archivePath, _currentDir.path);
//         }
//         break;
//       case 'tar':
//         showWaitForArchiveNotification('解压中...');
//         await AndroidMix.archive.extractArchive(
//           archivePath,
//           _currentDir.path,
//           ArchiveFormat.tar,
//         );
//         break;
//       case 'tar.gz':
//       case 'tgz':
//         showWaitForArchiveNotification('解压中...');
//         result = await AndroidMix.archive.extractArchive(
//           archivePath,
//           _currentDir.path,
//           ArchiveFormat.tar,
//           compressionType: CompressionType.gzip,
//         );
//         break;
//       case 'tar.bz2':
//       case 'tz2':
//         showWaitForArchiveNotification('解压中...');
//         result = await AndroidMix.archive.extractArchive(
//           archivePath,
//           _currentDir.path,
//           ArchiveFormat.tar,
//           compressionType: CompressionType.bzip2,
//         );
//         break;
//       case 'tar.xz':
//       case 'txz':
//         showWaitForArchiveNotification('解压中...');
//         result = await AndroidMix.archive.extractArchive(
//           archivePath,
//           _currentDir.path,
//           ArchiveFormat.tar,
//           compressionType: CompressionType.xz,
//         );
//         break;
//       case 'jar':
//         showWaitForArchiveNotification('解压中...');
//         result = await AndroidMix.archive.extractArchive(
//           archivePath,
//           _currentDir.path,
//           ArchiveFormat.jar,
//         );
//         break;
//     }
//     LocalNotification.plugin?.cancel(0);
//     if (result) {
//       showText('提取成功');
//     } else {
//       showText('提取失败');
//     }
//     // if (mounted) {
//     //   await _shareModel.clearSelectedFiles();
//     //   await update2Side();
//     //   MixUtils.safePop(context);
//     // }
//   }
// }

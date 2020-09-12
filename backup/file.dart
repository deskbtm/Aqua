// import 'dart:io';
// import 'dart:isolate';
// import 'package:lan_express/page/file_manager/file_action.dart';
// import 'package:path/path.dart' as pathLib;
// import 'package:archive/archive_io.dart';

// void isolateArchive(List msg) async {
//   SendPort sendPort = msg[0];
//   Map data = msg[1];
//   String type = data['type'];
//   List<String> originPaths = data['originPaths'];
//   String targetDir = data['targetDir'];

//   try {
//     String archivePath = FileAction.genPathWhenExists(targetDir, '.' + type);

//     Future<void> zip() async {
//       var encoder = ZipFileEncoder();
//       encoder.create(archivePath);
//       await for (var path in Stream.fromIterable(originPaths)) {
//         if (FileSystemEntity.isDirectorySync(path)) {
//           encoder.addDirectory(Directory(path), includeDirName: true);
//         } else {
//           encoder.addFile(File(path), pathLib.basename(path));
//         }
//       }
//       encoder.close();
//     }

//     Future<void> common(String type) async {
//       Archive archive = Archive();
//       List<int> bytes;

//       for (var path in originPaths) {
//         if (FileSystemEntity.isDirectorySync(path)) {
//           Directory dir = Directory(path);
//           final dirName = pathLib.basename(dir.path);

//           List files = dir.listSync(recursive: true);

//           for (var file in files) {
//             if (file is File) {
//               String filename = pathLib.relative(file.path, from: dir.path);
//               filename = dirName + '/' + filename;
//               List<int> content = File(file.path).readAsBytesSync();
//               final af = ArchiveFile(filename, content.length, content);

//               af.lastModTime = file.lastModifiedSync().millisecondsSinceEpoch;
//               af.mode = file.statSync().mode;
//               archive.addFile(af);
//             }
//           }
//         } else {
//           List<int> content = await File(path).readAsBytes();
//           ArchiveFile archiveFile =
//               ArchiveFile(pathLib.basename(path), content.length, content);
//           archive.addFile(archiveFile);
//         }
//       }
//       switch (type) {
//         case 'tar':
//           bytes = TarEncoder().encode(archive);
//           break;
//         case 'tar.gz':
//           List<int> tarData = TarEncoder().encode(archive);
//           bytes = GZipEncoder().encode(tarData);
//           break;
//         case 'tar.bz2':
//           List<int> tarData = TarEncoder().encode(archive);
//           bytes = BZip2Encoder().encode(tarData);
//           break;
//       }

//       File newFile = await File(archivePath).create(recursive: true);
//       await newFile.writeAsBytes(bytes);
//     }

//     switch (type) {
//       case 'zip':
//         await zip();
//         break;
//       case 'tar':
//         await common('tar');
//         break;
//       case 'tar.gz':
//         await common('tar.gz');
//         break;
//       case 'tar.bz2':
//         await common('tar.bz2');
//         break;
//       default:
//         await zip();
//     }

//     // await for (var item in Stream.fromIterable(originPaths)) {}
//     sendPort.send('done');
//   } catch (err) {
//     sendPort.send('fail');
//   }
// }

// // import 'dart:isolate';
// // import 'package:android_mix/android_mix.dart';
// // import 'package:lan_express/page/file_manager/file_action.dart';

// // void isolateArchive(List msg) async {
// //   SendPort sendPort = msg[0];
// //   Map data = msg[1];
// //   String type = data['type'];
// //   List<String> paths = data['paths'];
// //   String targetDir = data['targetDir'];
// //   String pwd = data['pwd'];

// //   try {
// //     String archivePath = FileAction.genPathWhenExists(targetDir, '.' + type);

// //     switch (type) {
// //       case 'zip':
// //         AndroidMix.archive.zip(
// //           paths,
// //           archivePath,
// //           pwd: pwd?.trim(),
// //           onZip: (data) {},
// //           onZipSuccess: () async {
// //             sendPort.send('done');
// //           },
// //         );
// //         break;
// //     }
// //   } catch (err) {
// //     sendPort.send('fail');
// //   }
// // }

// // await Future.delayed(Duration(milliseconds: 100));

// // switch (archiveType) {
// //   case 'zip':
// //     await AndroidMix.archive.zip(
// //       _shareProvider.selectedFiles
// //           .map((e) => e.entity.path)
// //           .toList(),
// //       FileAction.genPathWhenExists(
// //           _currentDir.path, '.' + archiveType),
// //       pwd: pwd,
// //       onZip: (data) {},
// //       onZipSuccess: () async {
// //         showText('归档成功');
// //         await _shareProvider.clear();
// //         await update2Side();
// //         MixUtils.safePop(context);
// //       },
// //     );
// //     break;
// // }

// // Map data = {
// //   'type': archiveType,
// //   'paths': _shareProvider.selectedFiles
// //       .map((e) => e.entity.path)
// //       .toList(),
// //   'targetDir': _currentDir.path,
// //   'pwd': pwd
// // };
// // await Future.delayed(Duration(milliseconds: 100));

// // isolates.spawn<String>(
// //   isolateArchive,
// //   name: "archive",
// //   // Executed every time data is received from the spawned isolate.
// //   onReceive: (message) async {
// //     if (message == 'done') {
// //       showText('归档完成');
// //       await update2Side();
// //       await _shareProvider.clear();
// //       if (mounted) {
// //         MixUtils.safePop(context);
// //       }
// //       isolates?.kill('archive');
// //     }
// //   },
// //   // Executed once when spawned isolate is ready for communication.
// //   onInitialized: () => isolates.send(data, to: "archive"),
// // );
// // ReceivePort recPort = ReceivePort();
// // SendPort sendPort = recPort.sendPort;
// // FlutterIsolate isolate = await FlutterIsolate.spawn(
// //     isolateArchive, [sendPort, data]);

// // recPort.listen((message) async {
// //   if (message == 'done') {
// //     showText('归档完成');
// //     await update2Side();
// //     await _shareProvider.clear();
// //     if (mounted) {
// //       MixUtils.safePop(context);
// //     }
// //     isolate?.kill();
// //   }
// // });

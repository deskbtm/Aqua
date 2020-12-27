import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/page/file_manager/file_utils.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:photo_manager/photo_manager.dart';

class AppImages {
  static Widget folder({double width = 30, double height = 30}) =>
      Image.asset('assets/images/folder.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget ppt({double width = 30, double height = 30}) =>
      Image.asset('assets/images/ppt.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget ai({double width = 30, double height = 30}) =>
      Image.asset('assets/images/ai.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget exe({double width = 30, double height = 30}) =>
      Image.asset('assets/images/exe.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget cvs({double width = 30, double height = 30}) =>
      Image.asset('assets/images/exe.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget flash({double width = 30, double height = 30}) =>
      Image.asset('assets/images/flash.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget html({double width = 30, double height = 30}) =>
      Image.asset('assets/images/html.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget link({double width = 30, double height = 30}) =>
      Image.asset('assets/images/link.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget excel({double width = 30, double height = 30}) =>
      Image.asset('assets/images/excel.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget image({double width = 30, double height = 30}) =>
      Image.asset('assets/images/image.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget mp4({double width = 30, double height = 30}) =>
      Image.asset('assets/images/mp4.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget unknown({double width = 30, double height = 30}) =>
      Image.asset('assets/images/unknown.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget video({double width = 30, double height = 30}) =>
      Image.asset('assets/images/video.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget word({double width = 30, double height = 30}) =>
      Image.asset('assets/images/word.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget xml({double width = 30, double height = 30}) =>
      Image.asset('assets/images/xml.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget zip({double width = 30, double height = 30}) =>
      Image.asset('assets/images/zip.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget apk({double width = 30, double height = 30}) =>
      Image.asset('assets/images/apk.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget audio({double width = 30, double height = 30}) =>
      Image.asset('assets/images/audio.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget pdf({double width = 30, double height = 30}) =>
      Image.asset('assets/images/pdf.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget psd({double width = 30, double height = 30}) =>
      Image.asset('assets/images/psd.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget txt({double width = 30, double height = 30}) =>
      Image.asset('assets/images/txt.png',
          width: width, height: height, fit: BoxFit.cover);

  static Widget md({double width = 30, double height = 30}) =>
      Image.asset('assets/images/md.png',
          width: width, height: height, fit: BoxFit.cover);
}

Widget getPreviewIcon(
    BuildContext context, ThemeModel themeModel, SelfFileEntity file) {
  Widget previewIcon;
  if (file.ext?.toLowerCase() == '.apk') {
    try {
      if (file.apkIcon != null) {
        previewIcon = Image.memory(
          file.apkIcon,
          width: 35,
          height: 35,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
        );
      } else {
        previewIcon = matchFileIcon(file.ext);
      }
    } catch (err) {
      previewIcon = matchFileIcon(file.ext);
    }
  } else if (IMG_EXTS.contains(file.ext?.toLowerCase())) {
    previewIcon = ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: FutureBuilder<Uint8List>(
        future: PhotoManager.getThumbnailByPath(
            path: file.entity.path, quality: 50),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || snapshot.data == null) {
              return Container(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(OMIcons.errorOutline),
                ),
              );
            } else {
              return Image.memory(
                snapshot.data,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              );
            }
          } else {
            return Container(
              width: 40,
              height: 40,
              child: Center(
                child: Center(child: loadingIndicator(context, themeModel)),
              ),
            );
          }
        },
      ),
    );
  } else if (file.isLink) {
    previewIcon = matchFileIcon('link');
  } else {
    previewIcon = matchFileIcon(file.isDir ? 'folder' : file.ext);
  }
  return previewIcon;
}

// bool isTheAssetsShouldNotUpdateLeading(SelfFileEntity file) {
//   String ext = file.ext?.toLowerCase();
//   return ext == '.apk' || IMG_EXTS.contains(ext);
// }

import 'dart:typed_data';

import 'package:aqua/plugin/glide/glide.dart';
import 'package:flutter/material.dart';
import 'package:aqua/common/widget/function_widget.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

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

Widget getPreviewIcon(BuildContext context, SelfFileEntity file) {
  Widget previewIcon;
  ThemeModel themeModel = Provider.of<ThemeModel>(context, listen: false);
  if (file.ext == '.apk') {
    try {
      if (file.apkIcon != null) {
        previewIcon = Image.memory(
          file.apkIcon!,
          width: 35,
          height: 35,
          fit: BoxFit.fitWidth,
          gaplessPlayback: true,
        );
      } else {
        previewIcon = FsUtils.matchFileIcon(file.ext);
      }
    } catch (err) {
      previewIcon = FsUtils.matchFileIcon(file.ext);
    }
  } else if (FsUtils.HAVE_THUMBNAIL.contains(file.ext)) {
    previewIcon = FutureBuilder<Uint8List?>(
      future: AquaGlide.getLocalThumbnail(
        path: file.entity.path,
        width: 50,
        height: 50,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            return Container(
              width: 40,
              height: 40,
              child: Center(
                child: FaIcon(FontAwesomeIcons.bomb),
              ),
            );
          } else {
            Widget img = ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              child: Image.memory(
                snapshot.data,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
              ),
            );

            return Container(
              width: 35,
              height: 35,
              child: FsUtils.VIDEO_EXTS.contains(file.ext)
                  ? Stack(
                      children: [
                        img,
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )
                  : img,
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
    );
  } else if (file.isLink) {
    previewIcon = FsUtils.matchFileIcon('link');
  } else {
    previewIcon = FsUtils.matchFileIcon(file.isDir ? 'folder' : file.ext);
  }
  return previewIcon;
}

// bool isTheAssetsShouldNotUpdateLeading(SelfFileEntity file) {
//   String ext = file.ext?.toLowerCase();
//   return ext == '.apk' || IMG_EXTS.contains(ext);
// }

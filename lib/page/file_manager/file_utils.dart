import 'package:flutter/widgets.dart';
import 'package:lan_express/common/widget/images.dart';

void matchFileExt(
  String ext, {
  Function casePPT,
  Function caseWord,
  Function caseCVS,
  Function caseFlash,
  Function caseExcel,
  Function caseHtml,
  Function casePdf,
  Function caseImage,
  Function caseText,
  Function caseAudio,
  Function caseMP4,
  Function caseVideo,
  Function caseArchive,
  Function casePs,
  Function caseApk,
  Function caseFolder,
  Function caseSymbolLink,
  Function caseMd,
  Function caseZip,
  Function defaultExec,
}) {
  ext = ext.toLowerCase();
  switch (ext) {
    case '.ppt':
    case '.pptx':
      if (casePPT != null) casePPT();
      break;
    case '.doc':
    case '.docx':
      if (caseWord != null) caseWord();
      break;
    case '.cvs':
      if (caseCVS != null) caseCVS();
      break;
    case '.swf':
      if (caseFlash != null) caseFlash();
      break;
    case '.xls':
    case '.xlsx':
      if (caseExcel != null) caseExcel();
      break;
    case '.htm':
    case '.html':
      if (caseHtml != null) caseHtml();
      break;
    case '.pdf':
      if (casePdf != null) casePdf();
      break;
    case '.jpg':
    case '.jpeg':
    case '.png':
    case '.gif':
    case '.bmp':
    case '.webp':
      if (caseImage != null) caseImage();
      break;
    case '.txt':
      if (caseText != null) caseText();
      break;
    case '.flac':
    case '.mp3':
    case '.wav':
    case '.mid':
      if (caseAudio != null) caseAudio();
      break;
    case '.mp4':
      if (caseMP4 != null) caseMP4();
      break;
    case '.md':
      if (caseMd != null) caseMd();
      break;
    case '.flv':
    case '.avi':
    case '.mov':
    case '.wmv':
    case '.rmvb':
    case '.rm':
    case '.asf':
    case '.mpg':
    case '.mpeg':
      if (caseVideo != null) caseVideo();
      break;
    case '.zip':
      if (caseZip != null) caseZip();
      break;
    case '.rar':
    case '.gz':
    case '.cz':
    case '.xz':
    case '.tar':
    case '.tgz':
    case '.bz':
    case '.bz2':
    case '.tbz2':
      if (caseArchive != null) caseArchive();
      break;
    case '.psd':
      if (casePs != null) casePs();
      break;
    case '.apk':
      if (caseApk != null) caseApk();
      break;
    case 'folder':
      if (caseFolder != null) caseFolder();
      break;
    case 'link':
      if (caseSymbolLink != null) caseSymbolLink();
      break;
    default:
      if (defaultExec != null) defaultExec();
      break;
  }
}

Widget matchFileIcon(String ext, {double size = 30}) {
  Widget iconImg;

  matchFileExt(
    ext,
    casePPT: () {
      iconImg = AppImages.ppt();
    },
    caseWord: () {
      iconImg = AppImages.word();
    },
    caseCVS: () {
      iconImg = AppImages.cvs();
    },
    caseFlash: () {
      iconImg = AppImages.flash();
    },
    caseExcel: () {
      iconImg = AppImages.excel();
    },
    caseHtml: () {
      iconImg = AppImages.html();
    },
    casePdf: () {
      iconImg = AppImages.pdf();
    },
    caseImage: () {
      iconImg = AppImages.image();
    },
    caseText: () {
      iconImg = AppImages.txt();
    },
    caseAudio: () {
      iconImg = AppImages.audio();
    },
    caseMP4: () {
      iconImg = AppImages.mp4();
    },
    caseVideo: () {
      iconImg = AppImages.video();
    },
    caseZip: () {
      iconImg = AppImages.zip();
    },
    caseArchive: () {
      iconImg = AppImages.zip();
    },
    casePs: () {
      iconImg = AppImages.psd();
    },
    caseApk: () {
      iconImg = AppImages.apk();
    },
    caseFolder: () {
      iconImg = AppImages.folder();
    },
    caseSymbolLink: () {
      iconImg = AppImages.link();
    },
    caseMd: () {
      iconImg = AppImages.md();
    },
    defaultExec: () {
      iconImg = AppImages.unknown();
    },
  );

  return iconImg;
}

// ignore: non_constant_identifier_names
List<String> IMG_EXTS = [
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.webp',
];

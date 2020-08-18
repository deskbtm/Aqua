import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:shelf/shelf.dart';

String _getHeader(String sanitizedHeading, String logo,
    {bool isShareFiles = false, bool isDark}) {
  return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>$sanitizedHeading</title>
  <link rel="shortcut icon" href="data:image/png;base64,$logo">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>

  *{
    color: ${isDark ? '#fff' : '#242424'}; 
    font-size: 14px; 
  }

  button{
    border: none;
    outline: none;
  }

  html, body {
    margin: 0;
    padding: 0;
  }

  body {
    font-family: sans-serif;
    background-color: ${isDark ? '#000' : '#fff'};
  }

  .click-scale{
    transition: transform 500ms ease;
  }

  .click-scale:hover{}

  .click-scale:active{
    transform: scale(0.95);
  }

  section{
    display: flex;
    justify-content: center;
    margin-bottom: 200px;
  }

  ul {
    margin: 0;
    padding: 0;
  }

  ul >  .heading-item{
    background-color: #2196f3;
    justify-content: space-between
  }

  ul > .func-item{
    padding: 5px 10px;
    transition: unset;
  }
  
  ul > .func-item:active{
    transform: unset;
  }

  ul > .func-item button{
    border-radius: 5px;
    background-color: #2196f3;
    margin: 10px;
    padding: 6px;
  }

  ul .item div{
    width: 80%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .icon{
    padding: 10px 5px;
    width: 30px;
    height: 30px;
  }

  .tiny-func{
    height: 100px;
  }
  
  .item {
    padding: 5px 20px;
    background-color: #dedede78;
    margin-top: 20px;
    border-radius: 5px;
    animation: admittance 500ms ease;
    display: flex;
    align-items: center;
    position: relative;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .download-tip{
    position: absolute;
    right: 30px;
  }

  @keyframes admittance{
    from {
      transform: scale(0.8);
      opacity: 0.6;
    }
    to {
      transform: scale(1);
      opacity: 1;
    }
  }

  @media only screen and (min-width: 200px) {
    ul{
      width: 94vw;
    }
  }

  @media only screen and (min-width: 1000px) {
    ul{
      width: 60vw;
    }
  }

  </style>
</head>
<body>
<div class='modal'>
  <div class="mask"></div>
</div>
<section>
  <ul>
  <li class="item heading-item">
    <div>$sanitizedHeading</div>
    <img class="icon" src="data:image/png;base64, $logo"/>
  </li>

  ${isShareFiles ? """
    <li class='item func-item'>
    <button class='click-scale download-all'>下载全部</button>
    <button class='click-scale upload'>发送</button>
  </li>
  """ : """
  <li class='item func-item'>
    <button class='click-scale upload'>发送</button>
  </li>
  """}
  
''';
}

String _trailer({bool isShareFiles = false}) {
  return '''
</ul>
</section>
<script>


if($isShareFiles){
  var files = document.getElementsByClassName('file-path');
  var downloadBtn = document.querySelector('.download-all');
  downloadBtn.onclick = function(){
    for(var i = 0; i < files.length; i  ++){
      files[i].click();
    }
  }
}
</script>
</body>
</html>
''';
}

Future<Map> _loadIcons() async {
  // rootBundle.loadString()

  return {
    'ppt': base64Encode(
        (await rootBundle.load('assets/images/ppt.png')).buffer.asUint8List()),
    'word': base64Encode(
        (await rootBundle.load('assets/images/word.png')).buffer.asUint8List()),
    'ai': base64Encode(
        (await rootBundle.load('assets/images/ai.png')).buffer.asUint8List()),
    'exe': base64Encode(
        (await rootBundle.load('assets/images/exe.png')).buffer.asUint8List()),
    'cvs': base64Encode(
        (await rootBundle.load('assets/images/csv.png')).buffer.asUint8List()),
    'flash': base64Encode((await rootBundle.load('assets/images/flash.png'))
        .buffer
        .asUint8List()),
    'folder': base64Encode((await rootBundle.load('assets/images/folder.png'))
        .buffer
        .asUint8List()),
    'html': base64Encode(
        (await rootBundle.load('assets/images/html.png')).buffer.asUint8List()),
    'link': base64Encode(
        (await rootBundle.load('assets/images/link.png')).buffer.asUint8List()),
    'execl': base64Encode((await rootBundle.load('assets/images/excel.png'))
        .buffer
        .asUint8List()),
    'image': base64Encode((await rootBundle.load('assets/images/image.png'))
        .buffer
        .asUint8List()),
    'mp4': base64Encode(
        (await rootBundle.load('assets/images/mp4.png')).buffer.asUint8List()),
    'unknown': base64Encode((await rootBundle.load('assets/images/unknown.png'))
        .buffer
        .asUint8List()),
    'video': base64Encode((await rootBundle.load('assets/images/video.png'))
        .buffer
        .asUint8List()),
    'xml': base64Encode(
        (await rootBundle.load('assets/images/xml.png')).buffer.asUint8List()),
    'zip': base64Encode(
        (await rootBundle.load('assets/images/zip.png')).buffer.asUint8List()),
    'apk': base64Encode(
        (await rootBundle.load('assets/images/apk.png')).buffer.asUint8List()),
    'audio': base64Encode((await rootBundle.load('assets/images/audio.png'))
        .buffer
        .asUint8List()),
    'pdf': base64Encode(
        (await rootBundle.load('assets/images/pdf.png')).buffer.asUint8List()),
    'psd': base64Encode(
        (await rootBundle.load('assets/images/psd.png')).buffer.asUint8List()),
    'txt': base64Encode(
        (await rootBundle.load('assets/images/txt.png')).buffer.asUint8List()),
    'md': base64Encode(
        (await rootBundle.load('assets/images/md.png')).buffer.asUint8List()),
    'logo': base64Encode(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List()),
  };
}

String matchIcon(String ext, Map icons) {
  String iconImg;
  matchFileExt(
    ext,
    casePPT: () {
      iconImg = icons['ppt'];
    },
    caseWord: () {
      iconImg = icons['word'];
    },
    caseCVS: () {
      iconImg = icons['cvs'];
    },
    caseFlash: () {
      iconImg = icons['flash'];
    },
    caseExcel: () {
      iconImg = icons['excel'];
    },
    caseHtml: () {
      iconImg = icons['html'];
    },
    casePdf: () {
      iconImg = icons['pdf'];
    },
    caseImage: () {
      iconImg = icons['image'];
    },
    caseText: () {
      iconImg = icons['txt'];
    },
    caseAudio: () {
      iconImg = icons['audio'];
    },
    caseMP4: () {
      iconImg = icons['mp4'];
    },
    caseVideo: () {
      iconImg = icons['video'];
    },
    caseArchive: () {
      iconImg = icons['zip'];
    },
    casePs: () {
      iconImg = icons['psd'];
    },
    caseApk: () {
      iconImg = icons['apk'];
    },
    caseFolder: () {
      iconImg = icons['folder'];
    },
    caseSymbolLink: () {
      iconImg = icons['link'];
    },
    caseMd: () {
      iconImg = icons['md'];
    },
    defaultExec: () {
      iconImg = icons['unknown'];
    },
  );

  return iconImg;
}

Future<Response> listDirectory(String fileSystemPath, String dirPath,
    {bool isDark}) async {
  StreamController<List<int>> controller = new StreamController<List<int>>();
  Encoding encoding = new Utf8Codec();
  HtmlEscape sanitizer = const HtmlEscape();
  Map icons = await _loadIcons();

  void add(String string) {
    controller.add(encoding.encode(string));
  }

  var heading = pathLib.relative(dirPath, from: fileSystemPath);
  if (heading == '.') {
    heading = '/';
  } else {
    heading = '/$heading/';
  }

  add(_getHeader(sanitizer.convert(heading), icons['logo'], isDark: isDark));

  // Return a sorted listing of the directory contents asynchronously.
  Directory(dirPath).list().toList().then((entities) {
    entities.sort((e1, e2) {
      if (e1 is Directory && e2 is! Directory) {
        return -1;
      }
      if (e1 is! Directory && e2 is Directory) {
        return 1;
      }
      return e1.path.compareTo(e2.path);
    });

    for (var entity in entities) {
      String name = pathLib.relative(entity.path, from: dirPath);
      String ext = pathLib.extension(name);
      bool isDir = entity is Directory;
      if (isDir) {
        name += '/';
        ext = 'folder';
      }
      String sanitizedName = sanitizer.convert(name);
      // 非链接强制下载
      add("""
      <a href="$sanitizedName" ${isDir ? '' : 'download="$sanitizedName"'}>
        <li class="item click-scale">
          <img  class="icon" src="data:image/png;base64, ${matchIcon(ext, icons)}"/>
          <div>$sanitizedName</div>
          ${isDir ? '' : '<span class="download-tip">下载</span>'}
        </li>
      </a>""");
    }

    add(_trailer());
    controller.close();
  });

  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

Future<Response> listFiles(List<String> paths, {bool isDark}) async {
  // ignore: close_sinks
  StreamController<List<int>> controller = new StreamController<List<int>>();
  HtmlEscape sanitizer = const HtmlEscape();
  Encoding encoding = new Utf8Codec();
  void add(String string) {
    controller.add(encoding.encode(string));
  }

  Map icons = await _loadIcons();

  add(_getHeader('共享列表', icons['logo'], isShareFiles: true, isDark: isDark));

  for (var path in paths) {
    String name = pathLib.basename(path);
    String ext = pathLib.extension(path);
    File file = File(path);
    // File(path)
    bool isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      name += '/';
      ext = 'folder';
    }
    String sanitizedName = sanitizer.convert(name);

    add("""
      <a class="${isDir ? 'dir-path' : 'file-path'}" href="$path" ${isDir ? '' : 'download="$sanitizedName"'}>
        <li class="item click-scale">
          <img class="icon" src="data:image/png;base64, ${matchIcon(ext, icons)}"/>
          <div>$sanitizedName</div>
          ${isDir ? '' : '<span class="download-tip">下载</span>'}
        </li>
      </a>""");
  }
  add(_trailer(isShareFiles: true));
  controller.close();
  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

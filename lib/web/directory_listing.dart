import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:lan_express/page/file_manager/file_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:shelf/shelf.dart';

Future<String> _getHeader(String sanitizedHeading, String logo,
    {bool isShareFiles = false, bool isDark}) async {
  return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>$sanitizedHeading</title>
  <link rel="shortcut icon" href="data:image/png;base64,$logo">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script>
  </script>
  <style>

  *{
    color: ${isDark ? '#fff' : '#242424'}; 
    font-size: 14px; 
  }

  button{
    border: none;
    outline: none;
    white-space: nowrap;
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
    transition: transform 300ms ease;
  }

  .click-scale:hover{}

  .click-scale:active{
    transform: scale(0.9);
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

  ul > .heading-item{
    background-color: #2196f3;
    justify-content: space-between
  }

  ul > .func-item{
    padding: 5px 10px;
    transition: unset;
    box-sizing: border-box;
    height: 65px;
  }

  ul > .func-item.dashed{
    border: 3px dashed #000;
    box-sizing: border-box;
  }
  
  ul > .func-item:active{
    transform: unset;
  }

  ul > .func-item button{
    border-radius: 5px;
    background-color: #2196f3;
    margin: 10px;
    height: 36px;
  }

  ul .item .file-name{
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

  .drag-txt{
    color: #aaa;
    transform: rotate(-25deg);
    position: absolute;right: 15px;
  }
  
  #select-file{
    position: relative;
  }

  #select-file input{
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    width: 40px;
    height: 35px;
    opacity: 0;
  }

  .chip {
    display: flex;
    align-items: center;
  }

  .close-btn{
    width: 15px;
    height: 15px;
    border-radius: 10px;
    background-color: #fff;
    margin-left: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
  }

  .close-btn::before{
    position: absolute;
    content: ' ';
    width: 2px;
    height: 9px;
    background-color: #505050;
    display: block;
    transform: rotate(45deg);
  }

  .close-btn::after{
    position: absolute;
    content: ' ';
    width: 2px;
    height: 8px;
    background-color: #505050;
    display: block;
    transform: rotate(-45deg);
  }

  #chip-wrapper{
    width: 70%;
    height: 65px;
    display:flex;
    overflow-x: auto;
    overflow-y: hidden;
    align-items: center;
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

  <li class='item func-item'>
  ${isShareFiles ? "<button class='click-scale download-all'>下载全部</button>" : ""}
    <button id='upload' class='click-scale'>上传</button>
    <button id='select-file' class='click-scale'>选择<input id="input-file" type='file' multiple/></button>
    <span id='chip-wrapper'></span>
    <h2 class="drag-txt">可拖拽到此</h2>
  </li>
''';
}

String _trailer({bool isShareFiles = false, String serverUrl}) {
  return '''
</ul>
</section>
<script>

var willUploadFiles = [];

var delFileFromWrapper  = function(name){
  removeFile(name);
  renderFileChips();
}

var fileChip = fileName =>  "<button class='click-scale chip'><span>" + fileName + 
"</span><div class='close-btn' onclick='delFileFromWrapper(" + '"' + fileName + '"' + ")'></div></button>";

var selectFileBtn = document.getElementById('select-file');
var inputFile = document.getElementById('input-file');
var chipWrapper = document.getElementById('chip-wrapper');
var uploadBtn = document.getElementById('upload');

var toast = function(msg, duration){
  duration=isNaN(duration)?3000:duration;
  var m = document.createElement('div');
  m.innerHTML = msg;
  m.style.cssText="max-width:60%;min-width: 150px;padding:0 14px;height: 40px;color: rgb(255, 255, 255);line-height: 40px;text-align: center;border-radius: 4px;position: fixed;top: 50%;left: 50%;transform: translate(-50%, -50%);z-index: 999999;background: rgba(0, 0, 0,.7);font-size: 16px;";
  document.body.appendChild(m);
  setTimeout(function() {
    var d = 0.5;
    m.style.webkitTransition = '-webkit-transform ' + d + 's ease-in, opacity ' + d + 's ease-in';
    m.style.opacity = '0';
    setTimeout(function() { document.body.removeChild(m) }, d * 1000);
  }, duration);
}

uploadBtn.onclick = function(e){
  e.preventDefault();
  var formData = new FormData();
  willUploadFiles.forEach((file, index)=>{
    formData.append('file' + index,  file, file.name);
  })
  var xhr = new XMLHttpRequest();
  xhr.open('POST','/upload_file');
  xhr.send(formData)
  xhr.onreadystatechange = function(){
    if(xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 404)){
      try{
        var a = JSON.parse(xhr.responseText);
        toast(a.msg,  2000);
      }catch(e){
        toast('出现位置错误',  2000);
      }
    }
  };
}

inputFile.onchange = function(e){
  e.preventDefault();
  Object.values(inputFile.files).forEach((file)=>{addFile(file);});
  renderFileChips();
}

var renderFileChips = function(){
  chipWrapper.innerHTML = willUploadFiles.map((file)=>{
    return fileChip(file.name);
  }).join('');
}

var existsFile = function (name){
  return willUploadFiles.some((file)=>{
    return file.name === name;
  })
}

var addFile = function(file){
  if(existsFile(file.name)){
    alert(file.name + '已存在');
  }else{
    willUploadFiles.push(file);
  }
}

var removeFile = function(name){
  var offset = willUploadFiles.findIndex((f, i)=>{
    return f.name === name;
  });
  
  inputFile.value = '';
  willUploadFiles.splice(offset, 1);
}

if($isShareFiles){
  var files = document.getElementsByClassName('file-path');
  var downloadBtn = document.querySelector('.download-all');
  downloadBtn.onclick = function(){
    for(var i = 0; i < files.length; i  ++){
      files[i].click();
    }
  }
}

if("$serverUrl" != "null"){
  var funcItem = document.getElementsByClassName('func-item')[0];
  funcItem.ondragover = function(e){
    e.preventDefault();
    funcItem.classList.add('dashed');
  }

  funcItem.ondragleave = function(e){
    e.preventDefault();
    funcItem.classList.remove('dashed');
  }

  funcItem.ondrop = function(e){
    e.preventDefault();
    funcItem.classList.remove('dashed');
    Object.values(e.dataTransfer.files).forEach((file)=>{addFile(file);});
    renderFileChips();
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
    {bool isDark, String serverUrl}) async {
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

  add(await _getHeader(sanitizer.convert(heading), icons['logo'],
      isDark: isDark));

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
          <div class="file-name">$sanitizedName</div>
          ${isDir ? '' : '<span class="download-tip">下载</span>'}
        </li>
      </a>""");
    }

    add(_trailer(serverUrl: serverUrl));
    controller.close();
  });

  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

Future<Response> listFiles(List<String> paths,
    {bool isDark, String serverUrl}) async {
  // ignore: close_sinks
  StreamController<List<int>> controller = new StreamController<List<int>>();
  HtmlEscape sanitizer = const HtmlEscape();
  Encoding encoding = new Utf8Codec();
  void add(String string) {
    controller.add(encoding.encode(string));
  }

  Map icons = await _loadIcons();

  add(await _getHeader('共享列表', icons['logo'],
      isShareFiles: true, isDark: isDark));

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
          <div class="file-name">$sanitizedName</div>
          ${isDir ? '' : '<span class="download-tip">下载</span>'}
        </li>
      </a>""");
  }
  add(_trailer(isShareFiles: true, serverUrl: serverUrl));
  controller.close();
  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

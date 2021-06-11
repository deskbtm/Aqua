import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:aqua/page/file_manager/fs_utils.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:path/path.dart' as pathLib;
import 'package:shelf/shelf.dart';

Future<String> _getHeader(String sanitizedHeading, String logo,
    {bool isShareFiles = false, required bool isDark}) async {
  String plyrJs = await rootBundle.loadString('/assets/web/plyr.js');
  String plyrCss = await rootBundle.loadString('/assets/web/plyr.css');

  return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>$sanitizedHeading</title>
  <link rel="shortcut icon" href="data:image/png;base64,$logo">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  ${MixUtils.isDev ? '<script src="https://cdn.bootcdn.net/ajax/libs/eruda/2.4.1/eruda.min.js"></script>' : ''}
  <script>$plyrJs</script>
  <style>$plyrCss</style>
  <style>
  *{
    font-size: 14px;
  }

  html, body {
    margin: 0;
    padding: 0;
  }

  li {
    list-style: none;
  }

  body {
    font-family: sans-serif;
    background-color: ${isDark ? '#000' : '#fff'};
  }

  button {
    border: none;
    outline: none;
    white-space: nowrap;
  }

  #mask {
    position: fixed;
    z-index: 1000;
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .c-btn {
    border-radius: 5px;
    background-color: #2196f3;
    margin: 10px;
    height: 29px;
    color: ${isDark ? '#fff' : '#242424'};
    transition: transform 300ms ease;
  }

  .c-btn:hover {}

  .c-btn:active {
    transform: scale(0.7);
  }

  .mask-bg {
    width: 100%;
    height: 100%;
    position: fixed;
    background-color: #000000;
    z-index: 999;
    opacity: 0.2;
    animation: opacity-display 500ms ease;
  }

  #mask.hidden{
    display: none;
  }

  #mask .display-stage{
    z-index: 1001;
    width: 600px;
    position: relative;
  }

  #mask .display-stage img{
    width: 500px;
    height: 500px;
    object-fit: contain;
    position: absolute;
    left: 50%;
    top: 50%;
    margin-left: -250px;
    margin-top: -250px;
  }

  #mask .display-stage video {
    width: 100%;
  }

  @keyframes opacity-display{
    from {
      opacity: 0;
    } to {
      opacity: 0.2;
    }
  }

  .click-scale{
    transition: transform 300ms ease;
  }

  .click-scale:hover{}

  .click-scale:active{
    transform: scale(0.9);
  }
    
  .plyr {
    border-radius: 6px;
    margin-bottom: 15px;
  }

  section {
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
    display: flex;
    align-items: center;
  }

  ul > .func-item h2{
    margin: 0;
  }

  ul > .func-item.dashed{
    border: 3px dashed #000;
    box-sizing: border-box;
  }
  
  ul > .func-item:active{
    transform: unset;
  }

  ul .item .file-name {
    width: 80%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .link-item {
    display: inline-block;
    width: 80%;
  }

  .content-wrapper{
    display: flex;
    align-items: center;
  }

  .icon{
    padding: 10px 5px;
    width: 30px;
    height: 30px;
    object-fit: contain;
  }

  .tiny-func{
    height: 100px;
  }

  .item-container *{
    color: ${isDark ? '#fff' : '#242424'};
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
    right: 20px;
    z-index: 10;
  }

  .drag-txt{
    color: #aaa;
    transform: rotate(-25deg);
    position: absolute;
    right: 15px;
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

  #chip-wrapper {
    width: 70%;
    height: 65px;
    display:flex;
    overflow-x: auto;
    overflow-y: hidden;
    align-items: center;
  }

  @keyframes admittance {
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

  .line {
    display: inline-block;
    width: 15px;
    height: 15px;
    border-radius: 15px;
    background-color: #2196f3;
    margin:  0 2.5px;
  }

  .load-1{
    display: flex;
    justify-content: center;
    height: 20px;
  }

  .load-1 .line:nth-last-child(1) {
    animation: loadingA 1.5s 1s infinite;
  }
  .load-1 .line:nth-last-child(2) {
    animation: loadingA 1.5s 0.5s infinite;
  }
  .load-1 .line:nth-last-child(3) {
    animation: loadingA 1.5s 0s infinite;
  }

  @keyframes loadingA {
    0 {
      height: 15px;
    }
    50% {
      height: 35px;
    }
    100% {
      height: 15px;
    }
  }


  </style>
</head>
<body>
<div id="mask" class="hidden">
  <div class="mask-bg" onclick="toggleMask()"></div>
  <div class="display-stage"></div>
</div>

<section class="item-container">
  <ul>
  <li class="item heading-item">
    <div>$sanitizedHeading</div>
    <img class="icon" src="data:image/png;base64, $logo"/>
  </li>

  <li class='item func-item'>
  ${isShareFiles ? "<button class='c-btn download-all'>下载全部</button>" : ""}
    <button id='upload' class='c-btn'>上传</button>
    <button id='select-file' class='c-btn'>选择<input id="input-file" type='file' multiple/></button>
    <span id='chip-wrapper'></span>
    <h2 class="drag-txt">可拖拽到此</h2>
  </li>
''';
}

String _trailer({bool isShareFiles = false, required String serverUrl}) {
  return '''
</ul>
</section>
<script>

if(${MixUtils.isDev}){
  // if(!!eruda){
  //   eruda.init();
  // }
}

var controls = [
  'play-large',
  'restart',
  'play',
  'progress',
  'current-time',
  'duration',
  'mute',
  'volume',
  'captions',
  'settings',
  'pip',
  'airplay',
  'download',
  'fullscreen'
];

var videoExts =  [
  '.mp4',
  '.flv',
  '.avi',
  '.mov',
  '.wmv',
  '.rmvb',
  '.rm',
  '.asf',
  '.mpg',
  '.mpeg',
];

var imgExts =  [
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.webp',
];

var mask = document.getElementById('mask');
var displayStage = document.querySelector('.display-stage');

var downloadURI = function(uri, name) {
  var link = document.createElement("a");
  link.setAttribute('download', name);
  link.href = uri;
  document.body.appendChild(link);
  link.click();
  link.remove();
}

var toggleMask = function(){
  if(mask.classList.contains('hidden')){
    mask.classList.remove('hidden');
  }else{
    mask.classList.add('hidden');
  }
}

var clickItem = function(e, name = ''){
  name = name.toLowerCase();
  e = e || window.event;
  var isVideo = videoExts.some((val)=> name.indexOf(val) > -1);
  var isImg = imgExts.some((val)=> name.indexOf(val) > -1);

  if(isVideo){
    e.preventDefault();
    
    toggleMask();

    displayStage.innerHTML = '<video controls crossorigin id="player" src="' + name + '"></video>';

    var player = new Plyr('#player', {controls});
    // 播放器下载按钮
    document.querySelector('[data-plyr="download"]').onclick = function(de){
      de.preventDefault();
      downloadURI(name, name);
    }
    return;
  }

  if(isImg){
    e.preventDefault();
    toggleMask();
    displayStage.innerHTML = '<img src="' + name + '"></img>';
    return;
  }

}

// 判断是否分享单个文件
if($isShareFiles){
  var files = document.getElementsByClassName('download-tip');
  var downloadBtn = document.querySelector('.download-all');
  downloadBtn.onclick = function(){
    for(var i = 0; i < files.length; i  ++){
      files[i].click();
    }
  }
}

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

var loadingModal = function(){
  toggleMask();
  displayStage.innerHTML = '<div class="load-1"><div class="line"></div><div class="line"></div><div class="line"></div></div>';
}

var clearLoadingModal = function(){
  mask.classList.add('hidden');
  displayStage.innerHTML = '';
}

if("$serverUrl" != "null"){

  var funcItem = document.getElementsByClassName('func-item')[0];
  var selectFileBtn = document.getElementById('select-file');
  var inputFile = document.getElementById('input-file');
  var chipWrapper = document.getElementById('chip-wrapper');
  var uploadBtn = document.getElementById('upload');

  var fileChip = fileName =>  "<button class='chip c-btn'><span>" + fileName + 
  "</span><div class='close-btn' onclick='delFileFromWrapper(" + '"' + fileName + '"' + ")'></div></button>";

  // 存放将要上传的文件
  var willUploadFiles = [];

  var delFileFromWrapper  = function(name){
    removeFile(name);
    renderFileChips();
  }

  uploadBtn.onclick = function(e){
    e.preventDefault();
    var formData = new FormData();
    willUploadFiles.forEach((file, index)=>{
      formData.append('file' + index,  file, file.name);
    })
    var xhr = new XMLHttpRequest();
    xhr.open('POST','/upload_file');
    loadingModal();
    xhr.send(formData);
    xhr.onreadystatechange = function(){
      if(xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 404)){
        try{
          var a = JSON.parse(xhr.responseText);
          willUploadFiles = [];
          chipWrapper.innerHTML = '';
          clearLoadingModal();
          toast(a.msg,  2000);
        }catch(e){
          toast('出现未知错误',  2000);
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
}else{
  toast('服务器地址 出现未知错误',  2000);
}

</script>
</body>
</html>
''';
}

Future<Map> _loadIcons() async {
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
  late String iconImg;
  FsUtils.matchFileExt(
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
    {required bool isDark, required String serverUrl}) async {
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
      String base64Icon = "data:image/png;base64, ${matchIcon(ext, icons)}";
      // 非链接强制下载
      add("""
        <li class="item ${isDir ? 'click-scale' : ''}">
          <a class="link-item" onclick='clickItem(event, "$sanitizedName", this)' href="${isDir ? sanitizedName : 'javascript:void(0)'}">
            <div class="content-wrapper">
              <img class="icon" src="${FsUtils.IMG_EXTS.any((val) => sanitizedName.endsWith(val)) ? sanitizedName : base64Icon}"/>
              <div class="file-name">$sanitizedName</div>
            </div>
          </a>
          ${isDir ? '' : '<a  class="download-tip" href="$sanitizedName" download="$sanitizedName"><button class="c-btn">下载</button></a>'}
        </li>
      """);
    }

    add(_trailer(serverUrl: serverUrl));
    controller.close();
  });

  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

Future<Response> listFiles(List<String> paths,
    {required bool isDark, required String serverUrl}) async {
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
    bool isDir = file.statSync().type == FileSystemEntityType.directory;
    if (isDir) {
      name += '/';
      ext = 'folder';
    } else {
      name = path;
    }
    String sanitizedName = sanitizer.convert(name);
    String base64Icon = "data:image/png;base64, ${matchIcon(ext, icons)}";

    add("""
      <li class="item ${isDir ? 'click-scale' : ''}">
        <a class="link-item" onclick='clickItem(event, "$sanitizedName", this)' href="${isDir ? sanitizedName : 'javascript:void(0)'}">
          <div class="content-wrapper">
            <img class="icon" src="${FsUtils.IMG_EXTS.any((val) => sanitizedName.endsWith(val)) ? sanitizedName : base64Icon}"/>
            <div class="file-name">$sanitizedName</div>
          </div>
        </a>
        ${isDir ? '' : '<a  class="download-tip" href="$sanitizedName" download="$sanitizedName"><button class="c-btn">下载</button></a>'}
      </li>
    """);
  }
  add(_trailer(isShareFiles: true, serverUrl: serverUrl));
  controller.close();
  return new Response.ok(controller.stream,
      encoding: encoding,
      headers: {HttpHeaders.contentTypeHeader: 'text/html'});
}

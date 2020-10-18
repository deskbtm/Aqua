import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/external/bot_toast/src/toast.dart';
import 'package:lan_express/page/file_manager/file_action.dart';
import 'package:lan_express/utils/mix_utils.dart';

// ignore: must_be_immutable
class FileInfoCard extends StatefulWidget {
  final SelfFileEntity file;
  final bool showSize;
  final List<List> additionalList;

  const FileInfoCard({
    Key key,
    @required this.file,
    this.showSize = false,
    this.additionalList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileInfoCardState();
  }
}

class _FileInfoCardState extends State<FileInfoCard> {
  SelfFileEntity get file => widget.file;
  bool get showSize => widget.showSize;
  StreamSubscription<FileSystemEntity> _listener;
  int _totalSize;
  int _fileCount;
  bool _mutex;

  @override
  void initState() {
    super.initState();
    _totalSize = 0;
    _fileCount = 0;
    _mutex = true;
  }

  @override
  void dispose() {
    super.dispose();
    _listener?.cancel();
    _mutex = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (showSize) {
      if (file.isDir) {
        Directory dir = Directory(file.entity.path);
        _listener = dir.list(recursive: true).listen((event) async {
          FileStat stat = await event.stat();
          if (mounted) {
            setState(() {
              _totalSize += stat.size;
              _fileCount++;
            });
          }
        }, onDone: () {
          _mutex = false;
        });
      } else {
        setState(() {
          _totalSize = file.size;
          _fileCount = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CupertinoThemeData themeData = CupertinoTheme.of(context);

    List<List> info = [
      ['文件名', file.filename],
      ['路径', file.entity.path],
      ['修改日期', MixUtils.formatFileTime(file.modified)],
      ['权限', file.modeString]
    ];

    if (widget.additionalList != null) {
      info.addAll(widget.additionalList);
    }

    if (showSize) {
      if (_mutex) {
        didChangeDependencies();
        _mutex = false;
      }
      info.addAll([
        ['文件大小', MixUtils.humanStorageSize(_totalSize.toDouble())],
        ['文件数', '$_fileCount'],
      ]);
    }

    return CupertinoTheme(
      data: CupertinoThemeData(textTheme: themeData.textTheme),
      child: Scrollbar(
        child: ListView.builder(
          itemCount: info.length,
          itemBuilder: (context, index) {
            List cur = info[index];
            return GestureDetector(
              onLongPressStart: (details) async {
                await Clipboard.setData(ClipboardData(text: cur[1]));
                BotToast.showText(text: '已复制到剪贴板');
              },
              child: Container(
                padding:
                    EdgeInsets.only(left: 30, right: 20, top: 3, bottom: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    NoResizeText('${cur[0]}'),
                    SizedBox(width: 20),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth:
                              (MediaQuery.of(context).size.width * 2) / 3 - 15),
                      child: NoResizeText(
                        '${cur[1]}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // FadeIn(
      //   // Optional paramaters
      //   duration: Duration(milliseconds: 500),
      //   curve: Curves.easeIn,
      //   child:
      //   ),
    );
  }
}

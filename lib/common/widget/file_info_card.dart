import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/page/file_manager/file_utils.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

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
  ThemeModel _themeModel;
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
    _themeModel = Provider.of<ThemeModel>(context);

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
    AquaTheme themeData = _themeModel?.themeData;

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

    return Scrollbar(
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
              margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Wrap(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 6, bottom: 6),
                          decoration: BoxDecoration(
                            color: themeData.actionButtonColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: NoResizeText('${cur[0]}'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      child: NoResizeText(
                        '${cur[1]}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

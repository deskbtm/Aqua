import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class FileInfoCard extends StatefulWidget {
  final SelfFileEntity file;
  final bool showSize;
  final List<List>? additionalList;

  const FileInfoCard({
    Key? key,
    required this.file,
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
  late StreamSubscription<FileSystemEntity> _listener;
  late ThemeModel _themeModel;
  late int _totalSize;
  late int _fileCount;
  late bool _mutex;

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
    AquaTheme themeData = _themeModel.themeData;

    List<List> info = [
      [AppLocalizations.of(context)!.filename, file.filename],
      [AppLocalizations.of(context)!.path, file.entity.path],
      [
        AppLocalizations.of(context)!.modify,
        MixUtils.formatFileTime(file.modified)
      ],
      [AppLocalizations.of(context)!.authorization, file.modeString]
    ];

    if (widget.additionalList != null) {
      info.addAll(widget.additionalList!);
    }

    if (showSize) {
      if (_mutex) {
        didChangeDependencies();
        _mutex = false;
      }
      info.addAll([
        [
          AppLocalizations.of(context)!.fileSize,
          MixUtils.humanStorageSize(_totalSize.toDouble())
        ],
        [AppLocalizations.of(context)!.fileCount, '$_fileCount'],
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
              Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.copied,
              );
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

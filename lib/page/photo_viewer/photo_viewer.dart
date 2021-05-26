import 'dart:io';
import 'dart:ui' as ui;

import 'package:aqua/third_party/photo_view/photo_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/fade_in.dart';
import 'package:aqua/common/widget/file_info_card.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/modal/show_modal.dart';
import 'package:aqua/page/file_manager/file_action.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/common/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<String> imageRes;
  final int index;

  const PhotoViewerPage({Key? key, required this.imageRes, this.index = 0})
      : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late int _currentIndex;
  late PreloadPageController _controller;
  late ThemeModel _themeModel;
  final _barFader = FadeInController(autoStart: true);
  final _topFader = FadeInController(autoStart: true);
  late bool _viewFaded = false;
  late bool _navButtonLocker;
  late int _navCurrentIndex;

  List<String> get imagesRes => widget.imageRes;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _controller =
        PreloadPageController(initialPage: _currentIndex, keepPage: true);
    _navCurrentIndex = 0;
    _viewFaded = false;
    _navButtonLocker = false;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _showMoreOptions(
      BuildContext context, SelfFileEntity img) async {
    ui.Image imgRes =
        await decodeImageFromList(await File(img.entity.path).readAsBytes());
    return showCupertinoModal(
      filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, changeState) {
            return SplitSelectionModal(
              topFlex: 1,
              bottomFlex: 1,
              topPanel: FileInfoCard(
                file: img,
                additionalList: [
                  [
                    '类型',
                    pathLib.extension(img.entity.path).replaceFirst('.', '')
                  ],
                  [
                    '宽度',
                    imgRes.width,
                  ],
                  [
                    '高度',
                    imgRes.height,
                  ]
                ],
              ),
              rightChildren: <Widget>[
                ActionButton(
                  content: '分享',
                  onTap: () async {
                    await ShareExtend.share(img.entity.path, 'image');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteModal(
      BuildContext context, SelfFileEntity img) async {
    return showTipTextModal(
      context,
      tip: '确定删除此照片?',
      onOk: () async {
        await img.entity.delete();
        setState(() {
          imagesRes.remove(img.entity.path);
        });
        Fluttertoast.showToast(
          msg: '已删除',
        );
      },
    );
  }

  PhotoViewScaleState customScaleStateCycle(PhotoViewScaleState actual) {
    switch (actual) {
      case PhotoViewScaleState.initial:
        return PhotoViewScaleState.originalSize;
      default:
        return PhotoViewScaleState.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;
    return Scaffold(
      backgroundColor: themeData?.scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            child: Container(
              alignment: Alignment.center,
              child: PreloadPageView.builder(
                preloadPagesCount: 3,
                controller: _controller,
                itemCount: imagesRes.length,
                onPageChanged: (index) async {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  File file = File(imagesRes[index]);
                  return PhotoView(
                    backgroundDecoration: BoxDecoration(
                      color: themeData?.scaffoldBackgroundColor,
                    ),
                    imageProvider: FileImage(file),
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.contained * 3,
                    initialScale: PhotoViewComputedScale.contained * 1,
                    scaleStateCycle: customScaleStateCycle,
                    enableRotation: true,
                    onTapUp: (context, details, value) {
                      if (_viewFaded) {
                        _topFader.fadeIn();
                        _barFader.fadeIn();
                      } else {
                        _topFader.fadeOut();
                        _barFader.fadeOut();
                      }
                      _viewFaded = !_viewFaded;
                    },
                  );
                  // return FutureBuilder(
                  //   future: FlutterGlide.getLocalThumbnail(
                  //     path: imagesRes[index],
                  //     quality: 100,
                  //     width: MediaQuery.of(context).size.width.toInt(),
                  //     height: MediaQuery.of(context).size.height.toInt(),
                  //   ),
                  //   builder: (BuildContext context,
                  //       AsyncSnapshot<dynamic> snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.done) {
                  //       if (snapshot.hasError || snapshot.data == null) {
                  //         return Container(
                  //           width: 40,
                  //           height: 40,
                  //           child: Center(
                  //             child: Icon(OMIcons.errorOutline),
                  //           ),
                  //         );
                  //       } else {
                  //         return PhotoView(
                  //           backgroundDecoration: BoxDecoration(
                  //             color: themeData?.scaffoldBackgroundColor,
                  //           ),
                  //           imageProvider: MemoryImage(snapshot.data),
                  //           minScale: PhotoViewComputedScale.contained * 0.8,
                  //           maxScale: PhotoViewComputedScale.contained * 3,
                  //           initialScale: PhotoViewComputedScale.contained * 1,
                  //           scaleStateCycle: customScaleStateCycle,
                  //           enableRotation: true,
                  //           onTapUp: (context, details, value) {
                  //             if (_viewFaded) {
                  //               _topFader.fadeIn();
                  //               _barFader.fadeIn();
                  //             } else {
                  //               _topFader.fadeOut();
                  //               _barFader.fadeOut();
                  //             }
                  //             _viewFaded = !_viewFaded;
                  //           },
                  //         );
                  //       }
                  //     } else {
                  //       return Container();
                  //     }
                  //   },
                  // );
                },
                physics: const BouncingScrollPhysics(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            child: FadeIn(
              duration: Duration(milliseconds: 100),
              controller: _topFader,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 52,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 15),
                      child: NoResizeText(
                        "${_currentIndex + 1}/${imagesRes.length}",
                        style: TextStyle(
                            fontSize: 16, color: themeData?.itemFontColor),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: themeData?.topNavIconColor,
                      ),
                      onPressed: () {
                        MixUtils.safePop(context);
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: FadeIn(
              controller: _barFader,
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: CupertinoTabBar(
                  onTap: (index) async {
                    setState(() {
                      _navCurrentIndex = index;
                    });
                    File file = File(imagesRes[_currentIndex]);

                    FileStat stat = file.statSync();

                    SelfFileEntity image = SelfFileEntity(
                      changed: stat.changed,
                      modified: stat.modified,
                      accessed: stat.accessed,
                      path: file.path,
                      type: stat.type,
                      mode: stat.mode,
                      modeString: stat.modeString(),
                      size: stat.size,
                      entity: file,
                      filename: pathLib.basename(file.path),
                      ext: pathLib.extension(file.path),
                      humanSize:
                          MixUtils.humanStorageSize(stat.size.toDouble()),
                      apkIcon: null,
                      isDir: stat.type == FileSystemEntityType.directory,
                      isFile: stat.type == FileSystemEntityType.file,
                      isLink: stat.type == FileSystemEntityType.link,
                      pureName: pathLib.basenameWithoutExtension(file.path),
                    );

                    switch (index) {
                      case 0:
                        if (!_navButtonLocker) {
                          _navButtonLocker = true;
                          await _showDeleteModal(context, image);
                          _navButtonLocker = false;
                        }
                        break;
                      // case 1:
                      //   showText('下一个大版本中更新');
                      //   break;
                      case 1:
                        if (!_navButtonLocker) {
                          _navButtonLocker = true;
                          await _showMoreOptions(context, image);
                          _navButtonLocker = false;
                        }
                        break;
                    }
                  },
                  currentIndex: _navCurrentIndex,
                  backgroundColor: themeData.photoNavColor,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      label: AppLocalizations.of(context)!.delete,
                      icon: FaIcon(FontAwesomeIcons.solidTrashAlt),
                    ),
                    // BottomNavigationBarItem(
                    //   label: AppLocalizations.of(context)!.edit,
                    //   icon: Icon(OMIcons.create),
                    // ),
                    BottomNavigationBarItem(
                      label: AppLocalizations.of(context)!.moreOptions,
                      icon: Icon(Icons.hdr_weak),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

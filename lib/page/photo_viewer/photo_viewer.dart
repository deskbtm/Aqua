import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:aqua/common/widget/action_button.dart';
import 'package:aqua/common/widget/fade_in.dart';
import 'package:aqua/common/widget/file_info_card.dart';
import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:aqua/common/widget/show_modal.dart';
import 'package:aqua/external/bot_toast/src/toast.dart';
import 'package:aqua/page/file_manager/file_action.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/page/file_manager/file_utils.dart';
import 'package:aqua/utils/mix_utils.dart';
import 'package:aqua/utils/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<String> imageRes;
  final int index;

  const PhotoViewerPage({Key key, this.imageRes, this.index = 0})
      : super(key: key);

  @override
  _PhotoViewerPageState createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  int _currentIndex;
  PreloadPageController _controller;
  ThemeModel _themeModel;
  final _barFader = FadeInController(autoStart: true);
  final _topFader = FadeInController(autoStart: true);
  bool _viewFaded;
  bool _navButtonLocker;
  int _navCurrentIndex;

  List<String> get imagesRes => widget.imageRes;

  void showText(String content) {
    BotToast.showText(text: content);
  }

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
        showText('已删除');
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
                    File img = File(imagesRes[_currentIndex]);
                    SelfFileEntity image = SelfFileEntity(
                      modified: img.statSync().modified,
                      entity: img,
                      filename: pathLib.basename(img.path),
                      ext: img.path,
                      isDir:
                          img.statSync().type == FileSystemEntityType.directory,
                      modeString: img.statSync().modeString(),
                      type: null,
                    );

                    switch (index) {
                      case 0:
                        if (!_navButtonLocker) {
                          _navButtonLocker = true;
                          await _showDeleteModal(context, image);
                          _navButtonLocker = false;
                        }
                        break;
                      case 1:
                        showText('下一个大版本中更新');
                        break;
                      case 2:
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
                      label: '删除',
                      icon: Icon(OMIcons.delete),
                    ),
                    BottomNavigationBarItem(
                      label: '编辑',
                      icon: Icon(OMIcons.create),
                    ),
                    BottomNavigationBarItem(
                      label: '更多',
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

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more/common/widget/action_button.dart';
import 'package:lan_file_more/common/widget/fade_in.dart';
import 'package:lan_file_more/common/widget/file_info_card.dart';
import 'package:lan_file_more/common/widget/function_widget.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/common/widget/show_modal.dart';
import 'package:lan_file_more/external/bot_toast/src/toast.dart';
import 'package:lan_file_more/page/file_manager/file_action.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/mix_utils.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as pathLib;
import 'package:share_extend/share_extend.dart';
import 'package:preload_page_view/preload_page_view.dart';

class PhotoViewer extends StatefulWidget {
  final List<String> imageRes;
  final int index;

  const PhotoViewer({Key key, this.imageRes, this.index = 0}) : super(key: key);

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  int _currentIndex;
  PreloadPageController _controller;
  ThemeModel _themeModel;
  final _barFader = FadeInController(autoStart: true);
  final _topFader = FadeInController(autoStart: true);
  bool _viewFaded = false;
  int _navCurrentIndex;

  List<String> get imagesRes => widget.imageRes;

  void showText(String content) {
    BotToast.showText(
        text: content, contentColor: _themeModel.themeData?.toastColor);
  }

  @override
  void initState() {
    // imagesRes = widget.imageRes;
    _controller = PreloadPageController(initialPage: widget.index);
    _currentIndex = widget.index;
    _navCurrentIndex = 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _themeModel = Provider.of<ThemeModel>(context);
    super.didChangeDependencies();
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

    showCupertinoModal(
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
    showTipTextModal(
      context,
      _themeModel,
      tip: '确定删除此照片?',
      onOk: () async {
        await img.entity.delete();
        setState(() {
          imagesRes.remove(img.entity.path);
        });
        showText('已删除');
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel.themeData;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            child: GestureDetector(
              onTap: () {
                if (_viewFaded) {
                  _topFader.fadeIn();
                  _barFader.fadeIn();
                } else {
                  _topFader.fadeOut();
                  _barFader.fadeOut();
                }
                _viewFaded = !_viewFaded;
              },
              child: Container(
                alignment: Alignment.center,
                child: PhotoViewGallery.builder(
                  preloadCount: 3,
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    File img = File(imagesRes[index]);
                    return PhotoViewGalleryPageOptions(
                      imageProvider: FileImage(img),
                    );
                  },
                  itemCount: imagesRes.length,
                  loadingBuilder: (context, event) {
                    return loadingIndicator(context, _themeModel);
                  },
                  backgroundDecoration: BoxDecoration(
                    color: themeData?.scaffoldBackgroundColor,
                  ),
                  pageController: _controller,
                  enableRotation: true,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
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
                        _showDeleteModal(context, image);
                        break;
                      case 1:
                        showText('下一个大版本中更新');
                        break;
                      case 2:
                        _showMoreOptions(context, image);
                        break;
                    }
                  },
                  currentIndex: _navCurrentIndex,
                  backgroundColor: themeData.photoNavColor,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      title: NoResizeText('删除'),
                      icon: Icon(OMIcons.delete),
                    ),
                    BottomNavigationBarItem(
                      title: NoResizeText('编辑'),
                      icon: Icon(OMIcons.create),
                    ),
                    BottomNavigationBarItem(
                      title: NoResizeText('更多'),
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

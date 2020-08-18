import 'package:flutter/material.dart';
import 'package:lan_express/common/widget/function_widget.dart';
import 'package:lan_express/common/widget/no_resize_text.dart';
import 'package:lan_express/provider/theme.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class PhotoViewPage extends StatefulWidget {
  final List images;
  final int index;

  const PhotoViewPage({Key key, this.images, this.index = 0}) : super(key: key);

  @override
  _PhotoViewPageState createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
  int currentIndex;
  PageController controller;

  ThemeProvider _themeProvider;

  String _getImgUrl(index) {
    return widget.images[index] is String
        ? widget.images[index]
        : widget.images[index]['url'];
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
    currentIndex = widget.index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(PhotoViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _themeProvider = Provider.of<ThemeProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(
                      _getImgUrl(index),
                    ),
                  );
                },
                itemCount: widget.images.length,
                loadingBuilder: (context, event) {
                  // return loadingIndicator(context, );
                },
                backgroundDecoration: BoxDecoration(color: Colors.white),
                pageController: controller,
                enableRotation: true,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Positioned(
            //图片index显示
            top: MediaQuery.of(context).padding.top + 15,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: NoResizeText("${currentIndex + 1}/${widget.images.length}",
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          Positioned(
            //右上角关闭按钮
            right: 10,
            top: MediaQuery.of(context).padding.top,
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 30,
                color: Colors.blue[200],
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ResizebleWidget extends StatefulWidget {
  final double initSize;
  final Widget child;
  final bool editorMode;

  const ResizebleWidget({
    Key key,
    this.initSize = 60,
    this.child,
    this.editorMode = false,
  }) : super(key: key);

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

class _ResizebleWidgetState extends State<ResizebleWidget> {
  double top = 0;
  double left = 0;
  double height;
  double width;

  @override
  void initState() {
    super.initState();
    height = widget.initSize;
    width = widget.initSize;
  }

  @override
  Widget build(BuildContext context) {
    return widget.editorMode
        ? Stack(
            children: <Widget>[
              Positioned(
                top: top,
                left: left,
                child: Container(
                  height: height,
                  width: width,
                  child: widget.child,
                ),
              ),
              Positioned(
                top: top - 15,
                left: left - 15,
                child: DraggableFixedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.rotate_90_degrees_ccw),
                ),
              ),
              Positioned(
                top: top - 15,
                left: left + width - 15,
                child: DraggableFixedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.cancel),
                  onDrag: (dx, dy) {},
                ),
              ),
              Positioned(
                top: top + height - 15,
                left: left + width - 15,
                child: DraggableFixedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.zoom_out_map),
                  onDrag: (dx, dy) {
                    var mid = (dx + dy) / 2;

                    var newHeight = height + 2 * mid;
                    var newWidth = width + 2 * mid;

                    setState(() {
                      height = newHeight > 0 ? newHeight : 0;
                      width = newWidth > 0 ? newWidth : 0;
                      top = top - mid;
                      left = left - mid;
                    });
                  },
                ),
              ),
              Positioned(
                top: top,
                left: left,
                child: DraggableFixedBox(
                  child: Container(
                    height: height,
                    width: width,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  onDrag: (dx, dy) {
                    setState(() {
                      top = top + dy;
                      left = left + dx;
                    });
                  },
                ),
              ),
            ],
          )
        : widget.child;
  }
}

class DraggableFixedBox extends StatefulWidget {
  final double width;
  final double height;
  final Function onDrag;
  final Widget child;
  final Function onTap;

  const DraggableFixedBox(
      {Key key, this.onDrag, this.width, this.height, this.child, this.onTap})
      : super(key: key);

  @override
  _DraggableFixedBoxState createState() => _DraggableFixedBoxState();
}

class _DraggableFixedBoxState extends State<DraggableFixedBox> {
  double initX;
  double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: widget.child,
      ),
    );
  }
}

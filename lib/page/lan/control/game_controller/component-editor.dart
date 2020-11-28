import 'package:flutter/material.dart';

class ComponentEditor extends StatefulWidget {
  final double initSize;
  final Widget child;
  final bool editorMode;
  final double minSize;
  final double maxSize;
  final double padding;
  final Function(double) onResize;
  final Function(double dx, double dy) onMove;

  const ComponentEditor({
    Key key,
    this.initSize = 60,
    this.child,
    this.editorMode = false,
    this.minSize,
    this.maxSize,
    this.onResize,
    this.onMove,
    this.padding = 10,
  }) : super(key: key);

  @override
  _ComponentEditorState createState() => _ComponentEditorState();
}

class _ComponentEditorState extends State<ComponentEditor> {
  double top = 0;
  double left = 0;
  double size = 0;
  // double height;
  // double width;

  @override
  void initState() {
    super.initState();
    size = widget.minSize ?? widget.initSize;
    // width = widget.minSize ?? widget.initSize;
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
                  height: size,
                  width: size,
                  padding: EdgeInsets.all(widget.padding),
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
                left: left + size - 15,
                child: DraggableFixedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.cancel),
                  onDrag: (dx, dy) {},
                ),
              ),
              Positioned(
                top: top + size - 15,
                left: left + size - 15,
                child: DraggableFixedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.zoom_out_map),
                  onDrag: (dx, dy) {
                    double mid = (dx + dy) / 2;
                    double newSize = size + 2 * mid;
                    if (mounted) {
                      setState(
                        () {
                          if (widget.minSize != null &&
                              newSize < widget.minSize) {
                            size = widget.minSize;
                          } else {
                            size = newSize > 0 ? newSize : 0;
                            top = top - mid;
                            left = left - mid;
                            if (widget.onMove != null) {
                              widget.onMove(dx, dy);
                            }
                          }
                          if (widget.onResize != null) {
                            widget.onResize(size / widget.minSize);
                          }
                        },
                      );
                    }
                  },
                ),
              ),
              Positioned(
                top: top,
                left: left,
                child: DraggableFixedBox(
                  child: Container(
                    height: size,
                    width: size,
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
  final Function(double, double) onDrag;
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

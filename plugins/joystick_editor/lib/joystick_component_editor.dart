import 'dart:developer';
import 'dart:math' as _math;
import 'package:flutter/material.dart';

class GameTransform extends StatelessWidget {
  final int rotateCount;
  final double scaleRate;
  final Widget child;

  const GameTransform({Key key, this.rotateCount, this.scaleRate, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -_math.pi / 2 * rotateCount,
      child: Transform.scale(
        scale: scaleRate,
        child: child,
      ),
    );
  }
}

class GameComponentEditor extends StatefulWidget {
  final Widget child;
  final double editorSize;
  final bool isEdit;
  final Function(double dx, double dy) onMove;
  final Function() onPressSetting;
  final double top;
  final double left;
  final int rotateCount;
  final double scaleRate;
  final String type;

  const GameComponentEditor({
    Key key,
    this.child,
    this.editorSize = 200,
    this.onMove,
    this.isEdit = true,
    this.top,
    this.left,
    this.scaleRate,
    this.rotateCount,
    this.onPressSetting,
    this.type,
  }) : super(key: key);

  @override
  _GameComponentEditorState createState() => _GameComponentEditorState();
}

class _GameComponentEditorState extends State<GameComponentEditor> {
  double _top = 0;
  double _left = 0;
  double _editorSize = 0;
  int _rotateCount = 0;
  double _scaleRate = 1;

  @override
  void initState() {
    super.initState();
    _editorSize = widget.editorSize;
    _rotateCount = widget.rotateCount;
    _scaleRate = widget.scaleRate;
    _top = widget.top;
    _left = widget.left;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        if (!widget.isEdit) ...[
          Positioned(
            top: _top,
            left: _left,
            child: Container(
              height: _editorSize,
              width: _editorSize,
              // padding: EdgeInsets.all(10),
              child: GameTransform(
                rotateCount: _rotateCount,
                scaleRate: _scaleRate,
                child: widget.child,
              ),
            ),
          ),
        ],
        if (widget.isEdit) ...[
          Positioned(
            top: _top,
            left: _left,
            child: Container(
              height: _editorSize,
              width: _editorSize,
              // padding: EdgeInsets.all(10),
              child: GameTransform(
                rotateCount: _rotateCount,
                scaleRate: _scaleRate,
                child: widget.child,
              ),
            ),
          ),
          Positioned(
            top: _top - 15,
            left: _left - 15,
            child: DraggableFixedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.rotate_90_degrees_ccw),
              onTap: () {
                if (mounted) {
                  setState(() {
                    _rotateCount++;
                  });
                }
              },
            ),
          ),
          Positioned(
            top: _top - 15,
            left: _left + _editorSize - 15,
            child: DraggableFixedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.cancel),
              onDrag: (dx, dy) {},
            ),
          ),
          Positioned(
            top: _top + _editorSize - 15,
            left: _left - 15,
            child: Transform.rotate(
              angle: -_math.pi / 2 * _rotateCount,
              child: DraggableFixedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.settings),
                onTap: () {
                  if (widget.onPressSetting != null) {
                    widget.onPressSetting();
                  }
                },
              ),
            ),
          ),
          Positioned(
            top: _top + _editorSize - 15,
            left: _left + _editorSize - 15,
            child: DraggableFixedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.zoom_out_map),
              onDrag: (dx, dy) {
                double mid = (dx + dy) / 2;
                double newSize = _editorSize + 2 * mid;
                if (mounted) {
                  setState(
                    () {
                      if (widget.editorSize != null &&
                          newSize < widget.editorSize) {
                        _editorSize = widget.editorSize;
                      } else {
                        _editorSize = newSize > 0 ? newSize : 0;
                        _top = _top - mid;
                        _left = _left - mid;
                        if (widget.onMove != null) {
                          widget.onMove(dx, dy);
                        }
                      }
                      _scaleRate = _editorSize / widget.editorSize;
                    },
                  );
                }
              },
            ),
          ),
          Positioned(
            top: _top,
            left: _left,
            child: DraggableFixedBox(
              child: Container(
                height: _editorSize,
                width: _editorSize,
                color: Colors.blue.withOpacity(0.2),
              ),
              onDrag: (dx, dy) {
                setState(() {
                  _top = _top + dy;
                  _left = _left + dx;
                });
              },
            ),
          ),
        ]
      ],
    );
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
  double _initX;
  double _initY;

  _handleDrag(details) {
    setState(() {
      _initX = details.globalPosition.dx;
      _initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - _initX;
    var dy = details.globalPosition.dy - _initY;
    _initX = details.globalPosition.dx;
    _initY = details.globalPosition.dy;
    if (widget.onDrag != null) {
      widget.onDrag(dx, dy);
    }
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

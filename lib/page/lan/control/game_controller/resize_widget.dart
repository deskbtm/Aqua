import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComponentContainer extends StatefulWidget {
  final Widget child;
  final bool editorMode;
  final double x;
  final double y;
  const ComponentContainer({
    Key key,
    this.child,
    this.editorMode = true,
    this.x,
    this.y,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ComponentContainerState();
  }
}

class _ComponentContainerState extends State<ComponentContainer> {
  double x = 0;
  double y = 0;
  Widget dragIcon = Icon(
    Icons.zoom_out_map,
    size: 20,
  );

  Widget cancelIcon = Icon(
    Icons.cancel,
    size: 20,
  );

  @override
  Widget build(BuildContext context) {
    Widget childWidget = widget.editorMode
        ? GestureDetector(
            child: Transform.scale(
              scale: 1,
              child: Container(
                child: Stack(
                  overflow: Overflow.visible,
                  children: [
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Icon(
                        Icons.cancel,
                        size: 20,
                      ),
                    ),
                    Positioned(
                        bottom: -10,
                        right: -10,
                        child: Listener(
                          child: Draggable(
                            axis: Axis.vertical,
                            child: dragIcon,
                            feedback: dragIcon,
                            childWhenDragging: dragIcon,
                            onDragStarted: () {
                              log('=================');
                            },
                          ),
                        )

                        // GestureDetector(
                        //   onTap: () {},
                        //   onVerticalDragStart: (details) {
                        //     print(details.globalPosition.distance);
                        //   },
                        //   child:
                        // ),
                        ),
                    DottedBorder(
                      color: Colors.black26,
                      strokeWidth: 1,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: widget.child,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : widget.child;

    return Positioned(
      top: y,
      left: x,
      child: LongPressDraggable(
        onDraggableCanceled: (v, o) {
          if (!mounted) {
            return;
          }
          setState(() {
            x = o.dx;
            y = o.dy;
          });
        },
        feedback: childWidget,
        childWhenDragging: childWidget,
        child: childWidget,
      ),
    );
  }
}

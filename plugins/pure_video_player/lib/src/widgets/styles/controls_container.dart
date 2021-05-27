import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/src/controller.dart';

class ControlsContainer extends StatelessWidget {
  final Widget child;
  const ControlsContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Positioned.fill(
      child: Obx(
        () => GestureDetector(
          onTap: () => _.controls = !_.showControls,
          child: AnimatedOpacity(
            opacity: _.showControls ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              color: _.showControls ? Colors.black38 : Colors.transparent,
              child: AbsorbPointer(
                absorbing: !_.showControls,
                child: this.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

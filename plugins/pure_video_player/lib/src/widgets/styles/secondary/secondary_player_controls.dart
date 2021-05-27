import 'package:flutter/material.dart';
import 'package:pure_video_player/src/controller.dart';
import 'package:pure_video_player/src/helpers/responsive.dart';

import 'package:pure_video_player/src/widgets/styles/controls_container.dart';
import 'package:pure_video_player/src/widgets/styles/secondary/secondary_bottom_controls.dart';

class SecondaryVideoPlayerControls extends StatelessWidget {
  final Responsive responsive;
  const SecondaryVideoPlayerControls({Key? key, required this.responsive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return ControlsContainer(
      child: Stack(
        children: [
          // RENDER A CUSTOM HEADER
          if (_.header != null)
            Positioned(
              child: _.header!,
              left: 0,
              right: 0,
              top: 0,
            ),
          SecondaryBottomControls(
            responsive: responsive,
          ),
        ],
      ),
    );
  }
}

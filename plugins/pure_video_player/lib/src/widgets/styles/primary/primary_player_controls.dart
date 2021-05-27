import 'package:flutter/material.dart';
import 'package:pure_video_player/pure_video_player.dart';

import 'package:pure_video_player/src/helpers/responsive.dart';
import 'package:pure_video_player/src/widgets/play_pause_button.dart';
import 'package:pure_video_player/src/widgets/styles/controls_container.dart';
import 'package:pure_video_player/src/widgets/styles/primary/bottom_controls.dart';
import '../../player_button.dart';

class PrimaryVideoPlayerControls extends StatelessWidget {
  final Responsive responsive;
  const PrimaryVideoPlayerControls({Key? key, required this.responsive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);

    return ControlsContainer(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // RENDER A CUSTOM HEADER
          if (_.header != null)
            Positioned(
              child: _.header!,
              left: 0,
              right: 0,
              top: 0,
            ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_.enabledButtons.rewindAndfastForward) ...[
                PlayerButton(
                  onPressed: _.rewind,
                  size: responsive.ip(_.fullscreen ? 8 : 12),
                  iconColor: Colors.white,
                  backgrounColor: Colors.transparent,
                  icon: Icon(
                    Icons.fast_rewind_outlined,
                    color: Colors.white,
                  ),
                  customIcon: _.customIcons.rewind,
                ),
                SizedBox(width: 10),
              ],
              if (_.enabledButtons.playPauseAndRepeat)
                PlayPauseButton(
                  size: responsive.ip(_.fullscreen ? 10 : 15),
                ),
              if (_.enabledButtons.rewindAndfastForward) ...[
                SizedBox(width: 10),
                PlayerButton(
                  onPressed: _.fastForward,
                  iconColor: Colors.white,
                  backgrounColor: Colors.transparent,
                  size: responsive.ip(_.fullscreen ? 8 : 12),
                  icon: Icon(
                    Icons.fast_forward_outlined,
                    color: Colors.white,
                  ),
                  customIcon: _.customIcons.fastForward,
                ),
              ]
            ],
          ),

          PrimaryBottomControls(
            responsive: responsive,
          ),
        ],
      ),
    );
  }
}

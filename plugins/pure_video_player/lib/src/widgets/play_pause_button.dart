import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';

import 'player_button.dart';

class PlayPauseButton extends StatelessWidget {
  final double size;
  const PlayPauseButton({Key? key, this.size = 40}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Obx(
      () {
        Icon icon = Icon(
          Icons.repeat_one_outlined,
          color: Colors.white,
          size: 45,
        );
        Widget customIcon = _.customIcons.repeat!;
        if (_.playerStatus.playing) {
          icon = Icon(
            Icons.pause_outlined,
            color: Colors.white,
            size: 45,
          );
          customIcon = _.customIcons.pause!;
        } else if (_.playerStatus.paused) {
          icon = Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 45,
          );
          customIcon = _.customIcons.play!;
        }
        return PlayerButton(
          backgrounColor: Colors.transparent,
          iconColor: Colors.white,
          onPressed: () {
            if (_.playerStatus.playing) {
              _.pause();
            } else if (_.playerStatus.paused) {
              _.play();
            } else {
              _.play(repeat: true);
            }
          },
          size: size,
          icon: icon,
          customIcon: customIcon,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';

import 'player_button.dart';

class FullscreenButton extends StatelessWidget {
  final double size;
  const FullscreenButton({Key? key, this.size = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Obx(
      () {
        Icon icon = Icon(
          Icons.fullscreen_exit_outlined,
          color: Colors.white,
        );
        Widget customIcon = _.customIcons.fullscreen!;

        if (!_.fullscreen) {
          icon = Icon(
            Icons.fullscreen,
            color: Colors.white,
          );
          customIcon = _.customIcons.fullscreen!;
        }
        return PlayerButton(
          size: size,
          circle: false,
          backgrounColor: Colors.transparent,
          iconColor: Colors.white,
          icon: icon,
          customIcon: customIcon,
          onPressed: () {
            if (_.fullscreen) {
              // exit to fullscreen
              Navigator.pop(context);
            } else {
              _.goToFullscreen(context);
            }
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';
import 'package:pure_video_player/src/helpers/responsive.dart';

import 'player_button.dart';

class MuteSoundButton extends StatelessWidget {
  final Responsive responsive;
  const MuteSoundButton({Key? key, required this.responsive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Obx(() {
      Icon icon = Icon(
        Icons.volume_off_outlined,
        color: Colors.white,
      );
      Widget customIcon = _.customIcons.mute!;

      if (!_.mute) {
        icon = Icon(
          Icons.volume_up_outlined,
          color: Colors.white,
        );
        customIcon = _.customIcons.sound!;
      }

      return PlayerButton(
        size: responsive.ip(_.fullscreen ? 5 : 7),
        circle: false,
        backgrounColor: Colors.transparent,
        iconColor: Colors.white,
        icon: icon,
        customIcon: customIcon,
        onPressed: () {
          _.setMute(!_.mute);
        },
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';
import 'package:pure_video_player/src/helpers/responsive.dart';

import 'player_button.dart';

class PipButton extends StatelessWidget {
  final Responsive responsive;
  const PipButton({Key? key, required this.responsive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Obx(() {
      if (!_.pipAvailable || !_.showPipButton) return Container();
      return PlayerButton(
        size: responsive.ip(_.fullscreen ? 5 : 7),
        circle: false,
        backgrounColor: Colors.transparent,
        iconColor: Colors.white,
        icon: Icon(
          Icons.picture_in_picture_outlined,
          color: Colors.white,
        ),
        customIcon: _.customIcons.pip,
        onPressed: () => _.enterPip(context),
      );
    });
  }
}

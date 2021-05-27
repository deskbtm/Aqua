import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';
import 'package:pure_video_player/src/helpers/responsive.dart';

class ClosedCaptionView extends StatelessWidget {
  final Responsive responsive;
  const ClosedCaptionView({Key? key, required this.responsive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _ = PurePlayerController.of(context);
    return Obx(() {
      if (!_.closedCaptionEnabled) return Container();

      return StreamBuilder<Duration?>(
        initialData: Duration.zero,
        stream: _.onPositionChanged,
        builder: (__, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          final strSubtitle = _.videoPlayerController?.value.caption.text;
          if (strSubtitle == null) return Container();

          return Positioned(
            left: 60,
            right: 60,
            bottom: 0,
            child: ClosedCaption(
              text: strSubtitle,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: responsive.ip(2),
              ),
            ),
          );
        },
      );
    });
  }
}

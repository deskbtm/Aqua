import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart';
import 'package:pure_video_player/src/controller.dart';
import 'package:pure_video_player/src/helpers/responsive.dart';
import 'package:pure_video_player/src/widgets/closed_caption_view.dart';
import 'package:pure_video_player/src/widgets/styles/primary/primary_player_controls.dart';
import 'package:pure_video_player/src/widgets/styles/secondary/secondary_player_controls.dart';
import 'package:video_player/video_player.dart';

class PureVideoPlayer extends StatefulWidget {
  final PurePlayerController controller;

  final Widget Function(
    BuildContext context,
    PurePlayerController controller,
    Responsive responsive,
  )? header;

  final Widget Function(
    BuildContext context,
    PurePlayerController controller,
    Responsive responsive,
  )? bottomRight;

  final CustomIcons Function(
    Responsive responsive,
  )? customIcons;

  PureVideoPlayer({
    Key? key,
    required this.controller,
    this.header,
    this.bottomRight,
    this.customIcons,
  })  : assert(controller != null),
        super(key: key);

  @override
  _PureVideoPlayerState createState() => _PureVideoPlayerState();
}

class _PureVideoPlayerState extends State<PureVideoPlayer> {
  Widget _getView(PurePlayerController _) {
    print("✅ _.dataStatus ${_.dataStatus.status}");
    if (_.dataStatus.none) return Container();
    if (_.dataStatus.loading) {
      return Center(
        child: _.placeholder,
      );
    }
    if (_.dataStatus.error) {
      return Center(
        child: Text(
          _.errorText,
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final responsive = Responsive(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        if (widget.customIcons != null) {
          _.customIcons = this.widget.customIcons!(responsive);
        }

        if (widget.header != null) {
          _.header = this.widget.header!(context, _, responsive);
        }

        if (widget.bottomRight != null) {
          _.bottomRight = this.widget.bottomRight!(context, _, responsive);
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _.videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_.videoPlayerController!),
            ),
            ClosedCaptionView(responsive: responsive),
            if (_.controlsEnabled && _.controlsStyle == ControlsStyle.primary)
              PrimaryVideoPlayerControls(
                responsive: responsive,
              ),
            if (_.controlsEnabled && _.controlsStyle == ControlsStyle.secondary)
              SecondaryVideoPlayerControls(
                responsive: responsive,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PurePlayerProvider(
      child: Container(
        color: Colors.black,
        width: 0.0,
        height: 0.0,
        child: Obx(
          () => _getView(widget.controller),
        ),
      ),
      controller: widget.controller,
    );
  }
}

class PurePlayerProvider extends InheritedWidget {
  final PurePlayerController controller;

  PurePlayerProvider({
    Key? key,
    required Widget child,
    required this.controller,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

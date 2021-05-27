import 'package:flutter/material.dart';
import 'package:pure_video_player/pure_video_player.dart';

class PurePlayerFullscreenPage extends StatelessWidget {
  final PurePlayerController controller;
  const PurePlayerFullscreenPage({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: PureVideoPlayer(controller: this.controller),
      ),
    );
  }
}

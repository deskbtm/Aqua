// import 'package:fijkplayer/fijkplayer.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:aqua/common/theme.dart';
import 'package:provider/provider.dart';
import 'package:pure_video_player/pure_video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'meida_info.dart';

class VideoPage extends StatefulWidget {
  final MediaInfo info;

  const VideoPage({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoPageState();
  }
}

class _VideoPageState extends State<VideoPage> {
  late ThemeModel _themeModel;
  late StreamSubscription _playerEventSub;
  final _purePlayerController = PurePlayerController(
    controlsStyle: ControlsStyle.primary,
    pipEnabled: true,
    showPipButton: true,
  );

  MediaInfo get info => widget.info;

  void _init() {
    _purePlayerController.setDataSource(
      DataSource(
        type: DataSourceType.file,
        file: File(info.path),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _playerEventSub = _purePlayerController.onPlayerStatusChanged.listen(
      (PlayerStatus? status) {
        if (status == PlayerStatus.playing) {
          Wakelock.enable();
        } else {
          Wakelock.disable();
        }
      },
    );

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _init();
    });
    // player.setDataSource(info.path, showCover: true);
    // player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
    // player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    _playerEventSub.cancel();
    Wakelock.disable();
    _purePlayerController.dispose();
    // player?.release();
    // player = null;
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;
    return CupertinoPageScaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Material(
            child: PureVideoPlayer(
              controller: _purePlayerController,
            ),
            // FijkView(
            //   player: player,
            //   fit: FijkFit.fill,
            //   fsFit: FijkFit.fitHeight,
            //   panelBuilder: fijkPanel2Builder(
            //     snapShot: true,
            //   ),
            //   color: Colors.black,
            // ),
          ),
        ),
      ),
    );
  }
}

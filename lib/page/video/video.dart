import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

import 'meida_info.dart';

class VideoPage extends StatefulWidget {
  final MediaInfo info;

  const VideoPage({
    Key key,
    this.info,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoPageState();
  }
}

class _VideoPageState extends State<VideoPage> {
  ThemeModel _themeModel;
  FijkPlayer player = FijkPlayer();

  MediaInfo get info => widget.info;

  @override
  void initState() {
    super.initState();
    player.setDataSource(info.path, showCover: true);
    player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
    player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  void dispose() {
    super.dispose();
    player?.release();
    player = null;
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel.themeData;
    return CupertinoPageScaffold(
      backgroundColor: themeData?.scaffoldBackgroundColor,
      child: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Material(
            child: FijkView(
              player: player,
              fit: FijkFit.fill,
              fsFit: FijkFit.fitHeight,
              panelBuilder: fijkPanel2Builder(
                snapShot: true,
              ),
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

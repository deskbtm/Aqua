import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/state_manager.dart';
import 'package:pure_video_player/pure_video_player.dart'
    show PurePlayerProvider;
import 'package:pure_video_player/src/helpers/custom_icons.dart';
import 'package:pure_video_player/src/helpers/data_source.dart';
import 'package:pure_video_player/src/helpers/enabled_buttons.dart';

import 'package:pure_video_player/src/helpers/player_data_status.dart';
import 'package:pure_video_player/src/helpers/pure_player_status.dart';
import 'package:pure_video_player/src/helpers/screen_manager.dart';
import 'package:pure_video_player/src/native/pip_manager.dart';
import 'package:pure_video_player/src/widgets/fullscreen_page.dart';
import 'package:video_player/video_player.dart';

enum ControlsStyle { primary, secondary }

class PurePlayerController {
  /// the video_player controller
  late VideoPlayerController? _videoPlayerController;
  final _pipManager = PipManager();

  /// Screen Manager to define the overlays and device orientation when the player enters in fullscreen mode
  final ScreenManager screenManager;

  /// use this class to change the default icons with your custom icons
  CustomIcons customIcons;

  /// use this class to hide some buttons in the player
  EnabledButtons enabledButtons;

  /// the playerStatus to notify the player events like paused,playing or stopped
  /// [playerStatus] has a [status] observable
  final PurePlayerStatus playerStatus = PurePlayerStatus();

  /// the dataStatus to notify the load sources events
  /// [dataStatus] has a [status] observable
  final PurePlayerDataStatus dataStatus = PurePlayerDataStatus();
  final Color colorTheme;
  final bool controlsEnabled;
  final String errorText;
  late Widget? placeholder, header, bottomRight;
  final ControlsStyle controlsStyle;
  final bool pipEnabled, showPipButton;
  BuildContext? _pipContextToFullscreen;

  late String tag;

  // OBSERVABLES
  Rx<Duration> _position = Duration.zero.obs;
  Rx<Duration> _sliderPosition = Duration.zero.obs;
  Rx<Duration> _duration = Duration.zero.obs;
  Rx<Duration> _bufferedLoaded = Duration.zero.obs;
  RxBool _closedCaptionEnabled = false.obs;

  RxBool _mute = false.obs;
  RxBool _fullscreen = false.obs;
  RxBool _showControls = true.obs;
  RxBool _pipAvailable = false.obs;

  // NO OBSERVABLES
  bool _isSliderMoving = false;
  bool _looping = false;
  bool _autoplay = false;
  double _volumeBeforeMute = 0;
  double _playbackSpeed = 1.0;
  Timer? _timer;

  // GETS

  /// use this stream to listen the player data events like none, loading, loaded, error
  Stream<DataStatus?> get onDataStatusChanged => dataStatus.status.stream;

  /// use this stream to listen the player data events like stopped, playing, paused
  Stream<PlayerStatus?> get onPlayerStatusChanged => playerStatus.status.stream;

  /// current position of the player
  Duration get position => _position.value;

  /// use this stream to listen the changes in the video position
  Stream<Duration?> get onPositionChanged => _position.stream;

  /// duration of the video
  Duration get duration => _duration.value;

  /// use this stream to listen the changes in the video duration
  Stream<Duration?> get onDurationChanged => _duration.stream;

  /// [mute] is true if the player is muted
  bool get mute => _mute.value;
  Stream<bool?> get onMuteChanged => _mute.stream;

  /// [fullscreen] is true if the player is in fullscreen mode
  bool get fullscreen => _fullscreen.value;
  Stream<bool?> get onFullscreenChanged => _fullscreen.stream;

  /// [showControls] is true if the player controls are visible
  bool get showControls => _showControls.value;
  Stream<bool?> get onShowControlsChanged => _showControls.stream;

  /// [sliderPosition] the video slider position
  Duration get sliderPosition => _sliderPosition.value;
  Stream<Duration?> get onSliderPositionChanged => _sliderPosition.stream;

  /// [bufferedLoaded] buffered Loaded for network resources
  Duration get bufferedLoaded => _bufferedLoaded.value;
  Stream<Duration?> get onBufferedLoadedChanged => _bufferedLoaded.stream;

  /// [videoPlayerController] instace of VideoPlayerController
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  /// the playback speed default value is 1.0
  double get playbackSpeed => _playbackSpeed;

  /// [looping] is true if the player is looping
  bool get looping => _looping;

  /// [autoPlay] is true if the player has enabled the autoplay
  bool get autoplay => _autoplay;

  bool get closedCaptionEnabled => _closedCaptionEnabled.value;
  Stream<bool?> get onClosedCaptionEnabledChanged =>
      _closedCaptionEnabled.stream;

  /// [isInPipMode] is true if pip mode is enabled
  bool get isInPipMode => _pipManager.isInPipMode.value;
  Stream<bool?> get onPipModeChanged => _pipManager.isInPipMode.stream;

  /// returns the os version
  Future<double> get osVersion async {
    return _pipManager.osVersion;
  }

  /// returns true if the pip mode can used on the current device, the initial value will be false after check if pip is available
  bool get pipAvailable => _pipAvailable.value;

  /// creates an instance of [PurePlayerControlle]
  ///
  /// [screenManager] the device orientations and overlays
  /// [placeholder] widget to show when the player is loading a video
  /// [controlsEnabled] if the player must show the player controls
  /// [errorText] message to show when the load process failed
  PurePlayerController({
    this.screenManager = const ScreenManager(),
    this.colorTheme = const Color(0xFF007AFF),
    Widget? placeholder,
    this.controlsEnabled = true,
    this.errorText = 'Error',
    this.controlsStyle = ControlsStyle.primary,
    this.header,
    this.bottomRight,
    this.pipEnabled = false,
    this.showPipButton = false,
    this.customIcons = const CustomIcons(),
    this.enabledButtons = const EnabledButtons(),
  }) {
    this.tag = DateTime.now().microsecondsSinceEpoch.toString();
    this.placeholder = placeholder ??
        SpinKitWave(
          size: 30,
          color: this.colorTheme,
        );

    _pipAvailable.value = pipEnabled;
  }

  /// create a new video_player controller
  VideoPlayerController _createVideoController(DataSource dataSource) {
    VideoPlayerController tmp; // create a new video controller
    if (dataSource.type == DataSourceType.asset) {
      tmp = new VideoPlayerController.asset(
        dataSource.source!,
        closedCaptionFile: dataSource.closedCaptionFile,
        package: dataSource.package,
      );
    } else if (dataSource.type == DataSourceType.network) {
      tmp = new VideoPlayerController.network(
        dataSource.source!,
        formatHint: dataSource.formatHint,
        closedCaptionFile: dataSource.closedCaptionFile,
      );
    } else {
      tmp = new VideoPlayerController.file(
        dataSource.file!,
        closedCaptionFile: dataSource.closedCaptionFile,
      );
    }
    return tmp;
  }

  /// initialize the video_player controller and load the data source
  Future _initializePlayer({
    Duration? seekTo,
  }) async {
    await _videoPlayerController!.initialize();

    if (seekTo != null) {
      await this.seekTo(seekTo);
    }

    // if the playbackSpeed is not the default value
    if (_playbackSpeed != 1.0) {
      await setPlaybackSpeed(_playbackSpeed);
    }

    if (_looping) {
      await setLooping(_looping);
    }

    if (_autoplay) {
      // if the autoplay is enabled
      await this.play();
    }
  }

  void _listener() {
    final value = _videoPlayerController!.value;
    // set the current video position
    final position = value.position;
    _position.value = position;
    if (!_isSliderMoving) {
      _sliderPosition.value = position;
    }

    // set the video buffered loaded
    final buffered = value.buffered;
    if (buffered.isNotEmpty) {
      _bufferedLoaded.value = buffered.last.end;
    }

    // save the volume value
    final volume = value.volume;
    if (!mute && _volumeBeforeMute != volume) {
      _volumeBeforeMute = volume;
    }

    // check if the player has been finished
    if (_position.value.inSeconds >= duration.inSeconds &&
        !playerStatus.stopped) {
      playerStatus.status.value = PlayerStatus.stopped;
    }
  }

  /// set the video data source
  ///
  /// [autoPlay] if this is true the video automatically start
  Future<void> setDataSource(
    DataSource dataSource, {
    bool? autoplay,
    bool? looping,
    Duration? seekTo,
  }) async {
    try {
      _autoplay = autoplay ?? this._autoplay;
      _looping = looping ?? this._looping;
      dataStatus.status.value = DataStatus.loading;

      // if we are playing a video
      if (_videoPlayerController != null &&
          _videoPlayerController!.value.isPlaying) {
        await this.pause(notify: false);
      }

      // save the current video controller to be disposed in the next frame
      VideoPlayerController? oldController = _videoPlayerController;

      // create a new video_player controller using the dataSource
      _videoPlayerController = _createVideoController(dataSource);
      await _initializePlayer(seekTo: seekTo);
      if (oldController != null) {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          oldController.removeListener(this._listener);
          await oldController
              .dispose(); // dispose the previous video controller
        });
      }

      /// notify that video was loaded
      dataStatus.status.value = DataStatus.loaded;

      // set the video duration
      _duration.value = _videoPlayerController!.value.duration;

      // listen the video player events
      _videoPlayerController!.addListener(this._listener);
    } catch (e, s) {
      print(e);
      print(s);
      dataStatus.status.value = DataStatus.error;
    }
  }

  /// play the current video
  ///
  /// [repeat] if is true the player go to Duration.zero before play
  Future<void> play({bool repeat = false}) async {
    if (repeat) {
      await seekTo(Duration.zero);
    }
    await _videoPlayerController?.play();
    playerStatus.status.value = PlayerStatus.playing;

    _hideTaskControls();
  }

  /// pause the current video
  ///
  /// [notify] if is true and the events is not null we notifiy the event
  Future<void> pause({bool notify = true}) async {
    await _videoPlayerController?.pause();
    playerStatus.status.value = PlayerStatus.paused;
  }

  /// seek the current video position
  Future<void> seekTo(Duration position) async {
    await _videoPlayerController?.seekTo(position);

    if (playerStatus.stopped) {
      await play();
    }
  }

  /// Sets the playback speed of [this].
  ///
  /// [speed] indicates a speed value with different platforms accepting
  /// different ranges for speed values. The [speed] must be greater than 0.
  ///
  /// The values will be handled as follows:
  /// * On web, the audio will be muted at some speed when the browser
  ///   determines that the sound would not be useful anymore. For example,
  ///   "Gecko mutes the sound outside the range `0.25` to `5.0`" (see https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/playbackRate).
  /// * On Android, some very extreme speeds will not be played back accurately.
  ///   Instead, your video will still be played back, but the speed will be
  ///   clamped by ExoPlayer (but the values are allowed by the player, like on
  ///   web).
  /// * On iOS, you can sometimes not go above `2.0` playback speed on a video.
  ///   An error will be thrown for if the option is unsupported. It is also
  ///   possible that your specific video cannot be slowed down, in which case
  ///   the plugin also reports errors.
  Future<void> setPlaybackSpeed(double speed) async {
    await _videoPlayerController?.setPlaybackSpeed(speed);
    _playbackSpeed = speed;
  }

  /// Sets whether or not the video should loop after playing once
  Future<void> setLooping(bool looping) async {
    await _videoPlayerController?.setLooping(looping);
    _looping = looping;
  }

  /// Sets the audio volume
  /// [volume] indicates a value between 0.0 (silent) and 1.0 (full volume) on a
  /// linear scale.
  Future<void> setVolume(double volume) async {
    assert(volume >= 0.0 && volume <= 1.0); // validate the param
    _volumeBeforeMute = _videoPlayerController!.value.volume;
    await _videoPlayerController?.setVolume(volume);
  }

  void onChangedSliderStart() {
    _isSliderMoving = true;
  }

  onChangedSlider(double v) {
    _sliderPosition.value = Duration(seconds: v.floor());
  }

  void onChangedSliderEnd() {
    _isSliderMoving = false;
  }

  /// set the video player to mute or sound
  ///
  /// [enabled] if is true the video player is muted
  Future<void> setMute(bool enabled) async {
    if (enabled) {
      _volumeBeforeMute = _videoPlayerController!.value.volume;
    }
    _mute.value = enabled;
    await this.setVolume(enabled ? 0 : _volumeBeforeMute);
  }

  /// fast Forward (10 seconds)
  Future<void> fastForward() async {
    final to = position.inSeconds + 10;
    if (duration.inSeconds > to) {
      await seekTo(Duration(seconds: to));
    }
  }

  /// rewind (10 seconds)
  Future<void> rewind() async {
    final to = position.inSeconds - 10;
    await seekTo(Duration(seconds: to < 0 ? 0 : to));
  }

  /// show or hide the player controls
  set controls(bool visible) {
    _showControls.value = visible;
    if (_timer != null) {
      _timer!.cancel();
    }
    if (visible) {
      _hideTaskControls();
    }
  }

  /// create a taks to hide controls after certain time
  void _hideTaskControls() {
    _timer = Timer(Duration(seconds: 5), () {
      this.controls = false;
      _timer = null;
    });
  }

  /// show the player in fullscreen mode
  Future<void> goToFullscreen(
    BuildContext context, {
    bool appliyOverlaysAndOrientations = true,
  }) async {
    if (appliyOverlaysAndOrientations) {
      await screenManager.setFullScreenOverlaysAndOrientations();
    }
    _fullscreen.value = true;
    final route = MaterialPageRoute(
      builder: (_) => PurePlayerFullscreenPage(controller: this),
    );

    await Navigator.push(context, route);
    await screenManager.setDefaultOverlaysAndOrientations();
    _fullscreen.value = false;
  }

  /// launch a video using the fullscreen apge
  ///
  /// [dataSource]
  /// [autoplay]
  /// [looping]
  Future<void> launchAsFullscreen(
    BuildContext context, {
    required DataSource dataSource,
    bool autoplay = false,
    bool looping = false,
    Widget? header,
    Widget? bottomRight,
    Duration? seekTo,
  }) async {
    this.header = header;
    this.bottomRight = bottomRight;
    setDataSource(
      dataSource,
      autoplay: autoplay,
      looping: looping,
      seekTo: seekTo,
    );
    await goToFullscreen(context);
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      _position.value = Duration.zero;
      _timer?.cancel();
      await pause();
      _videoPlayerController?.removeListener(this._listener);
    });
  }

  /// dispose de video_player controller
  Future<void> dispose() async {
    if (_videoPlayerController != null) {
      dataStatus.status.value = DataStatus.none;
      _videoPlayerController?.removeListener(this._listener);
      _timer?.cancel();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }

  /// enable or diable the visibility of ClosedCaptionFile
  set closedCaptionEnabled(bool enabled) {
    _closedCaptionEnabled.value = enabled;
  }

  /// enter to picture in picture mode only Android
  ///
  /// only available since Android 7
  Future<void> enterPip(BuildContext context) async {
    if (this.pipAvailable && this.pipEnabled) {
      controls = false; // hide the controls
      if (!fullscreen) {
        // if the player is not in the fullscreen mode
        _pipContextToFullscreen = context;
        goToFullscreen(context, appliyOverlaysAndOrientations: false);
      }
      await _pipManager.enterPip();
    }
  }

  /// listener for pip changes
  void _onPipModeChanged(bool isInPipMode) {
    // if the pip mode was closed and before enter to pip mode the player was not in fullscreen
    if (!isInPipMode && _pipContextToFullscreen != null) {
      Navigator.pop(_pipContextToFullscreen!); // close the fullscreen
      _pipContextToFullscreen = null;
    }
  }

  static PurePlayerController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PurePlayerProvider>()!
        .controller;
  }
}

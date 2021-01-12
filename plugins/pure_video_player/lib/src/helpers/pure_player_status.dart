import 'package:get/state_manager.dart';

enum PlayerStatus { stopped, playing, paused }

class PurePlayerStatus {
  Rx<PlayerStatus> status = PlayerStatus.paused.obs;

  bool get playing {
    return status.value == PlayerStatus.playing;
  }

  bool get paused {
    return status.value == PlayerStatus.paused;
  }

  bool get stopped {
    return status.value == PlayerStatus.stopped;
  }
}

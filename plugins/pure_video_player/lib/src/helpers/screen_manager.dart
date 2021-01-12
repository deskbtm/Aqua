import 'package:flutter/services.dart';

class ScreenManager {
  /// [orientations] the device orientation after exit of the fullscreen
  final List<DeviceOrientation> orientations;

  /// [overlays] the device overlays after exit of the fullscreen
  final List<SystemUiOverlay> overlays;

  /// when the player is in fullscreen mode if forceLandScapeInFullscreen the player only show the landscape mode
  final bool forceLandScapeInFullscreen;

  const ScreenManager({
    this.orientations = DeviceOrientation.values,
    this.overlays = SystemUiOverlay.values,
    this.forceLandScapeInFullscreen = true,
  });

  /// set the default orientations and overlays after exit of fullscreen
  Future<void> setDefaultOverlaysAndOrientations() async {
    await SystemChrome.setPreferredOrientations(this.orientations);
    await SystemChrome.setEnabledSystemUIOverlays(this.overlays);
  }

  /// hide the statusBar and the navigation bar, set only landscape mode only if forceLandScapeInFullscreen is true
  Future<void> setFullScreenOverlaysAndOrientations({
    hideOverLays = true,
  }) async {
    await SystemChrome.setPreferredOrientations(this.forceLandScapeInFullscreen
        ? [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : this.orientations);

    if (hideOverLays) {
      await SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }
}

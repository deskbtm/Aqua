import 'package:vibration/vibration.dart';

Future<void> pressVibrate() async {
  if (await Vibration.hasVibrator()) {
    if (await Vibration.hasAmplitudeControl()) {
      Vibration.vibrate(duration: 120, amplitude: 100);
    } else {
      Vibration.vibrate(duration: 120);
    }
  }
}

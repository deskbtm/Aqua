import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const COMMON_CHANNEL = '0';
const ARCHIVE_CHANNEL = '1';

class LocalNotification {
  static FlutterLocalNotificationsPlugin plugin;

  static Future<FlutterLocalNotificationsPlugin> initLocalNotification(
      {@required Function onSelected}) async {
    plugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher_round');
    var ios = IOSInitializationSettings();
    var initSetttings = InitializationSettings(android, ios);
    await plugin.initialize(initSetttings, onSelectNotification: onSelected);
    return plugin;
  }

  static Future<void> showNotification({
    String id = COMMON_CHANNEL,
    int index = 0,
    @required String name,
    @required String title,
    String subTitle,
    String payload,
    bool ongoing = false,
    bool onlyAlertOnce = false,
    bool showProgress = false,
    bool indeterminate = false,
    bool autoCancel = false,
  }) async {
    var android = AndroidNotificationDetails(
      id,
      name,
      'CHANNEL DESCRIPTION',
      priority: Priority.High,
      importance: Importance.Max,
      ongoing: ongoing,
      autoCancel: autoCancel,
      onlyAlertOnce: onlyAlertOnce,
      showProgress: showProgress,
      indeterminate: indeterminate,
    );
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android, ios);
    await plugin.show(index, title, subTitle, platform, payload: payload);
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// const SOCKET_CHANNEL = '1';
// const STATIC_CHANNEL = '2';
const COMMON_CHANNEL = '0';
const ARCHIVE_CHANNEL = '1';

// const String SOCKET_UNCONNECT_ID = '1';
// const String SOCKET_DISCONNECT_ID = '2';
// const String SOCKET_CONNECT_ID = '3';
// const String STATIC_OPEN_ID = '4';
// const String STATIC_CLOSE_ID = '5';

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
  }) async {
    var android = AndroidNotificationDetails(
      id,
      name,
      'CHANNEL DESCRIPTION',
      priority: Priority.High,
      importance: Importance.Max,
      ongoing: ongoing,
      onlyAlertOnce: onlyAlertOnce,
      showProgress: showProgress,
      indeterminate: indeterminate,
    );
    var ios = IOSNotificationDetails();
    var platform = NotificationDetails(android, ios);
    await plugin.show(index, title, subTitle, platform, payload: payload);
  }
}

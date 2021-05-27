import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const COMMON_CHANNEL = '0';
const ARCHIVE_CHANNEL = '1';

class LocalNotification {
  static late FlutterLocalNotificationsPlugin? plugin;

  static Future<void> initLocalNotification(
      {required SelectNotificationCallback onSelected}) async {
    plugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('ic_baseline_folder_24');
    var initSetttings = InitializationSettings(android: android);
    await plugin?.initialize(initSetttings, onSelectNotification: onSelected);
  }

  static Future<void> showNotification({
    String id = COMMON_CHANNEL,
    int index = 0,
    required String name,
    required String title,
    String? subTitle,
    String? payload,
    bool ongoing = false,
    bool onlyAlertOnce = false,
    bool showProgress = false,
    bool indeterminate = false,
    bool autoCancel = false,
    NotificationVisibility visibility = NotificationVisibility.public,
  }) async {
    var android = AndroidNotificationDetails(
      id,
      name,
      'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max,
      ongoing: ongoing,
      autoCancel: autoCancel,
      onlyAlertOnce: onlyAlertOnce,
      showProgress: showProgress,
      indeterminate: indeterminate,
      visibility: visibility,
      color: Color(0xFF007AFF),
    );
    var platform = NotificationDetails(android: android);
    await plugin?.show(index, title, subTitle, platform, payload: payload);
  }
}

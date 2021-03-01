import 'package:flutter/services.dart';

class StorageMountListener {
  static const EventChannel channel =
      const EventChannel('storage_mount_listener');
}

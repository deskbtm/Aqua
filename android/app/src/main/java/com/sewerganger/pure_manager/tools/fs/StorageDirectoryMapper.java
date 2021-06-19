package com.sewerganger.pure_manager.tools.fs;

    import android.os.Build;
    import android.os.Environment;

class StorageDirectoryMapper {

  static String androidType(Integer dartIndex) throws IllegalArgumentException {
    if (dartIndex == null) {
      return null;
    }

    switch (dartIndex) {
      case 0:
        return Environment.DIRECTORY_MUSIC;
      case 1:
        return Environment.DIRECTORY_PODCASTS;
      case 2:
        return Environment.DIRECTORY_RINGTONES;
      case 3:
        return Environment.DIRECTORY_ALARMS;
      case 4:
        return Environment.DIRECTORY_NOTIFICATIONS;
      case 5:
        return Environment.DIRECTORY_PICTURES;
      case 6:
        return Environment.DIRECTORY_MOVIES;
      case 7:
        return Environment.DIRECTORY_DOWNLOADS;
      case 8:
        return Environment.DIRECTORY_DCIM;
      case 9:
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
          return Environment.DIRECTORY_DOCUMENTS;
        } else {
          throw new IllegalArgumentException("Documents directory is unsupported.");
        }
      default:
        throw new IllegalArgumentException("Unknown index: " + dartIndex);
    }
  }
}
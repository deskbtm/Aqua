package com.sewerganger.pure_manager.tools.fs;

import java.io.File;

import android.content.Context;

import androidx.annotation.IntDef;

public final class StorageDescription {

  public static final int STORAGE_INTERNAL = 0;
  public static final int STORAGE_SD_CARD = 1;
  public static final int ROOT = 2;
  public static final int NOT_KNOWN = 3;

  @IntDef({STORAGE_INTERNAL, STORAGE_SD_CARD, ROOT, NOT_KNOWN})
  public @interface DeviceDescription {
  }

  public static @DeviceDescription
  int getDeviceDescriptionLegacy(File file) {
    String path = file.getPath();

    switch (path) {
      case "/storage/emulated/legacy":
      case "/storage/emulated/0":
      case "/mnt/sdcard":
        return STORAGE_INTERNAL;
      case "/storage/sdcard":
      case "/storage/sdcard1":
        return STORAGE_SD_CARD;
      case "/":
        return ROOT;
      default:
        return NOT_KNOWN;
    }
  }
}

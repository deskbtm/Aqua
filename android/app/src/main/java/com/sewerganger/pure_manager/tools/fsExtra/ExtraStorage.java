package com.sewerganger.pure_manager.tools.fsExtra;


import android.content.Context;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.util.PathUtils;

import static android.os.Build.VERSION_CODES.M;

public class ExtraStorage {
  private Context context;

  public ExtraStorage(Context ctx) {
    context = ctx;
  }

  public String getTemporaryDirectory() {
    return context.getCacheDir().getPath();
  }

  public String getExternalStorageState() {
    return Environment.getExternalStorageState();
  }

  public String getExternalStorageDirectory() {
//    String path;
//    if (Build.VERSION.SDK_INT < M) {
//      path = Environment.getExternalStorageDirectory().getAbsolutePath();
//    } else {
//      path = "content://com.android.externalstorage.documents/tree/primary%3A";
//    }

    return Environment.getExternalStorageDirectory().getAbsolutePath();
  }

  public String getFilesDir() {
    return context.getFilesDir().getAbsolutePath();
  }

  public String getCacheDir() {
    return context.getCacheDir().getAbsolutePath();
  }

  public String getDataDirectory() {
    return Environment.getDataDirectory().getAbsolutePath();
  }

  public String getExternalCacheDir() {
    return context.getExternalCacheDir().getAbsolutePath();
  }

  public String getApplicationSupportDirectory() {
    return PathUtils.getFilesDir(context);
  }

  public String getApplicationDocumentsDirectory() {
    return PathUtils.getDataDirectory(context);
  }

  public double getTotalExternalStorageSize() {
    StatFs statFs = new StatFs(getExternalStorageDirectory());
    long size;

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
      size = statFs.getBlockSizeLong() * statFs.getBlockCountLong();
    } else {
      size = (long) statFs.getBlockSize() * (long) statFs.getBlockCount();
    }

    return (double) size;
  }

  public double getValidExternalStorageSize() {
    StatFs statFs = new StatFs(getExternalStorageDirectory());
    long size;

    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR2) {
      size = statFs.getBlockSizeLong() * statFs.getAvailableBlocksLong();
    } else {
      size = (long) statFs.getBlockSize() * (long) statFs.getAvailableBlocks();
    }

    return (double) size;
  }


  public String getExternalFilesDir() {
    final File dir = context.getExternalFilesDir(null);
    if (dir == null) {
      return null;
    }
    return dir.getAbsolutePath();
  }

  public List<String> getExternalCacheDirectories() {
    final List<String> paths = new ArrayList<>();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      for (File dir : context.getExternalCacheDirs()) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = context.getExternalCacheDir();
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }

  public List<String> getExternalStorageDirectories(String type) {
    final List<String> paths = new ArrayList<>();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      for (File dir : context.getExternalFilesDirs(type)) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = context.getExternalFilesDir(type);
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }
}


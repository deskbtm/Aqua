package com.deskbtm.aqua.tools.fs;

import android.content.Context;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.PathUtils;

public class PathProvider {
  private Context mContext;


  public PathProvider(Context context) {
    mContext = context;
  }


  public String getTemporaryDirectory() {
    return mContext.getCacheDir().getPath();
  }

  public void getExternalStorageState(MethodChannel.Result result) {
    String state = Environment.getExternalStorageState();
    result.success(state);
  }

  public String getExternalStorageDirectory() {
    return Environment.getExternalStorageDirectory().getAbsolutePath();
  }

  public String getFilesDir() {
    return mContext.getFilesDir().getAbsolutePath();
  }

  public String getCacheDir() {
    return mContext.getCacheDir().getAbsolutePath();
  }

  public String getDataDirectory() {
    return Environment.getDataDirectory().getAbsolutePath();
  }

  public String getExternalCacheDir() {
    return mContext.getExternalCacheDir().getAbsolutePath();
  }

  public String getApplicationSupportDirectory() {
    return PathUtils.getFilesDir(mContext);
  }

  public String getApplicationDocumentsDirectory() {
    return PathUtils.getDataDirectory(mContext);
  }

  public List<String> getExternalCacheDirectories() {
    final List<String> paths = new ArrayList<>();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      for (File dir : mContext.getExternalCacheDirs()) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = mContext.getExternalCacheDir();
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }

  public String getExternalFilesDir() {
    final File dir = mContext.getExternalFilesDir(null);
    if (dir == null) {
      return null;
    }
    return dir.getAbsolutePath();
  }

  public List<String> getExternalStorageDirectories(String type) {
    final List<String> paths = new ArrayList<>();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      for (File dir : mContext.getExternalFilesDirs(type)) {
        if (dir != null) {
          paths.add(dir.getAbsolutePath());
        }
      }
    } else {
      File dir = mContext.getExternalFilesDir(type);
      if (dir != null) {
        paths.add(dir.getAbsolutePath());
      }
    }

    return paths;
  }

}

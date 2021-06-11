package com.sewerganger.pure_manager.tools.fsExtra;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;
import android.provider.DocumentsContract;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.PathUtils;

import static android.os.Build.VERSION_CODES.M;

public class ExtraStorage {
  private Context context;
  private Activity mActivity;

  public ExtraStorage(Context ctx, Activity activity) {
    context = ctx;mActivity = activity;
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

  public void requestDataObbAccess(MethodChannel.Result result) {
    try {
      Uri uri = Uri.parse("content://com.android.externalstorage.documents/document/primary%3AAndroid%2Fdata");
      Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
      intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri);
      intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
          | Intent.FLAG_GRANT_WRITE_URI_PERMISSION
          | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
      mActivity.startActivityForResult(intent, 998);
      result.success(true);
    } catch (Exception e) {
      e.printStackTrace();
      result.success(false);
    }
  }
}


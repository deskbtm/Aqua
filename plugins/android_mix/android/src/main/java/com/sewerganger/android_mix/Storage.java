package com.sewerganger.android_mix;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.util.PathUtils;

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

public class Storage {
  private Context context;

  public Storage(Context ctx) {
    context = ctx;
  }

  public String getTemporaryDirectory() {
    return context.getCacheDir().getPath();
  }

  public String getExternalStorageDirectory() {
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

  private Bitmap drawableToBitmap(Drawable drawable) {
    int width = drawable.getIntrinsicWidth();// 取drawable的长宽
    int height = drawable.getIntrinsicHeight();
    Bitmap.Config config = drawable.getOpacity() != PixelFormat.OPAQUE ? Bitmap.Config.ARGB_8888 : Bitmap.Config.RGB_565;// 取drawable的颜色格式
    Bitmap bitmap = Bitmap.createBitmap(width, height, config);// 建立对应bitmap
    Canvas canvas = new Canvas(bitmap);// 建立对应bitmap的画布
    drawable.setBounds(0, 0, width, height);
    drawable.draw(canvas);// 把drawable内容画到画布中
    return bitmap;
  }

  public HashMap getApkInfo(String path) {
    HashMap info = new HashMap();
    try {
      PackageManager packageManager = context.getPackageManager();
      PackageInfo packageInfo = packageManager.getPackageArchiveInfo(path, PackageManager.GET_ACTIVITIES);
      if (packageInfo != null) {
        ApplicationInfo appInfo = packageInfo.applicationInfo;

        appInfo.sourceDir = path;
        appInfo.publicSourceDir = path;


        Drawable icon = appInfo.loadIcon(packageManager);
        String appName = packageManager.getApplicationLabel(appInfo).toString();

        Bitmap bitIcon = drawableToBitmap(icon);

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        bitIcon.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
        byte[] byteArray = byteArrayOutputStream.toByteArray();

        info.put("icon", byteArray);
        info.put("appName", appName);
        info.put("packageName", appInfo.packageName);
        info.put("permission", appInfo.permission);
        info.put("processName", appInfo.processName);
        // 应用数据目录
        info.put("dataDir", appInfo.dataDir);
        // 本地路径  JNI本地库存放路径
        info.put("nativeLibraryDir", appInfo.nativeLibraryDir);
        info.put("sourceDir", appInfo.sourceDir);
      }

    } catch (Exception err) {
      throw err;
    }
    return info;
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


  public String getStorageDirectory() {
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

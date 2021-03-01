package com.sewerganger.android_mix;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PixelFormat;
import android.graphics.drawable.Drawable;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;

public class MixPackageManager {
  private Context context;

  public MixPackageManager(Context ctx) {
    context = ctx;
  }

  private byte[] drawableToByte(Drawable drawable) {
    int width = drawable.getIntrinsicWidth();// 取drawable的长宽
    int height = drawable.getIntrinsicHeight();
    Bitmap.Config config = drawable.getOpacity() != PixelFormat.OPAQUE ? Bitmap.Config.ARGB_8888 : Bitmap.Config.RGB_565;// 取drawable的颜色格式
    Bitmap bitmap = Bitmap.createBitmap(width, height, config);// 建立对应bitmap
    Canvas canvas = new Canvas(bitmap);// 建立对应bitmap的画布
    drawable.setBounds(0, 0, width, height);
    drawable.draw(canvas);// 把drawable内容画到画布中
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    return byteArrayOutputStream.toByteArray();
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

        byte[] byteArray = drawableToByte(icon);

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

  public byte[] getPackageIconByName(String name) throws PackageManager.NameNotFoundException {
    Drawable icon = context.getPackageManager().getApplicationIcon(name);
    return drawableToByte(icon);
  }

  public HashMap getPackageInfoByName(String name) throws PackageManager.NameNotFoundException {
    PackageManager pm = context.getPackageManager();
    ApplicationInfo appInfo = pm.getApplicationInfo(name,PackageManager.GET_META_DATA);
    HashMap info = new HashMap();

    info.put("icon", getPackageIconByName(name));
    info.put("appName", pm.getApplicationLabel(appInfo).toString());
    info.put("dataDir", appInfo.dataDir);
    info.put("packageNam", appInfo.packageName);
    info.put("nativeLibraryDir", appInfo.nativeLibraryDir);
    info.put("sourceDir", appInfo.sourceDir);
    info.put("permission", appInfo.permission);

    return info;
  }
}

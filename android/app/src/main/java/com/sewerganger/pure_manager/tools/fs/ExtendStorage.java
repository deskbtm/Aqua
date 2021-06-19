package com.sewerganger.pure_manager.tools.fs;


import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;
import android.os.storage.StorageManager;
import android.os.storage.StorageVolume;
import android.provider.DocumentsContract;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Collections;
import java.util.EventListener;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Pattern;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.PathUtils;

import static android.os.Build.VERSION_CODES.N;
import static androidx.core.content.ContextCompat.getSystemService;


public class ExtendStorage {
  private Context context;
  private Activity mActivity;
  private static final String INTERNAL_SHARED_STORAGE = "Internal shared storage";
  private String TAG = "ExtendStorage";
  private String STORAGE_INTERNAL = "storage_internal";
  private String STORAGE_SDCARD = "storage_sdcard";
  private String STORAGE_ROOT = "storage_roor";
//  private String STORAGE_INTERNAL = "storage_internal";

  public ExtendStorage(Context ctx, Activity activity) {
    context = ctx;
    mActivity = activity;
  }

  public String getTemporaryDirectory() {
    return context.getCacheDir().getPath();
  }

  public void getExternalStorageState(MethodChannel.Result result) {
    String state = Environment.getExternalStorageState();
    result.success(state);
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

  public void canRead(MethodCall call, MethodChannel.Result result) {
    String path = call.argument("canOperable");
    boolean readable = new File(path).canRead();
    result.success(readable);
  }

  public void requestDataObbAccess(MethodChannel.Result result) {
    try {
      Uri uri = Uri.parse("content://com.android.externalstorage.documents/document/primary%3AAndroid%2Fdata");
      Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, uri);
      }
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


  public void getAllValidStorage(MethodChannel.Result result) {
    try {
      ArrayList<HashMap> volumes = getStorageDirectories();
      result.success(volumes);
    } catch (Exception e) {
      result.error("getAllExternalStoragePath", "get all external storage error", e);
    }
  }

  @TargetApi(Build.VERSION_CODES.N)
  public static File getVolumeDirectory(StorageVolume volume) {
    try {
      Field f = StorageVolume.class.getDeclaredField("mPath");
      f.setAccessible(true);
      return (File) f.get(volume);
    } catch (Exception e) {
      // This shouldn't fail, as mPath has been there in every version
      throw new RuntimeException(e);
    }
  }

//  @TargetApi(Build.VERSION_CODES.KITKAT)
//  ArrayList<String> getExtSdCardPathsForActivity(Context context) {
//    ArrayList<String> paths = new ArrayList();
//    File[] externals = context.getExternalFilesDirs("external");
//    for (File file : externals) {
//      if (file != null) {
//        int index = file.getAbsolutePath().lastIndexOf("/Android/data");
//        if (index < 0) {
//          Log.w(TAG, "Unexpected external file dir: " + file.getAbsolutePath());
//        } else {
//          String path = file.getAbsolutePath().substring(0, index);
//          try {
//            path = new File(path).getCanonicalPath();
//          } catch (IOException e) {
//            // Keep non-canonical path.
//          }
//          paths.add(path);
//        }
//      }
//    }
//    if (paths.isEmpty()) paths.add("/storage/sdcard1");
//    return paths;
//  }

  public synchronized ArrayList<HashMap> getStorageDirectories() {
    // Final set of paths
    ArrayList<HashMap> volumes = new ArrayList<>();
    StorageManager sm = getSystemService(context, StorageManager.class);
    for (StorageVolume volume : sm.getStorageVolumes()) {
      if (!volume.getState().equalsIgnoreCase(Environment.MEDIA_MOUNTED)
          && !volume.getState().equalsIgnoreCase(Environment.MEDIA_MOUNTED_READ_ONLY)) {
        continue;
      }
      File file = getVolumeDirectory(volume);
      String description = volume.getDescription(context);

      HashMap vol = new HashMap();

      vol.put("description", description);
      vol.put("path", file.getPath());
      vol.put("isRemovable", volume.isRemovable());
      vol.put("isPrimary", volume.isPrimary());
      vol.put("isEmulated", volume.isEmulated());

      volumes.add(vol);
    }
    return volumes;
  }


//  public ArrayList<HashMap> getStorageDirectoriesLegacy() {
//    List<String> avail = new ArrayList<>();
//    final String rawExternalStorage = System.getenv("EXTERNAL_STORAGE");
//    final String rawSecondaryStoragesStr = System.getenv("SECONDARY_STORAGE");
//    final String rawEmulatedStorageTarget = System.getenv("EMULATED_STORAGE_TARGET");
//
//    if (TextUtils.isEmpty(rawEmulatedStorageTarget)) {
//      if (TextUtils.isEmpty(rawExternalStorage)) {
//        avail.add(Environment.getExternalStorageDirectory().getAbsolutePath());
//      } else {
//        avail.add(rawExternalStorage);
//      }
//    } else {
//      final String rawUserId;
//      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR1) {
//        rawUserId = "";
//      } else {
//        final String path = Environment.getExternalStorageDirectory().getAbsolutePath();
//        final String[] folders = Pattern.compile("/").split(path);
//        final String lastFolder = folders[folders.length - 1];
//        boolean isDigit = false;
//        try {
//          Integer.valueOf(lastFolder);
//          isDigit = true;
//        } catch (NumberFormatException ignored) {
//        }
//        rawUserId = isDigit ? lastFolder : "";
//      }
//      // /storage/emulated/0[1,2,...]
//      if (TextUtils.isEmpty(rawUserId)) {
//        avail.add(rawEmulatedStorageTarget);
//      } else {
//        avail.add(rawEmulatedStorageTarget + File.separator + rawUserId);
//      }
//    }
//    if (!TextUtils.isEmpty(rawSecondaryStoragesStr)) {
//      final String[] rawSecondaryStorages = rawSecondaryStoragesStr.split(File.pathSeparator);
//      Collections.addAll(avail, rawSecondaryStorages);
//    }
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) avail.clear();
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
//      ArrayList<String> strings = getExtSdCardPathsForActivity(context);
//      for (String s : strings) {
//        File file = new File(s);
//        if (!avail.contains(s) && file.canRead() && file.isDirectory()) avail.add(s);
//      }
//    }
//    File usb = getUsbDrive();
//    if (usb != null && !avail.contains(usb.getPath())) {
//      avail.add(usb.getPath());
//    }
//    ;
//
//    ArrayList<HashMap> volumes = new ArrayList<>();
//    for (String path : avail) {
//      File file = new File(path);
//
//      @StorageDescription.DeviceDescription
//      int deviceDescription = StorageDescription.getDeviceDescriptionLegacy(file);
//      String description = getNameForDeviceDescription(file, deviceDescription);
//      HashMap vol = new HashMap();
//
//      vol.put("description", description);
//      vol.put("path", file.getPath());
//
//      volumes.add(vol);
//    }
//
//    return volumes;
//  }

  private String getNameForDeviceDescription(File file, int d) {
    switch (d) {
      case StorageDescription.STORAGE_INTERNAL:
        return STORAGE_INTERNAL;
      case StorageDescription.STORAGE_SD_CARD:
        return STORAGE_SDCARD;
      case StorageDescription.ROOT:
        return STORAGE_ROOT;
      case StorageDescription.NOT_KNOWN:
      default:
        return file.getName();
    }
  }


  public File getUsbDrive() {
    File parent = new File("/storage");

    try {
      for (File f : parent.listFiles())
        if (f.exists() && f.getName().toLowerCase().contains("usb") && f.canExecute()) return f;
    } catch (Exception e) {
    }

    parent = new File("/mnt/sdcard/usbStorage");
    if (parent.exists() && parent.canExecute()) return parent;
    parent = new File("/mnt/sdcard/usb_storage");
    if (parent.exists() && parent.canExecute()) return parent;

    return null;
  }

}


package com.sewerganger.pure_manager.tools.virtual_container;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class VirtualContainerUtils {

  private Context context;
  private String TAG = "VirtualContainerUtils";

  public VirtualContainerUtils(Context ctx) {
    context = ctx;
  }


  public void copyDirFromAssets(MethodCall call, MethodChannel.Result result) {
    Handler handler = new Handler(Looper.getMainLooper());






//    Handler.


  }


  private void copyAssetsDir(String path) {
    AssetManager assetManager = context.getAssets();
    try {
      String[] assets = assetManager.list(path);
      if (assets.length == 0) {
        copyAssetsFile(path);
      } else {
        String fullPath = context.getFilesDir().getAbsolutePath() + "/" + path;
        File dir = new File(fullPath);
        if (!dir.exists())
          dir.mkdirs();
        for (int i = 0; i < assets.length; ++i) {
          copyAssetsDir(path + "/" + assets[i]);
        }
      }
    } catch (IOException ex) {
      Log.e(TAG, "I/O Exception", ex);
    }
  }

  private void copyAssetsFile(String filename) {
    AssetManager assetManager = context.getAssets();

    try {
      InputStream inputStream = assetManager.open(filename);
      String targetFileName = context.getFilesDir().getAbsolutePath() + "/" + filename;
      OutputStream outputStream = new FileOutputStream(targetFileName);

      byte[] buffer = new byte[inputStream.available()];
      int read;
      while ((read = inputStream.read(buffer)) != -1) {
        outputStream.write(buffer, 0, read);
      }
      inputStream.close();
      outputStream.flush();
      outputStream.close();
    } catch (Exception e) {
      Log.e(TAG, e.getMessage());
    }

  }
}

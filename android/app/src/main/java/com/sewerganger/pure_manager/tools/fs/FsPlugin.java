package com.sewerganger.pure_manager.tools.fs;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.nio.file.Path;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class FsPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private MethodChannel mChannel;
  private Context mContext;

  private String CHANNEL_NAME = "aqua_fs";
  private Activity mActivity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    mChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    mChannel.setMethodCallHandler(this);
    mContext = binding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    mChannel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    ExtendStorage extendStorage = new ExtendStorage(mContext, mActivity);
    PathProvider pathProvider = new PathProvider(mContext);

    switch (call.method) {
      case "getTemporaryDirectory":
        result.success(pathProvider.getTemporaryDirectory());
        break;
      case "getApplicationDocumentsDirectory":
        result.success(pathProvider.getApplicationDocumentsDirectory());
        break;
      case "getExternalFilesDir":
        result.success(pathProvider.getExternalFilesDir());
        break;
      case "getExternalCacheDirectories":
        result.success(pathProvider.getExternalCacheDirectories());
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        result.success(pathProvider.getExternalStorageDirectories(directoryName));
        break;
      case "getApplicationSupportDirectory":
        result.success(pathProvider.getApplicationSupportDirectory());
        break;
      case "getExternalStorageDirectory":
        result.success(pathProvider.getExternalStorageDirectory());
        break;
      case "getFilesDir":
        result.success(pathProvider.getFilesDir());
        break;
      case "getCacheDir":
        result.success(pathProvider.getCacheDir());
        break;
      case "getDataDirectory":
        result.success(pathProvider.getDataDirectory());
        break;
      case "getExternalCacheDir":
        result.success(pathProvider.getExternalCacheDir());
        break;
      case "getTotalExternalStorageSize":
        result.success(extendStorage.getTotalExternalStorageSize());
        break;
      case "getValidExternalStorageSize":
        result.success(extendStorage.getValidExternalStorageSize());
        break;
      case "requestDataObbAccess":
        extendStorage.requestDataObbAccess(result);
        break;
      case "getExternalStorageState":
        extendStorage.getExternalStorageState(result);
        break;
      case "getAllValidStorage":
        extendStorage.getAllValidStorage(result);
        break;
      case "canRead":
        extendStorage.canRead(call, result);
        break;
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    mActivity = null;
  }
}


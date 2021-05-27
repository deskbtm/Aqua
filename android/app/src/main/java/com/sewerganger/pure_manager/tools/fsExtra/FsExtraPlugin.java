package com.sewerganger.pure_manager.tools.fsExtra;

import android.content.Context;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class FsExtraPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private MethodChannel channel;
  private Context context;
  private ExtraStorage extraStorage;
  private String CHANNEL_NAME = "aqua_fs";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    context = binding.getApplicationContext();
    extraStorage = new ExtraStorage(context);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "getTemporaryDirectory":
        result.success(extraStorage.getTemporaryDirectory());
        break;
      case "getApplicationDocumentsDirectory":
        result.success(extraStorage.getApplicationDocumentsDirectory());
        break;
      case "getExternalFilesDir":
        result.success(extraStorage.getExternalFilesDir());
        break;
      case "getExternalCacheDirectories":
        result.success(extraStorage.getExternalCacheDirectories());
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        result.success(extraStorage.getExternalStorageDirectories(directoryName));
        break;
      case "getApplicationSupportDirectory":
        result.success(extraStorage.getApplicationSupportDirectory());
        break;
      case "getExternalStorageDirectory":
        result.success(extraStorage.getExternalStorageDirectory());
        break;
      case "getFilesDir":
        result.success(extraStorage.getFilesDir());
        break;
      case "getCacheDir":
        result.success(extraStorage.getCacheDir());
        break;
      case "getDataDirectory":
        result.success(extraStorage.getDataDirectory());
        break;
      case "getExternalCacheDir":
        result.success(extraStorage.getExternalCacheDir());
        break;
      case "getTotalExternalStorageSize":
        result.success(extraStorage.getTotalExternalStorageSize());
        break;
      case "getValidExternalStorageSize":
        result.success(extraStorage.getValidExternalStorageSize());
        break;
    }
  }
}


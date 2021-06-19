package com.sewerganger.pure_manager.tools.archive;

import android.app.Activity;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class ArchivePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private Archive archive;
  private Activity activity;
  private String CHANNEL_NAME = "aqua_archive";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    archive = null;
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    archive = new Archive(activity);
    switch (call.method) {
      case "zip":
        archive.createZip(call, result);
        break;
      case "unzip":
        archive.createUnzip(call, result);
        break;
      case "isZipEncrypted":
        archive.isZipEncrypted(call, result);
        break;
      case "isValidZipFile":
        archive.isValidZipFile(call, result);
        break;
      case "createArchive":
        archive.createArchive(call, result);
        break;
      case "extractArchive":
        archive.extractArchive(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {
    if (!activity.isDestroyed()) {
      activity.finish();
    }
  }
}

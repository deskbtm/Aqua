package com.sewerganger.storage_mount_listener;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * StorageMountListenerPlugin
 */
public class StorageMountListenerPlugin extends BroadcastReceiver implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String ACTION_MEDIA_REMOVED = "android.intent.action.MEDIA_REMOVED";
  private static final String ACTION_MEDIA_MOUNTED = "android.intent.action.MEDIA_MOUNTED";
  private static final String MEDIA_BAD_REMOVAL = "android.intent.action.MEDIA_BAD_REMOVAL";
  private static final String MEDIA_EJECT = "android.intent.action.MEDIA_EJECT";
  private static final String TAG = "SDCardBroadcastReceiver";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "storage_mount_listener");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onReceive(Context context, Intent intent) {
    Log.i(TAG, "Intent received: " + intent.getAction());

    if (intent.getAction() == ACTION_MEDIA_REMOVED) {
      channel.invokeMethod("mediaRemove", null);
    } else if (intent.getAction() == ACTION_MEDIA_MOUNTED) {
      channel.invokeMethod("mediaMounted", null);
    } else if (intent.getAction() == MEDIA_BAD_REMOVAL) {
      Log.e(TAG, "MEDIA_BAD_REMOVAL called");
      channel.invokeMethod("mediaBadRemoval", null);
    } else if (intent.getAction() == MEDIA_EJECT) {
      channel.invokeMethod("mediaEject", null);
      Log.e(TAG, "MEDIA_EJECT called");
    }
  }
}

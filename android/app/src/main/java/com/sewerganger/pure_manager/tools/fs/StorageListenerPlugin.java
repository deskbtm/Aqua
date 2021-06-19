package com.sewerganger.pure_manager.tools.fs;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;

/**
 * StorageMountListenerPlugin
 */
public class StorageListenerPlugin extends BroadcastReceiver implements FlutterPlugin, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private EventChannel eventChannel;
  private BroadcastReceiver sdcardStatusReceiver;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "aqua_storage_listener");
    eventChannel.setStreamHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    eventChannel.setStreamHandler(null);
    eventChannel = null;
  }

  @Override
  public void onListen(Object arguments, final EventChannel.EventSink events) {
    sdcardStatusReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        Log.i("ExternalStorageMount", intent.getAction());
        switch (intent.getAction()) {
          case Intent.ACTION_MEDIA_MOUNTED:
            events.success("mounted");
            break;
          case Intent.ACTION_MEDIA_REMOVED:
            events.success("removed");
            break;
          case Intent.ACTION_MEDIA_BAD_REMOVAL:
            events.success("removal");
            break;
          case Intent.ACTION_MEDIA_EJECT:
            events.success("eject");
            break;
        }
      }
    };

    IntentFilter intentFilter = new IntentFilter();
    intentFilter.addAction(Intent.ACTION_MEDIA_MOUNTED);
    intentFilter.addAction(Intent.ACTION_MEDIA_REMOVED);
    intentFilter.addAction(Intent.ACTION_MEDIA_BAD_REMOVAL);
    intentFilter.addAction(Intent.ACTION_MEDIA_EJECT);
    intentFilter.addDataScheme("file");

    context.registerReceiver(sdcardStatusReceiver, intentFilter);
  }

  @Override
  public void onCancel(Object arguments) {
    context.unregisterReceiver(sdcardStatusReceiver);
    sdcardStatusReceiver = null;
  }

  @Override
  public void onReceive(Context context, Intent intent) {

  }
}

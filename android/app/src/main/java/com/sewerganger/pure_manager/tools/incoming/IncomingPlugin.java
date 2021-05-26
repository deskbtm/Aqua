package com.sewerganger.pure_manager.tools.incoming;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.sewerganger.pure_manager.tools.archive.Archive;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class IncomingPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
  private MethodChannel channel;
  private Activity activity;
  private String CHANNEL_NAME = "aqua_incoming";


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch(call.method){
      case "getIncomingFile": {
//        result.success(incomingIntent);
//        incomingIntent = null;
      }
    }
  }
}

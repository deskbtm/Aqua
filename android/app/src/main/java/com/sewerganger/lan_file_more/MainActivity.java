package com.sewerganger.lan_file_more;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.umeng.analytics.MobclickAgent;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private Map incomingIntent;
  private static final String CHANNEL = "app.channel.shared.data";

  @Override
  public void onResume() {
    super.onResume();
    MobclickAgent.onResume(this);
  }

  @Override
  public void onPause() {
    super.onPause();
    MobclickAgent.onPause(this);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();
    
    if (Intent.ACTION_VIEW.equals(action) && type != null) {
      Uri uri = intent.getData();
      incomingIntent = new HashMap();
      incomingIntent.put("path", Uri.decode(uri.getEncodedPath()));
      incomingIntent.put("type", type);
    }
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          Log.i("DEMO#", call.method);
          Log.i("=++SS++", (call.method.contentEquals("getSharedText")) + "" + (incomingIntent != null));
          if (call.method.contentEquals("getSharedText")) {
            if (incomingIntent != null) {
              Log.i("DEMO#", incomingIntent.toString());
              result.success(incomingIntent);
              incomingIntent = null;
            }
          }
        }
      );
  }

}

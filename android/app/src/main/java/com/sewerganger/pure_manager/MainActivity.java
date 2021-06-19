/*
 *   Copyright (c) 2021
 *   All rights reserved.
 */
package com.sewerganger.pure_manager;

import android.app.Activity;
import android.os.Bundle;
import android.provider.DocumentsContract;
import android.widget.Button;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends Activity {
//  private Map incomingIntent;
//  private static final String CHANNEL = "app.channel.shared.data";
//  private String APP_NORMAL_MODE = "normal";
//  private String APP_INCOMING_MODE = "incoming";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
//    getApplicationContext().
    Button btn = (Button) findViewById(R.id.button);

    btn.setOnClickListener(v->{
      try {
        String[] a = getAssets().list("./");
      } catch (IOException e) {
        e.printStackTrace();
      }
    });
//    Button


//    Intent intent = getIntent();
//    String action = intent.getAction();
//    String type = intent.getType();
//    incomingIntent = new HashMap();
//
//    if (Intent.ACTION_VIEW.equals(action) && type != null) {
//      Uri uri = intent.getData();
//      incomingIntent.put("path", Uri.decode(uri.getEncodedPath()));
//      incomingIntent.put("type", type);
//      incomingIntent.put("appMode", APP_INCOMING_MODE);
//    } else {
//      incomingIntent.put("appMode", APP_NORMAL_MODE);
//    }
  }

//  @Override
//  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
//    GeneratedPluginRegistrant.registerWith(flutterEngine);
//    InnerPluginMgmt.register(flutterEngine);
//
////    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
////      .setMethodCallHandler(
////        (call, result) -> {
////          if (call.method.contentEquals("getIncomingFile")) {
////            result.success(incomingIntent);
////            incomingIntent = null;
////          }
////        }
////      );
//  }
}

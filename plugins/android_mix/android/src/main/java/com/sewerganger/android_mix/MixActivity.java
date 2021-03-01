package com.sewerganger.android_mix;

import android.app.Activity;
import android.content.Context;

import java.util.ArrayList;
import java.util.Arrays;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MixActivity {
  static ArrayList<String> includeMethods = new ArrayList<>(Arrays.asList("moveTaskToBack"));

  public MixActivity(Context context, Activity activity, MethodCall call, final MethodChannel.Result result) {

    switch (call.method) {
      case "moveTaskToBack":
        boolean nonRoot = call.argument("nonRoot");
        activity.moveTaskToBack(nonRoot);
        break;
      default:
        result.notImplemented();
    }
  }
}

package com.sewerganger.pure_manager.tools.glide;

import android.app.Activity;
import io.flutter.plugin.common.MethodChannel;

public class Reply {
  private boolean isSending = false;
  Activity activity;
  MethodChannel.Result result;

  public Reply(Activity activity, MethodChannel.Result result) {
    this.activity = activity;
    this.result = result;
  }

  public void send(Object val) {
    if (isSending) {
      return;
    }
    isSending = true;
    activity.runOnUiThread(() -> {
      result.success(val);
    });
  }
}

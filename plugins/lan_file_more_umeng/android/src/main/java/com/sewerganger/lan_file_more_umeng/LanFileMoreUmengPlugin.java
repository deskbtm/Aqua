package com.sewerganger.lan_file_more_umeng;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * LanFileMoreUmengPlugin
 */
public class LanFileMoreUmengPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity activity;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "lan_file_more_umeng");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "init":
        init(call, result);
        break;
      case "event":
        event(call, result);
        break;
      case "beginLogPageView":
        beginLogPageView(call, result);
        break;
      case "endLogPageView":
        endLogPageView(call, result);
        break;
      case "onResume":
        onResumeActivity(call, result);
        break;
      case "onPause":
        onPauseActivity(call, result);
        break;
      case "reportError":
        reportError(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void init(MethodCall call, Result result) {
    boolean enableLog = call.argument("enableLog");
    boolean enableReportError = call.argument("enableReportError");
    boolean encrypt = (boolean) call.argument("encrypt");
    String channel = call.argument("channel");


    if (channel == null) {
      channel = getChannel(activity);
    }

    UMConfigure.setLogEnabled(enableLog);

    UMConfigure.init(activity, (String) call.argument("appKey"), channel, UMConfigure.DEVICE_TYPE_PHONE, null);

    UMConfigure.setEncryptEnabled(encrypt);

    MobclickAgent.openActivityDurationTrack(false);

    MobclickAgent.setCatchUncaughtExceptions(enableReportError);

    result.success(true);

  }


  public static String getChannel(Context context) {
    try {
      ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
      String channel = appInfo.metaData.getString("UMENG_CHANNEL");
      return channel;
    } catch (PackageManager.NameNotFoundException e) {

    }
    return null;
  }

  public void event(MethodCall call, Result result) {

    if (call.hasArgument("label")) {
      String label = (String) call.argument("label");
      MobclickAgent.onEvent(activity, (String) call.argument("eventId"), label);

    } else {
      MobclickAgent.onEvent(activity, (String) call.argument("eventId"));
    }

    result.success(true);
  }

  public void beginLogPageView(MethodCall call, Result result) {

    MobclickAgent.onPageStart((String) call.argument("pageName"));

    result.success(true);

  }

  public void endLogPageView(MethodCall call, Result result) {

    MobclickAgent.onPageEnd((String) call.argument("pageName"));

    result.success(true);

  }

  public void onResumeActivity(MethodCall call, Result result) {

    MobclickAgent.onPause(activity);

    result.success(true);

  }

  public void onPauseActivity(MethodCall call, Result result) {

    MobclickAgent.onPause(activity);

    result.success(true);

  }

  public void reportError(MethodCall call, Result result) {
    String error = call.argument("error");

    MobclickAgent.reportError(context, error);
    result.success(true);
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
    activity = null;
  }
}

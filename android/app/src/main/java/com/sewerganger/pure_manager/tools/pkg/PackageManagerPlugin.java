package com.sewerganger.pure_manager.tools.pkg;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * GlidePlugin
 */
public class PackageManagerPlugin implements FlutterPlugin, MethodCallHandler {

  private MethodChannel channel;
  private Context context;
  private String CHANNEL_NAME = "aqua_pkg_mgmt";
  private PackageMgmt packageMgmt;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    packageMgmt = new PackageMgmt(context);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    switch (call.method) {
      case "getApkInfo":
        final String path = call.argument("path");
        result.success(packageMgmt.getApkInfo(path));
        break;
      case "getPackageInfoByName":
        final String packageName = call.argument("packageName");
        try {
          result.success(packageMgmt.getPackageInfoByName(packageName));
        } catch (PackageManager.NameNotFoundException e) {
          e.printStackTrace();
        }
        break;
      case "getPackageIconByName":
        final String packageName1 = call.argument("packageName");
        try {
          result.success(packageMgmt.getPackageIconByName(packageName1));
        } catch (PackageManager.NameNotFoundException e) {
          e.printStackTrace();
        }
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    packageMgmt = null;
  }
}

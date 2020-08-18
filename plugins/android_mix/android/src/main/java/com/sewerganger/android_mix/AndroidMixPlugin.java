package com.sewerganger.android_mix;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.enums.CompressionMethod;

import java.io.IOException;
import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AndroidMixPlugin
 */
public class AndroidMixPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private Context context;
  private MethodChannel channel;
  private Storage storage;
  private Archive archive;
  private Activity activity;

  public AndroidMixPlugin() {
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    AndroidMixPlugin instance = new AndroidMixPlugin();
    instance.channel = new MethodChannel(registrar.messenger(), "android_mix");
    instance.context = registrar.context();
    instance.channel.setMethodCallHandler(instance);
    new Archive(instance.channel);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "android_mix");
    context = flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
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

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    storage = new Storage(context);
    archive = new Archive(channel);
    switch (call.method) {
      case "getTemporaryDirectory":
        result.success(storage.getTemporaryDirectory());
        break;
      case "getApplicationDocumentsDirectory":
        result.success(storage.getApplicationDocumentsDirectory());
        break;
      case "getStorageDirectory":
        result.success(storage.getStorageDirectory());
        break;
      case "getExternalCacheDirectories":
        result.success(storage.getExternalCacheDirectories());
        break;
      case "getExternalStorageDirectories":
        final Integer type = call.argument("type");
        final String directoryName = StorageDirectoryMapper.androidType(type);
        result.success(storage.getExternalStorageDirectories(directoryName));
        break;
      case "getApplicationSupportDirectory":
        result.success(storage.getApplicationSupportDirectory());
        break;
      case "getExternalStorageDirectory":
        result.success(storage.getExternalStorageDirectory());
        break;
      case "getFilesDir":
        result.success(storage.getFilesDir());
        break;
      case "getCacheDir":
        result.success(storage.getCacheDir());
        break;
      case "getDataDirectory":
        result.success(storage.getDataDirectory());
        break;
      case "getExternalCacheDir":
        result.success(storage.getExternalCacheDir());
        break;
      case "getApkInfo":
        final String path = call.argument("path");
        result.success(storage.getApkInfo(path));
        break;
      case "getTotalExternalStorageSize":
        result.success(storage.getTotalExternalStorageSize());
        break;
      case "getValidExternalStorageSize":
        result.success(storage.getValidExternalStorageSize());
        break;
      //archive
      case "zip":
        final ArrayList<String> paths = call.argument("paths");
        final String targetPath = call.argument("targetPath");
        final int level = call.argument("level");
        final int method = call.argument("method");
        final int encrypt = call.argument("encrypt");
        final String pwd = call.argument("pwd");

        new Thread(new Runnable() {
          @Override
          public void run() {
            final boolean r = archive.zip(paths, targetPath, CompressMapper.level(level), CompressMapper.method(method), CompressMapper.encrypt(encrypt), pwd);
            activity.runOnUiThread(new Runnable() {
              @Override
              public void run() {
                result.success(r);
              }
            });
          }
        }).start();
        break;
      case "unzip":
        final String path2 = call.argument("path");
        final String targetPath2 = call.argument("targetPath");
        final String pwd2 = call.argument("pwd");
        new Thread(new Runnable() {
          @Override
          public void run() {
            final boolean r = archive.unzip(path2, targetPath2, pwd2);
            activity.runOnUiThread(new Runnable() {
              @Override
              public void run() {
                result.success(r);
              }
            });
          }
        }).start();

        break;
      case "isZipEncrypted":
        final String path3 = call.argument("path");
        try {
          result.success(archive.isZipEncrypted(path3));
        } catch (ZipException e) {
          e.printStackTrace();
        }
        break;
      case "isValidZipFile":
        final String path4 = call.argument("path");
        result.success(archive.isValidZipFile(path4));
        break;
//      case "tar":
//        final ArrayList<String> path3 = call.argument("path");
//        final String targetPath3 = call.argument("targetPath");
//        try {
//          archive.tar(path3, targetPath3);
//        } catch (IOException e) {
//          e.printStackTrace();
//        }
//        break;
      default:
        result.notImplemented();
    }
  }


}


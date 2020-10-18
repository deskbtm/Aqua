package com.sewerganger.android_mix_recorder;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.projection.MediaProjectionManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AndroidMixRecorderPlugin
 */
public class AndroidMixRecorderPlugin implements FlutterPlugin,
  MethodCallHandler,
  PluginRegistry.ActivityResultListener,
  HBRecorderListener,
  ActivityAware {

  private static final int RECORD_REQUEST_CODE = 201;
  private static final int PERMISSION_REQ_ID_RECORD_AUDIO = 22;
  private static final int SCREEN_RECORD_REQUEST_CODE = 777;


  private MethodChannel channel;
  private Activity activity;
  private Context context;
  private boolean hasPermissions = false;
  private HBRecorder hbRecorder;


  private void prepareToRecord() {
    MediaProjectionManager projectionManager = (MediaProjectionManager) context.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
    Intent captureIntent = projectionManager.createScreenCaptureIntent();
    activity.startActivityForResult(captureIntent, RECORD_REQUEST_CODE);

    if (checkSelfPermission(Manifest.permission.RECORD_AUDIO, PERMISSION_REQ_ID_RECORD_AUDIO)) {
      hasPermissions = true;
    }

    if (hasPermissions) {
      startScreenRecord();
    }
  }

  private void startScreenRecord() {
    hbRecorder.enableCustomSettings();
//    customSettings();
    MediaProjectionManager mediaProjectionManager = (MediaProjectionManager) context.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
    Intent permissionIntent = mediaProjectionManager != null ? mediaProjectionManager.createScreenCaptureIntent() : null;
    activity.startActivityForResult(permissionIntent, SCREEN_RECORD_REQUEST_CODE);

//    if (checkSelfPermission(Manifest.permission.RECORD_AUDIO, PERMISSION_REQ_ID_RECORD_AUDIO)) {
//      hasPermissions = true;
//    }
//    if (hasPermissions) {
//      if (hbRecorder.isBusyRecording()) {
//        hbRecorder.stopScreenRecording();
//
//      }
//      //else start recording
//      else {
//        startScreenRecord();
//      }
//    }
  }

  private boolean checkSelfPermission(String permission, int requestCode) {
    if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
      ActivityCompat.requestPermissions(activity, new String[]{permission}, requestCode);
      return false;
    }
    return true;
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      if (requestCode == SCREEN_RECORD_REQUEST_CODE) {
        if (resultCode == activity.RESULT_OK) {
          //Set file path or Uri depending on SDK version
          setOutputPath();
          //Start screen recording
          hbRecorder.startScreenRecording(data, resultCode, activity);
          return true;
        }
      }
    }
    return false;
  }

  private String generateFileName() {
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss", Locale.getDefault());
    Date curDate = new Date(System.currentTimeMillis());
    return formatter.format(curDate).replace(" ", "");
  }

  ContentResolver resolver;
  ContentValues contentValues;
  Uri mUri;

  private void createFolder() {
    File f1 = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES), "HBRecorder");
    if (!f1.exists()) {
      if (f1.mkdirs()) {
        Log.i("Folder ", "created");
      }
    }
  }

  private void setOutputPath() {
    String filename = generateFileName();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      resolver = context.getContentResolver();
      contentValues = new ContentValues();
      contentValues.put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/" + "HBRecorder");
      contentValues.put(MediaStore.Video.Media.TITLE, filename);
      contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, filename);
      contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4");
      mUri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues);
      //FILE NAME SHOULD BE THE SAME
      hbRecorder.setFileName(filename);
      hbRecorder.setOutputUri(mUri);
    } else {
      createFolder();
      hbRecorder.setOutputPath(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES) + "/HBRecorder");
    }
  }


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "android_mix_recorder");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
    hbRecorder = new HBRecorder(context, this);
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
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "android_mix_recorder");
    channel.setMethodCallHandler(new AndroidMixRecorderPlugin());
  }


  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "startRecord":

        break;
      case "pauseRecord":
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          hbRecorder.pauseScreenRecording();
        }
        break;
      case "stopRecord":
        hbRecorder.stopScreenRecording();
        break;
      default:
        result.notImplemented();
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void HBRecorderOnStart() {

  }

  @Override
  public void HBRecorderOnComplete() {

  }

  @Override
  public void HBRecorderOnError(int errorCode, String reason) {

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
}

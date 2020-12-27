package com.sewerganger.screen_capturer;

import android.Manifest;
import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.MediaCodec;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.IBinder;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_OK;
import static androidx.core.app.ActivityCompat.startActivityForResult;

/**
 * ScreenCapturerPlugin
 */
public class ScreenCapturerPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware, PluginRegistry.ActivityResultListener {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel methodChannel;
  private EventChannel eventChannel;


  private Context context;
  private MediaProjectionManager mMediaProjectionManager;
  private int CAP_REQUEST_CODE = 4000;
  private Activity mActivity;
  private VirtualDisplay mVirtualDisplay;
  private MediaProjection mMediaProjection;
  private ScreenCapturerService.VideoBinder mBinder;


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();

    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
      "screen_capturer_method");

    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),
      "screen_capturer_event");

    methodChannel.setMethodCallHandler(this);
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    methodChannel.setMethodCallHandler(null);

  }


  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {

  }

  @Override
  public void onCancel(Object arguments) {

  }


  private void requestScreenCapture() {
    mMediaProjectionManager = (MediaProjectionManager) context.getSystemService(Context.MEDIA_PROJECTION_SERVICE);
    Intent captureIntent = null;
    if (mMediaProjectionManager != null) {
      captureIntent = mMediaProjectionManager.createScreenCaptureIntent();
    }
    mActivity.startActivityForResult(captureIntent, CAP_REQUEST_CODE);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    mActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    if (!mActivity.isDestroyed()) {
      mActivity.finish();
      mActivity = null;
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }


//  private void createVirtualDisplay() {
//    Surface surface = MediaCodec.createInputSurface();
//    //实例化VirtualDisplay,这个类的主要作用是用来获取屏幕信息并保存在里。
//    mediaProjection.createVirtualDisplay("ScreenRecord",
//      width, height, 1, DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, surface,
//      null, null);
//  }


  private ServiceConnection mSc = new ServiceConnection() {
    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
      mBinder = (ScreenCapturerService.VideoBinder) service;
      mBinder.getService().setCallBack(new ScreenCapturerService.CallBack() {
        @Override
        public void getServiceData(String data) {

        }
      });
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {

    }
  };

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {

    if (requestCode == CAP_REQUEST_CODE) {
      if (resultCode == RESULT_OK) {
        Intent service = new Intent(context, ScreenCapturerService.class);
        mActivity.bindService(service, mSc, Context.BIND_AUTO_CREATE);
        mActivity.startService(service);
      }
    }
    return false;
  }
}

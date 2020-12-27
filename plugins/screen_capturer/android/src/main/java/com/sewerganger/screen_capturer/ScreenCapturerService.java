package com.sewerganger.screen_capturer;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.MediaRecorder;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Binder;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ScreenCapturerService extends Service {
  private static final String TAG = "ScreenRecordingService";
  private int mScreenWidth;
  private int mScreenHeight;
  private int mScreenDensity;
  private int mResultCode;
  private Intent mResultData;
  /**
   * 是否为标清视频
   */
  private boolean isVideoSd;
  /**
   * 是否开启音频录制
   */
  private boolean isAudio;
  private MediaProjection mMediaProjection;
  private MediaRecorder mMediaRecorder;
  private VirtualDisplay mVirtualDisplay;

  @Override
  public void onCreate() {
// TODO Auto-generated method stub
    super.onCreate();
    Log.i(TAG, "Service onCreate() is called");
  }

  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
// TODO Auto-generated method stub
    Log.i(TAG, "Service onStartCommand() is called");
    mResultCode = intent.getIntExtra("code", -1);
    mResultData = intent.getParcelableExtra("data");
    mScreenWidth = intent.getIntExtra("width", 1920);
    mScreenHeight = intent.getIntExtra("height", 1080);
    mScreenDensity = intent.getIntExtra("density", 1);
    isVideoSd = intent.getBooleanExtra("quality", true);
    isAudio = intent.getBooleanExtra("audio", true);
    mMediaProjection = createMediaProjection();
    mMediaRecorder = createMediaRecorder();
    mVirtualDisplay = createVirtualDisplay(); // 必须在mediaRecorder.prepare() 之后调用，否则报错"fail to get surface"
    mMediaRecorder.start();
    return Service.START_NOT_STICKY;
  }

  private MediaProjection createMediaProjection() {
    Log.i(TAG, "Create MediaProjection");
    return ((MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE)).getMediaProjection(mResultCode, mResultData);
  }

  private MediaRecorder createMediaRecorder() {
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
    Date curDate = new Date(System.currentTimeMillis());
    String curTime = formatter.format(curDate).replace(" ", "");
    String videoQuality = "HD";
    if (isVideoSd) videoQuality = "SD";
    Log.i(TAG, "Create MediaRecorder");
    MediaRecorder mediaRecorder = new MediaRecorder();
//  if(isAudio) mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
    mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP);
    mediaRecorder.setOutputFile(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES) + "/" + videoQuality + curTime + ".mp4");
    mediaRecorder.setVideoSize(mScreenWidth, mScreenHeight); //after setVideoSource(), setOutFormat()
    mediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264); //after setOutputFormat()
//  if(isAudio) mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC); //after setOutputFormat()
    int bitRate;
    if (isVideoSd) {
      mediaRecorder.setVideoEncodingBitRate(mScreenWidth * mScreenHeight);
      mediaRecorder.setVideoFrameRate(30);
      bitRate = mScreenWidth * mScreenHeight / 1000;
    } else {
      mediaRecorder.setVideoEncodingBitRate(5 * mScreenWidth * mScreenHeight);
      mediaRecorder.setVideoFrameRate(60); //after setVideoSource(), setOutFormat()
      bitRate = 5 * mScreenWidth * mScreenHeight / 1000;
    }
    try {
      mediaRecorder.prepare();
    } catch (IllegalStateException | IOException e) {
      e.printStackTrace();
    }
    Log.i(TAG, "Audio: " + isAudio + ", SD video: " + isVideoSd + ", BitRate: " + bitRate + "kbps");
    return mediaRecorder;
  }

  private VirtualDisplay createVirtualDisplay() {
    Log.i(TAG, "Create VirtualDisplay");
    return mMediaProjection.createVirtualDisplay(TAG, mScreenWidth, mScreenHeight, mScreenDensity,
      DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR, mMediaRecorder.getSurface(), null, null);
  }

  @Override
  public void onDestroy() {
// TODO Auto-generated method stub
    super.onDestroy();
    Log.i(TAG, "Service onDestroy");
    if (mVirtualDisplay != null) {
      mVirtualDisplay.release();
      mVirtualDisplay = null;
    }
    if (mMediaRecorder != null) {
      mMediaRecorder.setOnErrorListener(null);
      mMediaProjection.stop();
      mMediaRecorder.reset();
    }
    if (mMediaProjection != null) {
      mMediaProjection.stop();
      mMediaProjection = null;
    }
  }

  public class VideoBinder extends Binder {
    public ScreenCapturerService getService() {
      return ScreenCapturerService.this;
    }
  }

  public interface CallBack {
    void getServiceData(String data);
  }

  private CallBack callBack = null;

  public void setCallBack(CallBack callBack) {
    this.callBack = callBack;
  }

  public CallBack getCallBack() {
    return callBack;
  }

  @Override
  public IBinder onBind(Intent intent) {
    return new VideoBinder();
  }
}
// package com.sewerganger.android_mix.media;

// import android.content.Context;
// import android.content.res.Resources;
// import android.hardware.display.DisplayManager;
// import android.hardware.display.VirtualDisplay;
// import android.media.projection.MediaProjection;
// import android.os.Build;
// import android.util.DisplayMetrics;
// import android.view.Surface;
// import android.view.WindowManager;

// public class ScreenCapture extends Thread {

//   private final static String TAG = "ScreenRecord";

//   private Surface surface;
//   private Context context;
//   private VirtualDisplay virtualDisplay;
//   private MediaProjection mediaProjection;

//   private VideoCodec videoCodec;

//   public ScreenCapture(Context context, MediaProjection mp) {
//     this.context = context;
//     this.mediaProjection = mp;
//     videoCodec = new VideoCodec();
//   }

//   @Override
//   public void run() {
//     videoCodec.prepare();
//     surface = videoCodec.getSurface();
//     Resources resources  = context.getResources();
//     DisplayMetrics dm = resources.getDisplayMetrics();

//     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//       virtualDisplay = mediaProjection.createVirtualDisplay(TAG + "-display", dm.widthPixels, dm.heightPixels, Constant.VIDEO_DPI, DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
//         surface, null, null);
//     }
//     videoCodec.isRun(true);
//     videoCodec.getBuffer();
//   }

//   public void release() {
//     videoCodec.release();
//   }

// }

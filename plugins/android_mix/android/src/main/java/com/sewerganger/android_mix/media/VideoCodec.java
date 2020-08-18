// package com.sewerganger.android_mix.media;


// import android.media.MediaCodec;
// import android.media.MediaCodecInfo;
// import android.media.MediaFormat;
// import android.os.Environment;
// import android.view.Surface;

// import java.io.BufferedOutputStream;
// import java.io.File;
// import java.io.FileOutputStream;
// import java.io.IOException;
// import java.nio.ByteBuffer;


// /**
//  * Created by zpf on 2018/3/7.
//  */

// class Constant {

//     public static final String MIME_TYPE = "video/avc";

//     public static final int VIDEO_WIDTH = 1280;

//     public static final int VIDEO_HEIGHT = 720;

//     public static final int VIDEO_DPI = 1;

//     public static final int VIDEO_BITRATE = 500000;

//     public static final int VIDEO_FRAMERATE = 15;

//     public static final int VIDEO_IFRAME_INTER = 5;

// }



// public class VideoCodec extends VideoCodecBasic {
//   private final static String TAG = "VideoMediaCodec";


//   private Surface mSurface;
//   private long startTime = 0;
//   private int TIMEOUT_USEC = 12000;
//   public byte[] configByte;

//   private static String path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/test1.h264";
//   private BufferedOutputStream outputStream;
//   FileOutputStream outStream;

//   private void createfile() {
//     File file = new File(path);
//     if (file.exists()) {
//       file.delete();
//     }
//     try {
//       outputStream = new BufferedOutputStream(new FileOutputStream(file));
//     } catch (Exception e) {
//       e.printStackTrace();
//     }
//   }

//   /**
//    *
//    **/
//   public VideoCodec() {
//     prepare();
//   }

//   public Surface getSurface() {
//     return mSurface;
//   }

//   public void isRun(boolean isR) {
//     this.isRun = isR;
//   }


//   @Override
//   public void prepare() {
//     try {
//       MediaFormat format = MediaFormat.createVideoFormat(Constant.MIME_TYPE, Constant.VIDEO_WIDTH, Constant.VIDEO_HEIGHT);
//       format.setInteger(MediaFormat.KEY_COLOR_FORMAT,
//         MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface);
//       format.setInteger(MediaFormat.KEY_BIT_RATE, Constant.VIDEO_BITRATE);
//       format.setInteger(MediaFormat.KEY_FRAME_RATE, Constant.VIDEO_FRAMERATE);
//       format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, Constant.VIDEO_IFRAME_INTER);
//       mEncoder = MediaCodec.createEncoderByType(Constant.MIME_TYPE);
//       mEncoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE);
//       mSurface = mEncoder.createInputSurface();
//       mEncoder.start();
//     } catch (IOException e) {

//     }
//   }

//   @Override
//   public void release() {
//     this.isRun = false;
//   }

//   /**
//    * 获取h264数据
//    **/
//   public void getBuffer() {
//     try {
//       while (isRun) {
//         if (mEncoder == null)
//           break;

//         MediaCodec.BufferInfo mBufferInfo = new MediaCodec.BufferInfo();
//         int outputBufferIndex = mEncoder.dequeueOutputBuffer(mBufferInfo, TIMEOUT_USEC);
//         while (outputBufferIndex >= 0) {
//           ByteBuffer outputBuffer = mEncoder.getOutputBuffers()[outputBufferIndex];
//           byte[] outData = new byte[mBufferInfo.size];
//           outputBuffer.get(outData);
//           if (mBufferInfo.flags == 2) {
//             configByte = new byte[mBufferInfo.size];
//             configByte = outData;
//           }
// //                    else{
// //                        MainActivity.putData(outData,2,mBufferInfo.presentationTimeUs*1000L);
// //                    }

//           else if (mBufferInfo.flags == 1) {
//             byte[] keyframe = new byte[mBufferInfo.size + configByte.length];
//             System.arraycopy(configByte, 0, keyframe, 0, configByte.length);
//             System.arraycopy(outData, 0, keyframe, configByte.length, outData.length);
// //            MainActivity.putData(keyframe, 1, mBufferInfo.presentationTimeUs * 1000L);
// //                        if(outputStream != null){
// //                            outputStream.write(keyframe, 0, keyframe.length);
// //                        }
//           } else {
// //            MainActivity.putData(outData, 2, mBufferInfo.presentationTimeUs * 1000L);
// //                        if(outputStream != null){
// //                            outputStream.write(outData, 0, outData.length);
// //                        }
//           }
//           mEncoder.releaseOutputBuffer(outputBufferIndex, false);
//           outputBufferIndex = mEncoder.dequeueOutputBuffer(mBufferInfo, TIMEOUT_USEC);
//         }
//       }
//     } catch (Exception e) {

//     }
//     try {
//       mEncoder.stop();
//       mEncoder.release();
//       mEncoder = null;
//     } catch (Exception e) {
//       e.printStackTrace();
//     }
//   }
// }

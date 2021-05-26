package com.sewerganger.pure_manager.tools.glide;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.transition.Transition;

import java.io.ByteArrayOutputStream;
import java.io.File;

import io.flutter.plugin.common.MethodChannel;

public class GlideHandler {
  Activity activity;
  MethodChannel.Result result;
  Context context;

  public GlideHandler(Context ctx, Activity act, MethodChannel.Result res) {
    this.context = ctx;
    this.activity = act;
    this.result = res;
  }

  public void getLocalThumbnail(String path, Integer width, Integer height, int format, int quality/*, DiskCacheStrategy diskCacheStrategy, boolean onlyRetrieveFromCache*/) {
    Reply reply = new Reply(activity, result);
    new Thread(() -> {

      Glide.with(context).asBitmap().load(new File(path)).into(new BitmapTarget(width, height) {
        @Override
        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
          super.onResourceReady(resource, transition);
          ByteArrayOutputStream bos = new ByteArrayOutputStream();
          Bitmap.CompressFormat compressFormat = format == 1 ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG;
          resource.compress(compressFormat, quality, bos);
          reply.send(bos.toByteArray());
        }

        @Override
        public void onLoadCleared(@Nullable Drawable placeholder) {
          reply.send(null);
        }

        @Override
        public void onLoadFailed(@Nullable Drawable errorDrawable) {
          super.onLoadFailed(errorDrawable);
          reply.send(null);
        }
      });
    }).start();
  }

  public void getLocalThumbnail(String path, int format, int quality) {
    Reply reply = new Reply(activity, result);
    new Thread(() -> {
      Glide.with(context).asBitmap().load(new File(path)).into(new BitmapTarget() {
        @Override
        public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
          super.onResourceReady(resource, transition);
          ByteArrayOutputStream bos = new ByteArrayOutputStream();
          Bitmap.CompressFormat compressFormat = format == 1 ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG;
          resource.compress(compressFormat, quality, bos);
          reply.send(bos.toByteArray());
        }

        @Override
        public void onLoadCleared(@Nullable Drawable placeholder) {
          reply.send(null);
        }

        @Override
        public void onLoadFailed(@Nullable Drawable errorDrawable) {
          super.onLoadFailed(errorDrawable);
          reply.send(null);
        }
      });
    }).start();
  }
}
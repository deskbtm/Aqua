package com.sewerganger.flutter_glide.utils;

import android.graphics.Bitmap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

public abstract class BitmapTarget extends CustomTarget<Bitmap> {

  private Bitmap bitmap = null;

  public BitmapTarget(@NonNull int width,@NonNull int height){
    super(width, height);
  }

  @Override
  public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
    bitmap = resource;
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    if(!bitmap.isRecycled()){
      bitmap.recycle();
    }
  }
}

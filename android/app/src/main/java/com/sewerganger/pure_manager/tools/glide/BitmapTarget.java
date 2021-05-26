package com.sewerganger.pure_manager.tools.glide;

import android.graphics.Bitmap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;

abstract class BitmapTarget extends CustomTarget<Bitmap> {
  private Bitmap bitmap;


  public BitmapTarget(Integer width, Integer height) {
    super(width, height);
  }

  public BitmapTarget() {
    super();
  }

  @Override
  public void onResourceReady(@NonNull Bitmap resource, @Nullable Transition<? super Bitmap> transition) {
    bitmap = resource;
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    if (!bitmap.isRecycled()) {
      bitmap.recycle();
    }
  }
}

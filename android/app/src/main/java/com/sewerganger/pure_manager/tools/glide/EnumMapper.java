package com.sewerganger.pure_manager.tools.glide;


import com.bumptech.glide.load.engine.DiskCacheStrategy;

public class EnumMapper {
  static DiskCacheStrategy cacheStrategy(int type) {
    DiskCacheStrategy strategy;
    switch (type) {
      case 0:
        strategy = DiskCacheStrategy.ALL;
        break;
      case 1:
        strategy = DiskCacheStrategy.NONE;
        break;
      case 2:
        strategy = DiskCacheStrategy.DATA;
        break;
      case 3:
        strategy = DiskCacheStrategy.RESOURCE;
        break;
      default:
        strategy = DiskCacheStrategy.AUTOMATIC;
    }
    return strategy;
  }
}

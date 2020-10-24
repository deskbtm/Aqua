package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.sewerganger.android_broadcast.AndroidBroadcastPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    AndroidBroadcastPlugin.registerWith(registry.registrarFor("com.sewerganger.android_broadcast.AndroidBroadcastPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}

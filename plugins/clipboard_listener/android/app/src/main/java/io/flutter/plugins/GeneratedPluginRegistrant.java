package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import top.huic.clipboard_listener.ClipboardListenerPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    ClipboardListenerPlugin.registerWith(registry.registrarFor("top.huic.clipboard_listener.ClipboardListenerPlugin"));
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

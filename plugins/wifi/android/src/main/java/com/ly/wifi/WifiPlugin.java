package com.ly.wifi;

import android.content.Context;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.wifi.WifiManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class WifiPlugin implements MethodCallHandler {
  private final Registrar registrar;
  private WifiDelegate delegate;

  private WifiPlugin(Registrar registrar, WifiDelegate delegate) {
    this.registrar = registrar;
    this.delegate = delegate;
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "plugins.ly.com/wifi");
    WifiManager wifiManager = (WifiManager) registrar.activeContext().getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    final WifiDelegate delegate = new WifiDelegate(registrar.activity(), wifiManager);
    registrar.addRequestPermissionsResultListener(delegate);

    // support Android O,listen network disconnect event
    // https://stackoverflow.com/questions/50462987/android-o-wifimanager-enablenetwork-cannot-work
    IntentFilter filter = new IntentFilter();
    filter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);
    filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
    registrar
      .context()
      .registerReceiver(delegate.networkReceiver, filter);

    channel.setMethodCallHandler(new WifiPlugin(registrar, delegate));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (registrar.activity() == null) {
      result.error("no_activity", "wifi plugin requires a foreground activity.", null);
      return;
    }
    switch (call.method) {
      case "ssid":
        delegate.getSSID(call, result);
        break;
      case "level":
        delegate.getLevel(call, result);
        break;
      case "ip":
        delegate.getIP(call, result);
        break;
      case "list":
        delegate.getWifiList(call, result);
        break;
      case "connection":
        delegate.connection(call, result);
        break;
      case "isConnected":
        delegate.isConnected(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

}

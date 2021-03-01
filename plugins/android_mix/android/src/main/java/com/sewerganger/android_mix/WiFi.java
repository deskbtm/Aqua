// package com.sewerganger.android_mix;

// import android.app.Activity;
// import android.content.Context;
// import android.net.ConnectivityManager;
// import android.net.NetworkInfo;
// import android.net.wifi.WifiInfo;
// import android.net.wifi.WifiManager;

// import java.net.Inet4Address;
// import java.net.InetAddress;
// import java.net.NetworkInterface;
// import java.net.SocketException;
// import java.util.Enumeration;

// import io.flutter.plugin.common.MethodCall;
// import io.flutter.plugin.common.MethodChannel;

// public class WiFi {
//   private Context context;
//   private Activity activity;
//   private WifiManager wifiManager;

//   @Override
//   protected void finalize() throws Throwable {
//     super.finalize();
//     activity = null;
//     wifiManager = null;
//     context = null;
//   }

//   public WiFi(Context c, Activity a) {
//     context = c;
//     activity = a;
//     wifiManager = (WifiManager) context.getApplicationContext().getSystemService(Context.WIFI_SERVICE);
//   }


//   private static String intIP2StringIP(int ip) {
//     return (ip & 0xFF) + "." +
//       ((ip >> 8) & 0xFF) + "." +
//       ((ip >> 16) & 0xFF) + "." +
//       (ip >> 24 & 0xFF);
//   }

//   public boolean isConnected() {
//     NetworkInfo info = ((ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE)).getActiveNetworkInfo();
//     if (info != null && info.isConnected()) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   public String getIp() throws Exception {
//     NetworkInfo info = ((ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE)).getActiveNetworkInfo();
//     if (info != null && info.isConnected()) {
//       if (info.getType() == ConnectivityManager.TYPE_MOBILE) {
//         try {
//           for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
//             NetworkInterface intf = en.nextElement();
//             for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
//               InetAddress inetAddress = enumIpAddr.nextElement();
//               if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
//                 return inetAddress.getHostAddress();
//               }
//             }
//           }
//         } catch (SocketException e) {
//           throw e;
//         }
//       } else if (info.getType() == ConnectivityManager.TYPE_WIFI) {
//         WifiInfo wifiInfo = wifiManager.getConnectionInfo();
//         return intIP2StringIP(wifiInfo.getIpAddress());
//       }
//     } else {
//       throw new Exception("wifi unavailable");
//     }
//     return null;
//   }
// }

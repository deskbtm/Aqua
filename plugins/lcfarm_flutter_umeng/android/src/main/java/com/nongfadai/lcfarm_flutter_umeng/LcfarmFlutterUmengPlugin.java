package com.nongfadai.lcfarm_flutter_umeng;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.text.TextUtils;

import com.umeng.analytics.MobclickAgent;
import com.umeng.commonsdk.UMConfigure;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** LcfarmFlutterUmengPlugin */
public class LcfarmFlutterUmengPlugin implements MethodCallHandler {

    private Activity activity;

    /** Plugin registration. */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "lcfarm_flutter_umeng");
        channel.setMethodCallHandler(new LcfarmFlutterUmengPlugin(registrar.activity()));
    }

    private LcfarmFlutterUmengPlugin(Activity activity) {
        this.activity = activity;
    }


    public static String getChannel(Context context) {
        try {
            ApplicationInfo appInfo = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            String channel = appInfo.metaData.getString("UMENG_CHANNEL");
            return channel;
        } catch (PackageManager.NameNotFoundException e) {

        }
        return null;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals("init")){
            init(call,result);
        }else if (call.method.equals("event")){
            event(call, result);
        }else if (call.method.equals("beginLogPageView")){
            beginLogPageView(call, result);
        }else if (call.method.equals("endLogPageView")){
            endLogPageView(call, result);
        }else if (call.method.equals("onResume")){
            onResumeActivity(call, result);
        }else if (call.method.equals("onPause")){
            onPauseActivity(call, result);
        }

        else {
            result.notImplemented();
        }
    }


    public void init(MethodCall call, Result result){

        boolean logEnable = false;
        if(call.hasArgument("logEnable")){
            logEnable = (boolean)call.argument("logEnable");
        }

        UMConfigure.setLogEnabled(logEnable);

        if(call.hasArgument("channel")){
            String channel = (String) call.argument("channel");
            UMConfigure.init(activity, (String) call.argument("appKey"), channel, UMConfigure.DEVICE_TYPE_PHONE, null);
        }else {

            String channel = getChannel(activity);
            UMConfigure.init(activity, (String) call.argument("appKey"), channel, UMConfigure.DEVICE_TYPE_PHONE, null);
        }

        boolean encrypt = false;

        if(call.hasArgument("encrypt")){
            encrypt = (boolean)call.argument("encrypt");
        }

        UMConfigure.setEncryptEnabled(encrypt);

        MobclickAgent.openActivityDurationTrack(false);

        result.success(true);

    }

    public  void event(MethodCall call, Result result) {

        if (call.hasArgument("label")){
            String label = (String) call.argument("label");
            MobclickAgent.onEvent(activity,(String) call.argument("eventId"),label);

        }else {
            MobclickAgent.onEvent(activity, (String) call.argument("eventId"));
        }

        result.success(true);
    }

    public  void beginLogPageView(MethodCall call, Result result) {

        MobclickAgent.onPageStart((String) call.argument("pageName"));

        result.success(true);

    }

    public  void endLogPageView(MethodCall call, Result result) {

        MobclickAgent.onPageEnd((String) call.argument("pageName"));

        result.success(true);

    }

    public  void onResumeActivity(MethodCall call, Result result) {

        MobclickAgent.onPause(activity);

        result.success(true);

    }

    public  void onPauseActivity(MethodCall call, Result result) {

        MobclickAgent.onPause(activity);

        result.success(true);

    }

}

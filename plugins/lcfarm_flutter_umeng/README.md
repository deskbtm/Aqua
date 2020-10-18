# lcfarm_flutter_umeng

A new flutter plugin project.

## Getting Started

android项目需要在MainActivity.java添加方法

```
public void onResume() {
  super.onResume();
  MobclickAgent.onResume(this);

}

public void onPause() {
  super.onPause();
  MobclickAgent.onPause(this);
}
```

当然记得引入

```
import com.umeng.analytics.MobclickAgent;
```

### android的获取权限

```
<manifest ...>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.INTERNET"/>
<application ...>
```

### android 多渠道

没有配置参数 channel . 则需要修改 Androidmanifest.xml 

修改${CHANNEL_NAME}

```
<manifest ...>

    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application ...>
        ...
        <meta-data
            android:name="UMENG_CHANNEL"
            android:value="${CHANNEL_NAME}" />
    </application>
</manifest>
```

使用了多渠道打包。需要修改app/build.gradle

```
manifestPlaceholders = [
  CHANNEL_NAME: "默认渠道名",
]
```
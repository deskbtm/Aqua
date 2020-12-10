package com.sewerganger.lan_file_more;
import com.umeng.analytics.MobclickAgent;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity  {
  @Override
  public void onResume() {
    super.onResume();
    MobclickAgent.onResume(this);
  }

  @Override
  public void onPause() {
    super.onPause();
    MobclickAgent.onPause(this);
  }
}

package top.huic.clipboard_listener

import android.content.ClipboardManager
import io.flutter.plugin.common.MethodChannel

/**
 * 自定义粘贴板改变监听
 * @author 蒋具宏
 */
class CustomOnPrimaryClipChangedListener : ClipboardManager.OnPrimaryClipChangedListener {

    /**
     * 方法管道
     */
    private var channel: MethodChannel

    /**
     * 监听器回调的方法名
     */
    private var listenerName: String = "onListener";

    constructor(channel: MethodChannel) {
        this.channel = channel
    }


    /**
     * 粘贴板改变事件
     */
    override fun onPrimaryClipChanged() {
        channel.invokeMethod(listenerName, null);
    }
}



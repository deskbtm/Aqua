package com.sewerganger.pure_manager;

import com.sewerganger.pure_manager.tools.archive.ArchivePlugin;
import com.sewerganger.pure_manager.tools.connectivity.ConnectivityPlugin;
import com.sewerganger.pure_manager.tools.fsExtra.FsExtraPlugin;
import com.sewerganger.pure_manager.tools.glide.GlidePlugin;

import io.flutter.embedding.engine.FlutterEngine;

public final class InnerPluginMgmt {
    public static void register(FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new ConnectivityPlugin());
        flutterEngine.getPlugins().add(new GlidePlugin());
        flutterEngine.getPlugins().add(new ArchivePlugin());
        flutterEngine.getPlugins().add(new FsExtraPlugin());
    }
}

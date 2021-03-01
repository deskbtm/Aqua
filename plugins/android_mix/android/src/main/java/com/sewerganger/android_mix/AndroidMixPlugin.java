package com.sewerganger.android_mix;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import net.lingala.zip4j.exception.ZipException;

import org.rauschig.jarchivelib.Archiver;
import org.rauschig.jarchivelib.ArchiverFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AndroidMixPlugin
 */
public class AndroidMixPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private Context context;
    private MethodChannel channel;
    private Storage storage;
    private Archive archive;
    private Activity activity;
    private MixPackageManager mixPackageManager;
    // private WiFi wifi;

    public AndroidMixPlugin() {
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        AndroidMixPlugin instance = new AndroidMixPlugin();
        instance.channel = new MethodChannel(registrar.messenger(), "android_mix");
        instance.context = registrar.context();
        instance.channel.setMethodCallHandler(instance);
        new Archive(instance.channel);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "android_mix");
        context = flutterPluginBinding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        channel = null;
        // wifi = null;
        archive = null;
        storage = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {
        if (!activity.isDestroyed()) {
            activity.finish();
        }
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
        storage = new Storage(context);
        archive = new Archive(channel);
        // wifi = new WiFi(context, activity);
        mixPackageManager = new MixPackageManager(context);

        if (MixActivity.includeMethods.contains(call.method)) {
            new MixActivity(context, activity, call, result);
        }

        switch (call.method) {
            case "getTemporaryDirectory":
                result.success(storage.getTemporaryDirectory());
                break;
            case "getApplicationDocumentsDirectory":
                result.success(storage.getApplicationDocumentsDirectory());
                break;
            case "getStorageDirectory":
                result.success(storage.getStorageDirectory());
                break;
            case "getExternalCacheDirectories":
                result.success(storage.getExternalCacheDirectories());
                break;
            case "getExternalStorageDirectories":
                final Integer type = call.argument("type");
                final String directoryName = StorageDirectoryMapper.androidType(type);
                result.success(storage.getExternalStorageDirectories(directoryName));
                break;
            case "getApplicationSupportDirectory":
                result.success(storage.getApplicationSupportDirectory());
                break;
            case "getExternalStorageDirectory":
                result.success(storage.getExternalStorageDirectory());
                break;
            case "getFilesDir":
                result.success(storage.getFilesDir());
                break;
            case "getCacheDir":
                result.success(storage.getCacheDir());
                break;
            case "getDataDirectory":
                result.success(storage.getDataDirectory());
                break;
            case "getExternalCacheDir":
                result.success(storage.getExternalCacheDir());
                break;
            case "getApkInfo":
                final String path = call.argument("path");
                result.success(mixPackageManager.getApkInfo(path));
                break;
            case "getPackageInfoByName":
                final String packageName = call.argument("packageName");
                try {
                    result.success(mixPackageManager.getPackageInfoByName(packageName));
                } catch (PackageManager.NameNotFoundException e) {
                    e.printStackTrace();
                }
                break;
            case "getPackageIconByName":
                final String packageName1 = call.argument("packageName");
                try {
                    result.success(mixPackageManager.getPackageIconByName(packageName1));
                } catch (PackageManager.NameNotFoundException e) {
                    e.printStackTrace();
                }
                break;
            case "getTotalExternalStorageSize":
                result.success(storage.getTotalExternalStorageSize());
                break;
            case "getValidExternalStorageSize":
                result.success(storage.getValidExternalStorageSize());
                break;
            //archive
            case "zip":
                final ArrayList<String> paths = call.argument("paths");
                final String targetPath = call.argument("targetPath");
                final int level = call.argument("level");
                final int method = call.argument("method");
                final int encrypt = call.argument("encrypt");
                final String pwd = call.argument("pwd");

                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        final boolean r = archive.zip(paths, targetPath, ArchiveMapper.level(level), ArchiveMapper.method(method), ArchiveMapper.encrypt(encrypt), pwd);
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                result.success(r);
                            }
                        });
                    }
                }).start();
                break;
            case "unzip":
                final String path2 = call.argument("path");
                final String targetPath2 = call.argument("targetPath");
                final String pwd2 = call.argument("pwd");
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        final boolean r = archive.unzip(path2, targetPath2, pwd2);
                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                result.success(r);
                            }
                        });
                    }
                }).start();

                break;
            case "isZipEncrypted":
                final String path3 = call.argument("path");
                try {
                    result.success(archive.isZipEncrypted(path3));
                } catch (ZipException e) {
                    e.printStackTrace();
                }
                break;
            case "isValidZipFile":
                final String path4 = call.argument("path");
                result.success(archive.isValidZipFile(path4));
                break;
            case "extractTarGz":
                final String tarPath = call.argument("source");
                final String destPath = call.argument("dest");
                final String linuxRootPath = call.argument("linuxRootPath");

                new Thread(new Runnable() {
                    @Override
                    public void run() {

                        try {
                            final ArrayList<ArrayList<String>> list = archive.extractTarGz(tarPath, destPath, linuxRootPath);
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(list);
                                }
                            });
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();

                break;
            case "createArchive": {
                final ArrayList<String> archivePaths = call.argument("paths");
                final String dest1 = call.argument("dest");
                final String archiveName = call.argument("archiveName");
                final int archiveFormat1 = call.argument("archiveFormat");
                final Integer compressionType1 = call.argument("compressionType");

                if (archivePaths == null) {
                    result.success(false);
                    return;
                }

                final File[] fileArr = new File[archivePaths.size()];
                final ArrayList tmpArr = new ArrayList<File>();

                for (String filePath : archivePaths) {
                    tmpArr.add(new File(filePath));
                }

                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        Archiver archiver;

                        if (compressionType1 == null) {
                            archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat1));
                        } else {
                            archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat1), ArchiveMapper.compressionType(compressionType1));
                        }
                        try {
                            archiver.create(archiveName, new File(dest1), (File[])tmpArr.toArray(fileArr));
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(true);
                                }
                            });

                        } catch (IOException e) {
                            e.printStackTrace();
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(false);
                                }
                            });
                        }
                    }
                }).start();
            }
            break;
            case "extractArchive":
                final String path5 = call.argument("path");
                final String dest = call.argument("dest");
                final int archiveFormat2 = call.argument("archiveFormat");
                final Integer compressionType2 = call.argument("compressionType");

                new Thread(new Runnable() {
                    @Override
                    public void run() {

                        try {
                            Archiver archiver;
                            if (compressionType2 == null) {
                                archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat2));
                            } else {
                                archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat2), ArchiveMapper.compressionType(compressionType2));
                            }

                            archiver.extract(new File(path5), new File(dest));
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(true);
                                }
                            });
                        } catch (IOException e) {
                            activity.runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    result.success(false);
                                }
                            });
                            e.printStackTrace();
                        }
                    }
                }).start();
                break;
            // // WIFI
            // case "isConnected":
            //   result.success(wifi.isConnected());
            //   break;
            // case "getIp":
            //   try {
            //     result.success(wifi.getIp());
            //   } catch (Exception e) {
            //     e.printStackTrace();
            //   }
            //   break;

            default:
                result.notImplemented();
        }
    }
}


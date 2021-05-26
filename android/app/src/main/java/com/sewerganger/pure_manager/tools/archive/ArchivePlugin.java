package com.sewerganger.pure_manager.tools.archive;

import android.app.Activity;
import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import net.lingala.zip4j.exception.ZipException;

import org.rauschig.jarchivelib.Archiver;
import org.rauschig.jarchivelib.ArchiverFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.LogRecord;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


class MyHandler extends Handler {

}


public class ArchivePlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private MethodChannel channel;
  private Archive archive;
  private Activity activity;
  private String CHANNEL_NAME = "aqua_archive";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    archive = new Archive(channel);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    archive = null;
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "zip": {
        final ArrayList<String> paths = call.argument("paths");
        final String targetPath = call.argument("targetPath");
        final int level = call.argument("level");
        final int method = call.argument("method");
        final int encrypt = call.argument("encrypt");
        final String pwd = call.argument("pwd");

        new Thread(() -> {
          final boolean r = archive.zip(paths, targetPath, ArchiveMapper.level(level), ArchiveMapper.method(method), ArchiveMapper.encrypt(encrypt), pwd);
          activity.runOnUiThread(() -> result.success(r));
        }).start();
      }

      break;
      case "unzip": {
        final String path = call.argument("path");
        final String targetPath = call.argument("targetPath");
        final String pwd = call.argument("pwd");
        new Thread(() -> {
          final boolean r = archive.unzip(path, targetPath, pwd);
          activity.runOnUiThread(() -> result.success(r));
        }).start();
      }
      break;
      case "isZipEncrypted": {
        final String path = call.argument("path");
        try {
          result.success(archive.isZipEncrypted(path));
        } catch (ZipException e) {
          e.printStackTrace();
        }
      }
      break;
      case "isValidZipFile": {
        final String path = call.argument("path");
        result.success(archive.isValidZipFile(path));
      }
      break;
      case "extractTarGz": {
        final String source = call.argument("source");
        final String destPath = call.argument("dest");
        final String linuxRootPath = call.argument("linuxRootPath");

        new Thread(() -> {
          try {
            final ArrayList<ArrayList<String>> list = archive.extractTarGz(source, destPath, linuxRootPath);
            activity.runOnUiThread(() -> result.success(list));
          } catch (IOException e) {
            e.printStackTrace();
          }
        }).start();
      }
      break;
      case "createArchive": {
        final ArrayList<String> paths = call.argument("paths");
        final String dest = call.argument("dest");
        final String archiveName = call.argument("archiveName");
        final int archiveFormat = call.argument("archiveFormat");
        final Integer compressionType = call.argument("compressionType");

        if (paths == null) {
          result.success(false);
          return;
        }

        final File[] fileArr = new File[paths.size()];
        final ArrayList tmpArr = new ArrayList<File>();

        for (String filePath : paths) {
          tmpArr.add(new File(filePath));
        }

        new Thread(() -> {
          Archiver archiver;

          if (compressionType == null) {
            archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat));
          } else {
            archiver = ArchiverFactory.createArchiver(
                ArchiveMapper.archiveFormat(archiveFormat),
                ArchiveMapper.compressionType(compressionType)
            );
          }
          try {
            archiver.create(archiveName, new File(dest), (File[]) tmpArr.toArray(fileArr));
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
}

package com.sewerganger.pure_manager.tools.archive;


import android.app.Activity;
import android.os.Build;

import androidx.annotation.RequiresApi;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.model.enums.CompressionLevel;
import net.lingala.zip4j.model.enums.CompressionMethod;
import net.lingala.zip4j.model.enums.EncryptionMethod;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream;
import org.apache.commons.compress.utils.IOUtils;
import org.rauschig.jarchivelib.Archiver;
import org.rauschig.jarchivelib.ArchiverFactory;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public class Archive {
  private Activity activity;

  public Archive(Activity activity) {
    this.activity = activity;
  }

  public void createZip(MethodCall call, MethodChannel.Result result) {
    final ArrayList<String> paths = call.argument("paths");
    final String targetPath = call.argument("targetPath");
    final int level = call.argument("level");
    final int method = call.argument("method");
    final int encrypt = call.argument("encrypt");
    final String pwd = call.argument("pwd");
    new Thread(() -> {
      final boolean r = zip(paths, targetPath, ArchiveMapper.level(level), ArchiveMapper.method(method), ArchiveMapper.encrypt(encrypt), pwd);
      activity.runOnUiThread(() -> result.success(r));
    }).start();
  }

  public void createUnzip(MethodCall call, MethodChannel.Result result) {
    final String path = call.argument("path");
    final String targetPath = call.argument("targetPath");
    final String pwd = call.argument("pwd");
    new Thread(() -> {
      final boolean r = unzip(path, targetPath, pwd);
      activity.runOnUiThread(() -> result.success(r));
    }).start();
  }

  public void isZipEncrypted(MethodCall call, MethodChannel.Result result) {
    final String path = call.argument("path");
    try {
      result.success(new ZipFile(path).isEncrypted());
    } catch (ZipException e) {
      e.printStackTrace();
    }
  }


  public boolean zip(ArrayList<String> paths, String targetPath, CompressionLevel compressionLevel, CompressionMethod compressionMethod, EncryptionMethod encryptionMethod, String pwd) {
    ZipFile zipFile;
    ZipParameters zipParameters = new ZipParameters();

    if (pwd != null) {
      zipFile = new ZipFile(targetPath, pwd.toCharArray());
      zipParameters.setEncryptFiles(true);

      if (encryptionMethod == null) {
        zipParameters.setEncryptionMethod(EncryptionMethod.ZIP_STANDARD);
      } else {
        zipParameters.setEncryptionMethod(encryptionMethod);
      }

    } else {
      zipFile = new ZipFile(targetPath);
    }

    if (compressionLevel == null) {
      zipParameters.setCompressionLevel(CompressionLevel.NORMAL);
    } else {
      zipParameters.setCompressionLevel(compressionLevel);
    }

    if (compressionMethod == null) {
      zipParameters.setCompressionMethod(CompressionMethod.DEFLATE);
    } else {
      zipParameters.setCompressionMethod(compressionMethod);
    }

    zipParameters.setSymbolicLinkAction(ZipParameters.SymbolicLinkAction.INCLUDE_LINK_AND_LINKED_FILE);

    for (String path : paths) {
      File file = new File(path);
      try {
        if (file.isDirectory()) {
          zipFile.addFolder(file, zipParameters);
        } else {
          zipFile.addFile(file, zipParameters);
        }
      } catch (ZipException e) {
        e.printStackTrace();
        return false;
      }
    }
    return true;
  }

  public boolean unzip(String originPath, String targetPath, String pwd) {
    ZipFile zipFile;
    if (pwd != null) {
      zipFile = new ZipFile(originPath, pwd.toCharArray());
    } else {
      zipFile = new ZipFile(originPath);
    }

    try {
      zipFile.extractAll(targetPath);
    } catch (ZipException e) {
      e.printStackTrace();
      return false;
    }
    return true;
  }

  public void isValidZipFile(MethodCall call, MethodChannel.Result result) {
    final String path = call.argument("path");
    result.success(new ZipFile(path).isValidZipFile());
  }

  public void extractArchive(MethodCall call, MethodChannel.Result result) {
    final String path = call.argument("path");
    final String dest = call.argument("dest");
    final int archiveFormat2 = call.argument("archiveFormat");
    final Integer compressionType2 = call.argument("compressionType");

    new Thread(() -> {
      try {
        Archiver archiver;
        if (compressionType2 == null) {
          archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat2));
        } else {
          archiver = ArchiverFactory.createArchiver(ArchiveMapper.archiveFormat(archiveFormat2), ArchiveMapper.compressionType(compressionType2));
        }

        archiver.extract(new File(path), new File(dest));
        activity.runOnUiThread(() -> result.success(true));
      } catch (IOException e) {
        activity.runOnUiThread(() -> result.success(false));
        e.printStackTrace();
      }
    }).start();
  }


  public void createArchive(MethodCall call, MethodChannel.Result result) {
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
        activity.runOnUiThread(() -> result.success(true));

      } catch (IOException e) {
        activity.runOnUiThread(() -> result.error("createArchive", e.getMessage(), e));
      }
    }).start();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  ArrayList<ArrayList<String>> extractTarGz(String tarPath, String destPath, String linuxRootPath) throws IOException {
//     final String source = call.argument("source");
//        final String destPath = call.argument("dest");
//        final String linuxRootPath = call.argument("linuxRootPath");
//
//        new Thread(() -> {
//          try {
//            final ArrayList<ArrayList<String>> list = archive.extractTarGz(source, destPath, linuxRootPath);
//            activity.runOnUiThread(() -> result.success(list));
//          } catch (IOException e) {
//            e.printStackTrace();
//          }
//        }).start();
    File tarFile = new File(tarPath);
    ArrayList symLinks = new ArrayList();

    try (InputStream fi = new FileInputStream(tarFile);
         InputStream bi = new BufferedInputStream(fi);
         InputStream gzi = new GzipCompressorInputStream(bi);
         TarArchiveInputStream tarStream = new TarArchiveInputStream(gzi)) {
      TarArchiveEntry entry = null;

      while ((entry = tarStream.getNextTarEntry()) != null) {
        if (!tarStream.canReadEntryData(entry)) {
          continue;
        }
        File f = new File(destPath, entry.getName());
        if (entry.isDirectory()) {
          if (!f.isDirectory() && !f.mkdirs()) {
            throw new IOException("failed to create directory " + f);
          }
        } else if (entry.isSymbolicLink()) {

          String linkedPath;
          if (entry.getLinkName().startsWith("/")) {
            linkedPath = linuxRootPath + entry.getLinkName();
          } else {
            linkedPath = f.getAbsolutePath() + "/" + entry.getLinkName();
          }

          ArrayList links = new ArrayList();
          // 原路径
          links.add(linkedPath);
          links.add(f.getAbsolutePath());

          symLinks.add(links);

        } else {
          File parent = f.getParentFile();

          if (!parent.isDirectory() && !parent.mkdirs()) {
            throw new IOException("failed to create directory " + parent);
          }

          try (OutputStream o = new FileOutputStream(f)) {
            IOUtils.copy(tarStream, o);
          }
        }
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    return symLinks;
  }
}


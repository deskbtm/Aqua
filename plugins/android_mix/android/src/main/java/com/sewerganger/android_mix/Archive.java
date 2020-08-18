package com.sewerganger.android_mix;

import android.util.Log;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.model.enums.CompressionLevel;
import net.lingala.zip4j.model.enums.CompressionMethod;
import net.lingala.zip4j.model.enums.EncryptionMethod;
import net.lingala.zip4j.progress.ProgressMonitor;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveOutputStream;
import org.apache.commons.compress.compressors.gzip.GzipCompressorOutputStream;
import org.apache.commons.compress.utils.IOUtils;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel;


class CompressMapper {
  static CompressionLevel level(int index) {
    switch (index) {
      case 0:
        return CompressionLevel.FASTEST;
      case 1:
        return CompressionLevel.FAST;
      case 2:
        return CompressionLevel.NORMAL;
      case 3:
        return CompressionLevel.MAXIMUM;
      case 4:
        return CompressionLevel.ULTRA;
      default:
        throw new IllegalArgumentException("CompressionLevel Unknown index: " + index);
    }
  }

  static CompressionMethod method(int index) {
    switch (index) {
      case 0:
        return CompressionMethod.STORE;
      case 1:
        return CompressionMethod.DEFLATE;
      case 2:
        return CompressionMethod.AES_INTERNAL_ONLY;
      default:
        throw new IllegalArgumentException("CompressionLevel Unknown index: " + index);
    }
  }

  static EncryptionMethod encrypt(int index) {
    switch (index) {
      case 0:
        return EncryptionMethod.AES;
      case 1:
        return EncryptionMethod.ZIP_STANDARD;
      case 2:
        return EncryptionMethod.ZIP_STANDARD_VARIANT_STRONG;
      default:
        throw new IllegalArgumentException("CompressionLevel Unknown index: " + index);
    }
  }
}


public class Archive {
  MethodChannel channel;

  public Archive(MethodChannel channel) {
    this.channel = channel;
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
//    ProgressMonitor progressMonitor = zipFile.getProgressMonitor();
//    zipFile.setRunInThread(true);

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
          zipFile.addFile(file);
        }
      } catch (ZipException e) {
        e.printStackTrace();
        return false;
      }
    }
    return true;
//    while (!progressMonitor.getState().equals(ProgressMonitor.State.READY)) {
//      channel.invokeMethod("o nZip",
//        "{\"percent\":" + progressMonitor.getPercentDone() + "," +
//          "\"filename\":" + "\"" + progressMonitor.getFileName() + "\"" + "," +
//          "\"total\":" + progressMonitor.getTotalWork() + "," +
//          "\"workCompleted\":" + progressMonitor.getWorkCompleted() + "," +
//          "\"isPause\":" + progressMonitor.isPause() + "," +
//          "\"isCancelAllTasks\":" + progressMonitor.isCancelAllTasks() + "}"
//      );
//      try {
//        Thread.sleep(100);
//      } catch (InterruptedException e) {
//        e.printStackTrace();
//      }
//    }
//
//    if (progressMonitor.getResult().equals(ProgressMonitor.Result.SUCCESS)) {
//      channel.invokeMethod("onZipSuccess", null);
//    } else if (progressMonitor.getResult().equals(ProgressMonitor.Result.ERROR)) {
//      channel.invokeMethod("onZipError", progressMonitor.getException().getMessage());
//    } else if (progressMonitor.getResult().equals(ProgressMonitor.Result.CANCELLED)) {
//      channel.invokeMethod("onZipCancel", null);
//    }
  }

  public boolean unzip(String originPath, String targetPath, String pwd) {
    ZipFile zipFile;
    if (pwd != null) {
      zipFile = new ZipFile(originPath, pwd.toCharArray());
    } else {
      zipFile = new ZipFile(originPath);
    }
//    ProgressMonitor progressMonitor = zipFile.getProgressMonitor();
    try {
//      zipFile.setRunInThread(true);
      zipFile.extractAll(targetPath);

//      while (!progressMonitor.getState().equals(ProgressMonitor.State.READY)) {
//        channel.invokeMethod("onUnZip",
//          "{\"percent\":" + progressMonitor.getPercentDone() + "," +
//            "\"filename\":" + "\"" + progressMonitor.getFileName() + "\"" + "," +
//            "\"total\":" + progressMonitor.getTotalWork() + "," +
//            "\"workCompleted\":" + progressMonitor.getWorkCompleted() + "," +
//            "\"isPause\":" + progressMonitor.isPause() + "," +
//            "\"isCancelAllTasks\":" + progressMonitor.isCancelAllTasks() + "}"
//        );
//
//        try {
//          Thread.sleep(100);
//        } catch (InterruptedException e) {
//          e.printStackTrace();
//        }
//      }

//      if (progressMonitor.getResult().equals(ProgressMonitor.Result.SUCCESS)) {
//        channel.invokeMethod("onUnZipSuccess", null);
//      } else if (progressMonitor.getResult().equals(ProgressMonitor.Result.ERROR)) {
//        channel.invokeMethod("onUnZipError", progressMonitor.getException().getMessage());
//      } else if (progressMonitor.getResult().equals(ProgressMonitor.Result.CANCELLED)) {
//        channel.invokeMethod("onUnZipCancel", null);
//      }


    } catch (ZipException e) {
      e.printStackTrace();
      return false;
    }
    return true;
  }

  boolean isZipEncrypted(String path) throws ZipException {
    return new ZipFile(path).isEncrypted();
  };

  boolean isValidZipFile(String path)  {
    return new ZipFile(path).isValidZipFile();
  };

//  public void sevenZ(ArrayList<String> paths) throws IOException {
//    for (String path : paths) {
//      File file = new File(path);
//      SevenZOutputFile sevenZOutput = new SevenZOutputFile(file);
//      SevenZArchiveEntry entry = sevenZOutput.createArchiveEntry(fileToArchive, name);
//      sevenZOutput.putArchiveEntry(entry);
//      sevenZOutput.write(contentOfEntry);
//      sevenZOutput.closeArchiveEntry();
//    }
//  }

//  private void addTarFile() {
//    TarArchiveEntry tarArchiveEntry = new TarArchiveEntry();
//  }

//  private void addFilesToCompression(TarArchiveOutputStream taos, File file, String dir) throws IOException {
//    taos.putArchiveEntry(new TarArchiveEntry(file, dir));
//
//    if (file.isFile()) {
//      BufferedInputStream bis = new BufferedInputStream(new FileInputStream(file));
//      IOUtils.copy(bis, taos);
//      taos.closeArchiveEntry();
//      bis.close();
//    } else if (file.isDirectory()) {
//      taos.closeArchiveEntry();
//      for (File childFile : file.listFiles()) {
//        addFilesToCompression(taos, childFile, file.getName());
//      }
//    }
//  }

//  private void addFileToTarGz(TarArchiveOutputStream tOut, String path, String base)
//    throws IOException {
//    File f = new File(path);
//    System.out.println(f.exists());
//    String entryName = base + f.getName();
//    TarArchiveEntry tarEntry = new TarArchiveEntry(f, entryName);
//    tOut.putArchiveEntry(tarEntry);
//
//    if (f.isFile()) {
//      IOUtils.copy(new FileInputStream(f), tOut);
//      tOut.closeArchiveEntry();
//    } else {
//      tOut.closeArchiveEntry();
//      File[] children = f.listFiles();
//      if (children != null) {
//        for (File child : children) {
//          System.out.println(child.getName());
//          addFileToTarGz(tOut, child.getAbsolutePath(), entryName + "/");
//        }
//      }
//    }
//  }
//


//  public void tar(ArrayList<String> paths, String targetPath) throws IOException {
////    ArrayList a = new ArrayList();
////    a.add("C:\\Users\\sewer\\Desktop\\LESS");
////    a.add("C:\\Users\\sewer\\Desktop\\mihoyou");
////    paths = a;
////    new Thread(new Runnable() {
////      @Override
////      public void run() {
////
////      }
////    });
//
//    File outputFile = new File(targetPath);
//    if (!outputFile.exists()) {
//      outputFile.createNewFile();
//    }
//    FileOutputStream fos = new FileOutputStream(outputFile);
//    BufferedOutputStream bos = new BufferedOutputStream(fos);
//    GzipCompressorOutputStream gos = new GzipCompressorOutputStream(bos);
//    TarArchiveOutputStream tos = new TarArchiveOutputStream(gos);
//
//    for (String path : paths) {
//      File file = new File(path);
////      addFilesToCompression(tos, file, ".");
//      if (file.isDirectory()) {
//        File[] dirFiles = file.listFiles();
//        for (File df : dirFiles) {
//          Log.i("File", df.getAbsolutePath());
//          TarArchiveEntry tarArchiveEntry = new TarArchiveEntry(df, df.getName());
//          tos.putArchiveEntry(tarArchiveEntry);
//          if (df.isFile()) {
//            try (FileInputStream in = new FileInputStream(df);) {
//              IOUtils.copy(in, tos);
//            }
//          }
//          tos.closeArchiveEntry();
//        }
//      } else {
//        TarArchiveEntry tarArchiveEntry = new TarArchiveEntry(file, file.getName());
//        tos.putArchiveEntry(tarArchiveEntry);
//        FileInputStream in = new FileInputStream(file);
//        IOUtils.copy(in, tos);
//
//        tos.closeArchiveEntry();
//        in.close();
//      }
//    }
//
//  }
}

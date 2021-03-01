package com.sewerganger.android_mix;

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
import org.rauschig.jarchivelib.ArchiveFormat;
import org.rauschig.jarchivelib.CompressionType;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel;


class ArchiveMapper {
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

  static ArchiveFormat archiveFormat(int index) {
    switch (index) {
      case 0:
        return ArchiveFormat.SEVEN_Z;
      case 1:
        return ArchiveFormat.TAR;
      case 2:
        return ArchiveFormat.JAR;
      case 3:
        return ArchiveFormat.AR;
      case 4:
        return ArchiveFormat.DUMP;
      case 5:
        return ArchiveFormat.CPIO;
      default:
        throw new IllegalArgumentException("archiveFormat Unknown index: " + index);
    }
  }

  static CompressionType compressionType(int index) {
    switch (index) {
      case 0:
        return CompressionType.BZIP2;
      case 1:
        return CompressionType.GZIP;
      case 2:
        return CompressionType.PACK200;
      case 3:
        return CompressionType.XZ;
      default:
        throw new IllegalArgumentException("archiveFormat Unknown index: " + index);
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

  boolean isZipEncrypted(String path) throws ZipException {
    return new ZipFile(path).isEncrypted();
  }

  boolean isValidZipFile(String path) {
    return new ZipFile(path).isValidZipFile();
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  ArrayList<ArrayList<String>> extractTarGz(String tarPath, String destPath, String linuxRootPath) throws IOException {
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

package com.sewerganger.pure_manager.tools.archive;

import net.lingala.zip4j.model.enums.CompressionLevel;
import net.lingala.zip4j.model.enums.CompressionMethod;
import net.lingala.zip4j.model.enums.EncryptionMethod;

import org.rauschig.jarchivelib.ArchiveFormat;
import org.rauschig.jarchivelib.CompressionType;

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

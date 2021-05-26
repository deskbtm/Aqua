library dio_range_download;

import 'dart:io';
import 'package:dio/dio.dart';

class RangeDownload {
  static Future<Response> downloadWithChunks(
    url,
    savePath, {
    bool isRangeDownload = true,
    ProgressCallback? onReceiveProgress,
    int maxChunk = 6,
    Dio? dio,
    CancelToken? cancelToken,
  }) async {
    const firstChunkSize = 102;

    int total = 0;
    if (dio == null) {
      dio = Dio();
      dio.options.connectTimeout = 60 * 1000;
    }
    var progress = <int>[];
    var progressInit = <int>[];

    Future mergeTempFiles(chunk) async {
      File f = File(savePath + "temp0");
      IOSink ioSink = f.openWrite(mode: FileMode.writeOnlyAppend);
      for (int i = 1; i < chunk; ++i) {
        File _f = File(savePath + "temp$i");
        await ioSink.addStream(_f.openRead());
        await _f.delete();
      }
      await ioSink.close();
      await f.rename(savePath);
    }

    Future mergeFiles(file1, file2, targetFile) async {
      File f1 = File(file1);
      File f2 = File(file2);
      IOSink ioSink = f1.openWrite(mode: FileMode.writeOnlyAppend);
      await ioSink.addStream(f2.openRead());
      await f2.delete();
      await ioSink.close();
      await f1.rename(targetFile);
    }

    createCallback(no) {
      return (int received, rangeTotal) async {
        if (received >= rangeTotal) {
          var path = savePath + "temp${no}";
          var oldPath = savePath + "temp${no}_pre";
          File oldFile = File(oldPath);
          if (oldFile.existsSync()) {
            await mergeFiles(oldPath, path, path);
          }
        }
        progress[no] = progressInit[no] + received;
        if (onReceiveProgress != null && total != 0) {
          onReceiveProgress(progress.reduce((a, b) => a + b), total);
        }
      };
    }

    Future<Response> downloadChunk(url, start, end, no,
        {isMerge = true}) async {
      int initLength = 0;
      --end;
      var path = savePath + "temp$no";
      File targetFile = File(path);
      if (await targetFile.exists() && isMerge) {
        print("good job start:${start} length:${File(path).lengthSync()}");
        if (start + await targetFile.length() < end) {
          initLength = await targetFile.length();
          start += initLength;
          var preFile = File(path + "_pre");
          if (await preFile.exists()) {
            initLength += await preFile.length();
            start += await preFile.length();
            await mergeFiles(preFile.path, targetFile.path, preFile.path);
          } else {
            await targetFile.rename(preFile.path);
          }
        } else {
          await targetFile.delete();
        }
      }
      progress.add(initLength);
      progressInit.add(initLength);
      return dio!.download(
        url,
        path,
        onReceiveProgress: createCallback(no),
        options: Options(
          headers: {"range": "bytes=$start-$end"},
        ),
        cancelToken: cancelToken,
      );
    }

    if (isRangeDownload) {
      Response response =
          await downloadChunk(url, 0, firstChunkSize, 0, isMerge: false);
      if (response.statusCode == 206) {
        print("This http protocol support range download");
        total = int.parse(response.headers
            .value(HttpHeaders.contentRangeHeader)!
            .split("/")
            .last);
        int reserved = total -
            int.parse(response.headers.value(HttpHeaders.contentLengthHeader)!);
        int chunk = (reserved / firstChunkSize).ceil() + 1;
        if (chunk > 1) {
          int chunkSize = firstChunkSize;
          if (chunk > maxChunk + 1) {
            chunk = maxChunk + 1;
            chunkSize = (reserved / maxChunk).ceil();
          }
          var futures = <Future>[];
          for (int i = 0; i < maxChunk; ++i) {
            int start = firstChunkSize + i * chunkSize;
            int end;
            if (i == maxChunk - 1) {
              end = total;
            } else {
              end = start + chunkSize;
            }
            futures.add(downloadChunk(url, start, end, i + 1));
          }
          await Future.wait(futures);
        }
        await mergeTempFiles(chunk);
        return Response(
          statusCode: 200,
          statusMessage: "Download sucess.",
          data: "Download sucess.",
          requestOptions: response.requestOptions,
        );
      } else if (response.statusCode == 200) {
        print(
            "The protocol does not support resumable downloads, and regular downloads will be used.");
        return dio.download(
          url,
          savePath,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken,
        );
      } else {
        print("The request encountered a problem, please handle it yourself");
        return response;
      }
    } else {
      return dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    }
  }
}

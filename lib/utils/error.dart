import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:lan_file_more_umeng/lan_file_more_umeng.dart';

Future<Null> recordError({
  String className = "",
  String methodName = "",
  @required String text,
  Exception exception,
  String dataLogType,
  StackTrace stacktrace,
}) async {
  FLog.error(
    text: text,
    exception: exception,
    methodName: methodName,
    dataLogType: dataLogType,
    stacktrace: stacktrace,
    className: className,
  );
  // 发送到友盟
  await LanFileMoreUmeng.reportError(
      "{className:$className} {methodName:$methodName} {text: $text} {exception:${exception?.toString()}}");
}

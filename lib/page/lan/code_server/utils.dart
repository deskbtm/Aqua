import 'dart:io';

import 'package:aqua/plugin/storage/storage.dart';
import 'package:aqua/utils/req.dart';
import 'package:aqua/constant/constant_var.dart';

enum AlpineMirror { ustc, aliyun, tsinghua, alpine }

class CodeSrvUtils {
  late String filesPath;
  String tarName = 'lan-file-more.tar.gz';
  String busyboxName = 'busybox';

  Future<CodeSrvUtils> init() async {
    filesPath = await ExtraStorage.getFilesDir;
    return this;
  }

  Future<void> fetchAndSave(String from, String to) async {
    try {
      await req().download(from, to, onReceiveProgress: (a, b) {});
    } catch (err) {
      throw err;
    }
  }

  Future<ProcessResult> chmod777(String path) async {
    return Process.run(
      'chmod',
      [
        '-R',
        '777',
        path,
      ],
      workingDirectory: '/',
    );
  }

  Future<File> fakeNameServer() async {
    File conf = File('$filesPath/rootfs/etc/resolv.conf');
    if (!(await conf.exists())) {
      await conf.create(recursive: true);
    }
    return conf.writeAsString("""
nameserver 1.1.1.1
nameserver 1.0.0.1
""");
  }

  Future<dynamic> createProotTmp() async {
    Directory tmp = Directory('$filesPath/tmp');
    if (!tmp.existsSync()) {
      return Directory('$filesPath/tmp').create(recursive: true);
    }
  }

  Future<File> fakeProcStat() async {
    File file = File('$filesPath/rootfs/proc/.stat');

    if (!(await file.exists())) {
      await file.create(recursive: true);
    }
    return file.writeAsString("""
cpu  1050008 127632 898432 43828767 37203 63 99244 0 0 0
cpu0 212383 20476 204704 8389202 7253 42 12597 0 0 0
cpu1 224452 24947 215570 8372502 8135 4 42768 0 0 0
cpu2 222993 17440 200925 8424262 8069 9 17732 0 0 0
cpu3 186835 8775 195974 8486330 5746 3 8360 0 0 0
cpu4 107075 32886 48854 8688521 3995 4 5758 0 0 0
cpu5 90733 20914 27798 1429573 2984 1 11419 0 0 0
intr 53261351 0 686 1 0 0 1 12 31 1 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7818 0 0 0 0 0 0 0 0 255 33 1912 33 0 0 0 0 0 0 3449534 2315885 2150546 2399277 696281 339300 22642 19371 0 0 0 0 0 0 0 0 0 0 0 2199 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2445 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 162240 14293 2858 0 151709 151592 0 0 0 284534 0 0 0 0 0 0 0 0 0 0 0 0 0 0 185353 0 0 938962 0 0 0 0 736100 0 0 1 1209 27960 0 0 0 0 0 0 0 0 303 115968 452839 2 0 0 0 0 0 0 0 0 0 0 0 0 0 160361 8835 86413 1292 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6091 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 35667 0 0 156823 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 138 2667417 0 41 4008 952 16633 533480 0 0 0 0 0 0 262506 0 0 0 0 0 0 126 0 0 1558488 0 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 2 8 0 0 6 0 0 0 10 3 4 0 0 0 0 0 3 0 0 0 0 0 0 0 0 0 0 0 20 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 12 1 1 83806 0 1 1 0 1 0 1 1 319686 2 8 0 0 0 0 0 0 0 0 0 244534 0 1 10 9 0 10 112 107 40 221 0 0 0 144
ctxt 90182396
btime 1595203295
processes 270853
procs_running 2
procs_blocked 0
softirq 25293348 2883 7658936 40779 539155 497187 2864 1908702 7229194 279723 7133925
""");
  }

  Future<File> fakeProcVersion() async {
    File file = File('$filesPath/rootfs/proc/.version');

    if (!(await file.exists())) {
      await file.create(recursive: true);
    }
    return file.writeAsString(
        """Linux version 5.4.0-fake-kernel (termux@fakehost) (gcc version 4.9.x 20150123 (prerelease) (GCC) ) #1 SMP PREEMPT Fri Jul 10 00:00:00 UTC 2020""");
  }

  Future<File> fakeHost() async {
    File file = File('$filesPath/rootfs/etc/hosts');

    if (!(await file.exists())) {
      await file.create(recursive: true);
    }
    return file.writeAsString("""
# IPv4.
127.0.0.1   localhost.localdomain localhost

# IPv6.
::1         localhost.localdomain localhost ipv6-localhost ipv6-loopback
fe00::0     ipv6-localnet
ff00::0     ipv6-mcastprefix
ff02::1     ipv6-allnodes
ff02::2     ipv6-allrouters
ff02::3     ipv6-allhosts
""");
  }

  Future<ProcessResult> tarGz(String from, String to) async {
    return Process.run(
      '$filesPath/busybox',
      ['tar', 'zxf', from, '-C', to],
      workingDirectory: filesPath,
    );
  }

  Future<bool> prepareResource(
    String resourceUrl,
    String busyboxUrl,
  ) async {
    try {
      await fetchAndSave(busyboxUrl, '$filesPath/$busyboxName');
      await fetchAndSave(resourceUrl, '$filesPath/$tarName');
      await installResource();
      return true;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> installResource() async {
    await chmod777('$filesPath/$tarName');
    await chmod777('$filesPath/busybox');
    if (!(await File('$filesPath/busybox').exists())) {
      return false;
    }
    await tarGz('./$tarName', './');
    await chmod777('$filesPath/proot');
    await createProotTmp();
    await chmod777('$filesPath/rootfs');
    await setChineseRepo();
    await fakeNameServer();
    await fakeProcStat();
    await fakeProcVersion();
    await fakeHost();
    return true;
  }

  List<String> getArguments(List<String> cmds) {
    return [
      '--kernel-release=5.4.0-fake-kernel',
      '-0',
      '--link2symlink',
      '-r',
      '$filesPath/rootfs',
      '-b',
      '/dev/',
      '-b',
      '/sys/',
      '-b',
      '/proc/',
      '-b',
      '/sdcard',
      '-b',
      '/storage',
      '-w',
      '/root',
      '/usr/bin/env',
      '-i',
      'HOME`=/root',
      'PREFIX=/usr',
      'PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin/',
      'LANG=C.UTF-8',
      ...cmds
    ];
  }

  Future<ProcessResult> runProot(List<String> cmds,
      {Map<String, String>? env}) async {
    return Process.run(
      '$filesPath/proot',
      getArguments(cmds),
      workingDirectory: '/',
      environment: {'PROOT_TMP_DIR': '$filesPath/tmp', ...?env},
      includeParentEnvironment: true,
    );
  }

  Future<Process> startProot(List<String> cmds,
      {Map<String, String>? env}) async {
    return Process.start(
      '$filesPath/proot',
      getArguments(cmds),
      workingDirectory: '/',
      includeParentEnvironment: true,
      environment: {'PROOT_TMP_DIR': '$filesPath/tmp', ...?env},
    );
  }

  Future<void> setChineseRepo([String? mirror]) async {
    String mirrorUrl;
    switch (mirror) {
      case TSINGHUA_REPO:
        mirrorUrl =
            'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
        break;
      case ALIYUN_REPO:
        mirrorUrl =
            'http://mirrors.aliyun.com/alpine/latest-stable/main\nhttp://mirrors.aliyun.com/alpine/latest-stable/community';
        break;
      case USTC_REPO:
        mirrorUrl =
            'http://mirrors.ustc.edu.cn/alpine/latest-stable/main\nhttp://mirrors.ustc.edu.cn/alpine/latest-stable/community';
        break;
      case ALPINE_REPO:
        mirrorUrl =
            'http://dl-cdn.alpinelinux.org/alpine/latest-stable/main\nhttp://dl-cdn.alpinelinux.org/alpine/latest-stable/community';
        break;
      default:
        mirrorUrl =
            'http://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttp://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/community';
    }

    File repoFile = File('$filesPath/rootfs/etc/apk/repositories');

    if (repoFile.existsSync()) {
      await repoFile.writeAsString(mirrorUrl);
    } else {
      throw Exception('不存在 ${repoFile.path}');
    }
  }

  Future<ProcessResult> installNodeJs() async {
    return runProot(['apk', 'add', '--allow-untrusted', '/root/nodejs.apk']);
  }

  Future<bool> existsAllResource() async {
    return (await File('$filesPath/proot').exists()) &&
        (await Directory('$filesPath/rootfs').exists());
  }

  Future<void> rmAllResource() async {
    await rmDownloads();
    if (await Directory('$filesPath/rootfs').exists())
      await Directory('$filesPath/rootfs').delete(recursive: true);
    if (await File('$filesPath/proot').exists())
      await File('$filesPath/proot').delete();
  }

  Future<void> rmDownloads() async {
    if (await File('$filesPath/$tarName').exists())
      await File('$filesPath/$tarName').delete();
  }

  Future<void> clearProotTmp() async {
    Directory tmpDir = Directory('$filesPath/tmp');
    if (await tmpDir.exists()) {
      await tmpDir.delete(recursive: true);
      await createProotTmp();
    }
  }

  Future<List<String>> getServerSeemsPids() async {
    ProcessResult ps = await runProot(['ps', '-ef']);
    String output = ps.stdout.toString();

    List<String> seg = output.split(RegExp(r'\n'));
    Set<String> pids = Set();
    for (var i = 0; i < seg.length; i++) {
      String line = seg[i];

      /// [f]
      if (line.contains('node') && line.contains('code-server')) {
        List<String> lines = line.trim().split(RegExp(r'\s+'));
        if (lines != null) {
          pids.add(lines[0]);
        }
      }
    }
    return pids.toList();
  }

  Future<void> killNodeServer() async {
    await for (var item in Stream.fromIterable(await getServerSeemsPids())) {
      await runProot(['kill', '-9', item]);
    }
  }

  bool _existsNodeJs() {
    return File('$filesPath/rootfs/usr/bin/node').existsSync();
  }

  Future<Process> runServer(
    String url, {
    String? pwd,
    bool disableUpdate = true,
    bool debug = false,
  }) async {
    if (_existsNodeJs()) {
      List<String> arg = [
        if (pwd != null) 'PASSWORD=$pwd',
        'node',
        '/root/code-server/out/node/entry.js',
        '--bind-addr',
        url,
        '--force'
      ];

      if (pwd == null) {
        arg.addAll(['--auth', 'none']);
      } else {
        arg.addAll(['--auth', 'password']);
      }

      if (debug) {
        arg.addAll(['--log', 'debug']);
      }

      if (disableUpdate) {
        arg.add('--disable-updates');
      }

      return startProot(arg);
    } else {
      throw Exception('not found nodejs');
    }
  }
}

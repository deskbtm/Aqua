part of system_info;

class ProcessorArchitecture {
  static const ProcessorArchitecture AARCH64 = ProcessorArchitecture('AARCH64');

  static const ProcessorArchitecture ARM = ProcessorArchitecture('ARM');

  static const ProcessorArchitecture IA64 = ProcessorArchitecture('IA64');

  static const ProcessorArchitecture MIPS = ProcessorArchitecture('MIPS');

  static const ProcessorArchitecture X86 = ProcessorArchitecture('X86');

  static const ProcessorArchitecture X86_64 = ProcessorArchitecture('X86_64');

  static const ProcessorArchitecture UNKNOWN = ProcessorArchitecture('UNKNOWN');

  final String name;

  const ProcessorArchitecture(this.name);

  @override
  String toString() => name;
}

class ProcessorInfo {
  final ProcessorArchitecture architecture;

  final String name;

  final int socket;

  final String vendor;

  ProcessorInfo(
      {this.architecture = ProcessorArchitecture.UNKNOWN,
      this.name = '',
      this.socket = 0,
      this.vendor = ''});
}

abstract class SysInfo {
  /// Returns the architecture of the kernel.
  ///
  ///     print(SysInfo.kernelArchitecture);
  ///     => i686
  static final String kernelArchitecture = _getKernelArchitecture();

  /// Returns the bintness of kernel.
  ///
  ///     print(SysInfo.kernelBitness);
  ///     => 32
  static final int kernelBitness = _getKernelBitness();

  /// Returns the name of kernel.
  ///
  ///     print(SysInfo.kernelName);
  ///     => Linux
  static final String kernelName = _getKernelName();

  /// Returns the version of kernel.
  ///
  ///     print(SysInfo.kernelVersion);
  ///     => 32
  static final String kernelVersion = _getKernelVersion();

  /// Returns the name of operating system.
  ///
  ///     print(SysInfo.operatingSystemName);
  ///     => Ubuntu
  static final String operatingSystemName = _getOperatingSystemName();

  /// Returns the version of operating system.
  ///
  ///     print(SysInfo.operatingSystemVersion);
  ///     => 14.04
  static final String operatingSystemVersion = _getOperatingSystemVersion();

  /// Returns the information about the processors.
  ///
  ///     print(SysInfo.processors.first.vendor);
  ///     => GenuineIntel
  static final List<ProcessorInfo> processors = _getProcessors();

  /// Returns the path of user home directory.
  ///
  ///     print(SysInfo.userDirectory);
  ///     => /home/andrew
  static final String userDirectory = _getUserDirectory();

  /// Returns the identifier of current user.
  ///
  ///     print(SysInfo.userId);
  ///     => 1000
  static final String userId = _getUserId();

  /// Returns the name of current user.
  ///
  ///     print(SysInfo.userName);
  ///     => 'Andrew'
  static final String userName = _getUserName();

  /// Returns the bitness of the user space.
  ///
  ///     print(SysInfo.userSpaceBitness);
  ///     => 32
  static final int userSpaceBitness = _getUserSpaceBitness();

  static final Map<String, String> _environment = Platform.environment;

  static final String _operatingSystem = Platform.operatingSystem;

  SysInfo._internal();

  /// Returns the amount of free physical memory in bytes.
  ///
  ///     print(SysInfo.getFreePhysicalMemory());
  ///     => 3755331584
  static int getFreePhysicalMemory() => _getFreePhysicalMemory();

  /// Returns the amount of free virtual memory in bytes.
  ///
  ///     print(SysInfo.getFreeVirtualMemory());
  ///     => 3755331584
  static int getFreeVirtualMemory() => _getFreeVirtualMemory();

  /// Returns the amount of total physical memory in bytes.
  ///
  ///     print(SysInfo.getTotalPhysicalMemory());
  ///     => 3755331584
  static int getTotalPhysicalMemory() => _getTotalPhysicalMemory();

  /// Returns the amount of total virtual memory in bytes.
  ///
  ///     print(SysInfo.getTotalVirtualMemory());
  ///     => 3755331584
  static int getTotalVirtualMemory() => _getTotalVirtualMemory();

  /// Returns the amount of virtual memory in bytes used by the proccess.
  ///
  ///     print(SysInfo.getVirtualMemorySize());
  ///     => 123456
  static int getVirtualMemorySize() => _getVirtualMemorySize();

  static ProcessorInfo _createUnknownProcessor() {
    return ProcessorInfo(architecture: ProcessorArchitecture.UNKNOWN);
  }

  static dynamic _error() {
    throw UnsupportedError('Unsupported operating system.');
  }

  static int _getFreePhysicalMemory() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('cat', ['/proc/meminfo']))
            .trim()
            .stringToMap(':')
            .mapValue;
        final value = _fluent(data['MemFree'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        return value * 1024;
      case 'macos':
        return getFreeVirtualMemory();
      case 'windows':
        final data = _wmicGetValueAsMap('OS', ['FreePhysicalMemory']);
        final value = _fluent(data['FreePhysicalMemory']).parseInt().intValue;
        return value * 1024;
      default:
        _error();
    }

    return null;
  }

  static int _getFreeVirtualMemory() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('cat', ['/proc/meminfo']))
            .trim()
            .stringToMap(':')
            .mapValue;
        final physical = _fluent(data['MemFree'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        final swap = _fluent(data['SwapFree'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        return (physical + swap) * 1024;
      case 'macos':
        final data =
            _fluent(_exec('vm_stat', [])).trim().stringToMap(':').mapValue;
        final free =
            _fluent(data['Pages free']).replaceAll('.', '').parseInt().intValue;
        final pageSize = _fluent(_exec('sysctl', ['-n', 'hw.pagesize']))
            .trim()
            .parseInt()
            .intValue;
        return free * pageSize;
      case 'windows':
        final data = _wmicGetValueAsMap('OS', ['FreeVirtualMemory']);
        final free = _fluent(data['FreeVirtualMemory']).parseInt().intValue;
        return free * 1024;
      default:
        _error();
    }

    return null;
  }

  static String _getKernelArchitecture() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_exec('uname', ['-m'])).trim().stringValue;
      case 'windows':
        final wow64 =
            _fluent(_environment['PROCESSOR_ARCHITEW6432']).stringValue;
        if (wow64.isNotEmpty) {
          return wow64;
        }

        return _fluent(_environment['PROCESSOR_ARCHITECTURE']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static int _getKernelBitness() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        if (userSpaceBitness == 64) {
          return 64;
        }

        final paths = <String>[];
        final path = _resolveLink('/etc/ld.so.conf');
        if (path != null) {
          _parseLdConf(path, paths, Set<String>());
        }

        paths.add('/lib');
        paths.add('/lib64');
        for (var path in paths) {
          final files = FileUtils.glob(pathos.join(path, 'libc.so.*'));
          for (var filePath in files) {
            filePath = _resolveLink(filePath);
            if (filePath == null) {
              continue;
            }

            final file = File(filePath);
            if (file.existsSync()) {
              final fileType =
                  _fluent(_exec('file', ['-b', file.path])).trim().stringValue;
              if (fileType.startsWith('ELF 64-bit')) {
                return 64;
              }
            }
          }
        }

        return 32;
      case 'macos':
        if (_fluent(_exec('uname', ['-m'])).trim().stringValue == 'x86_64') {
          return 64;
        }

        return 32;
      case 'windows':
        final wow64 =
            _fluent(_environment['PROCESSOR_ARCHITEW6432']).stringValue;
        if (wow64.isNotEmpty) {
          return 64;
        }

        switch (_environment['PROCESSOR_ARCHITECTURE']) {
          case 'AMD64':
          case 'IA64':
            return 64;
        }

        return 32;
      default:
        _error();
    }

    return null;
  }

  static String _getKernelName() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_exec('uname', ['-s'])).trim().stringValue;
      case 'windows':
        return _fluent(_environment['OS']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getKernelVersion() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_exec('uname', ['-r'])).trim().stringValue;
      case 'windows':
        return operatingSystemVersion;
      default:
        _error();
    }

    return null;
  }

  static String _getOperatingSystemName() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('lsb_release', ['-a']))
            .trim()
            .stringToMap(':')
            .mapValue;
        return _fluent(data['Distributor ID']).stringValue;
      case 'macos':
        final data =
            _fluent(_exec('sw_vers', [])).trim().stringToMap(':').mapValue;
        return _fluent(data['ProductName']).stringValue;
      case 'windows':
        final data = _wmicGetValueAsMap('OS', ['Caption']);
        return _fluent(data['Caption']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getOperatingSystemVersion() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('lsb_release', ['-a']))
            .trim()
            .stringToMap(':')
            .mapValue;
        return _fluent(data['Release']).stringValue;
      case 'macos':
        final data =
            _fluent(_exec('sw_vers', [])).trim().stringToMap(':').mapValue;
        return _fluent(data['ProductVersion']).stringValue;
      case 'windows':
        final data = _wmicGetValueAsMap('OS', ['Version']);
        return _fluent(data['Version']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static List<ProcessorInfo> _getProcessors() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final processors = <ProcessorInfo>[];
        final groups = _fluent(_exec('cat', ['/proc/cpuinfo']))
            .trim()
            .stringToList()
            .listToGroups(':')
            .groupsValue;

        final processorGroups =
            groups.where((e) => e.keys.contains('processor'));
        var cpuImplementer = '';
        var cpuPart = '';
        var hardware = '';
        var processorName = '';
        for (final group in groups) {
          if (cpuPart.isEmpty) {
            cpuPart = _fluent(group['CPU part']).stringValue;
          }

          if (hardware.isEmpty) {
            hardware = _fluent(group['Hardware']).stringValue;
          }

          if (cpuImplementer.isEmpty) {
            cpuImplementer = _fluent(group['CPU implementer']).stringValue;
          }

          if (processorName.isEmpty) {
            processorName = _fluent(group['Processor']).stringValue;
          }
        }

        for (final group in processorGroups) {
          var socket = 0;
          if (_fluent(group['physical id']).stringValue.isNotEmpty) {
            socket = _fluent(group['physical id']).parseInt().intValue;
          } else {
            socket = _fluent(group['processor']).parseInt().intValue;
          }

          var vendor = _fluent(group['vendor_id']).stringValue;
          final modelFields = const <String>['model name', 'cpu model'];
          var name = '';
          for (var field in modelFields) {
            name = _fluent(group[field]).stringValue;
            if (name.isNotEmpty) {
              break;
            }
          }

          if (name.isEmpty) {
            name = processorName;
          }

          var architecture = ProcessorArchitecture.UNKNOWN;
          if (name.startsWith('AMD')) {
            architecture = ProcessorArchitecture.X86;
            final flags = _fluent(group['flags']).split(' ').listValue;
            if (flags.contains('lm')) {
              architecture = ProcessorArchitecture.X86_64;
            }
          } else if (name.startsWith('Intel')) {
            architecture = ProcessorArchitecture.X86;
            final flags = _fluent(group['flags']).split(' ').listValue;
            if (flags.contains('lm')) {
              architecture = ProcessorArchitecture.X86_64;
            }

            if (flags.contains('ia64')) {
              architecture = ProcessorArchitecture.IA64;
            }
          } else if (name.startsWith('ARM')) {
            architecture = ProcessorArchitecture.ARM;
            final features = _fluent(group['Features']).split(' ').listValue;
            if (features.contains('fp')) {
              architecture = ProcessorArchitecture.AARCH64;
            }
          } else if (name.toUpperCase().startsWith('AARCH64')) {
            architecture = ProcessorArchitecture.AARCH64;
          } else if (name.startsWith('MIPS')) {
            architecture = ProcessorArchitecture.MIPS;
          }

          if (vendor.isEmpty) {
            switch (cpuImplementer.toLowerCase()) {
              case '0x51':
                vendor = 'Qualcomm';
                break;
              default:
            }
          }

          final processor = ProcessorInfo(
              architecture: architecture,
              name: name,
              socket: socket,
              vendor: vendor);
          processors.add(processor);
        }

        if (processors.isEmpty) {
          processors.add(_createUnknownProcessor());
        }

        return UnmodifiableListView(processors);
      case 'macos':
        final data = _fluent(_exec('sysctl', ['machdep.cpu']))
            .trim()
            .stringToMap(':')
            .mapValue;
        var architecture = ProcessorArchitecture.UNKNOWN;
        if (data['machdep.cpu.vendor'] == 'GenuineIntel') {
          architecture = ProcessorArchitecture.X86;
          final extfeatures =
              _fluent(data['machdep.cpu.extfeatures']).split(' ').listValue;
          if (extfeatures.contains('EM64T')) {
            architecture = ProcessorArchitecture.X86_64;
          }
        }

        final numberOfCores =
            _fluent(data['machdep.cpu.core_count']).parseInt().intValue;
        final processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfCores; i++) {
          final name = _fluent(data['machdep.cpu.brand_string']).stringValue;
          final vendor = _fluent(data['machdep.cpu.vendor']).stringValue;
          final processor = ProcessorInfo(
              architecture: architecture,
              name: name,
              socket: 0,
              vendor: vendor);
          processors.add(processor);
        }

        if (processors.isEmpty) {
          processors.add(_createUnknownProcessor());
        }

        return UnmodifiableListView(processors);
      case 'windows':
        final groups = _wmicGetValueAsGroups('CPU', [
          'Architecture',
          'DataWidth',
          'Manufacturer',
          'Name',
          'NumberOfCores'
        ]);
        final numberOfSockets = groups.length;
        final processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfSockets; i++) {
          final data = groups[i];
          final numberOfCores =
              _fluent(data['NumberOfCores']).parseInt().intValue;
          var architecture = ProcessorArchitecture.UNKNOWN;
          switch (_fluent(data['Architecture']).parseInt().intValue) {
            case 0:
              architecture = ProcessorArchitecture.X86;
              break;
            case 1:
              architecture = ProcessorArchitecture.MIPS;
              break;
            case 5:
              switch (_fluent(data['DataWidth']).parseInt().intValue) {
                case 32:
                  architecture = ProcessorArchitecture.ARM;
                  break;
                case 64:
                  architecture = ProcessorArchitecture.AARCH64;
                  break;
              }

              break;
            case 9:
              architecture = ProcessorArchitecture.X86_64;
              break;
          }

          for (var socket = 0; socket < numberOfCores; socket++) {
            final name = _fluent(data['Name']).stringValue;
            final vendor = _fluent(data['Manufacturer']).stringValue;
            final processor = ProcessorInfo(
                architecture: architecture,
                name: name,
                socket: socket,
                vendor: vendor);
            processors.add(processor);
          }
        }

        if (processors.isEmpty) {
          processors.add(_createUnknownProcessor());
        }

        return UnmodifiableListView(processors);
      default:
        _error();
    }

    return null;
  }

  static int _getTotalPhysicalMemory() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('cat', ['/proc/meminfo']))
            .trim()
            .stringToMap(':')
            .mapValue;
        final value = _fluent(data['MemTotal'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        return value * 1024;
      case 'macos':
        final pageSize = _fluent(_exec('sysctl', ['-n', 'hw.pagesize']))
            .trim()
            .parseInt()
            .intValue;
        final size = _fluent(_exec('sysctl', ['-n', 'hw.memsize']))
            .trim()
            .parseInt()
            .intValue;
        return size * pageSize;
      case 'windows':
        final data =
            _wmicGetValueAsMap('ComputerSystem', ['TotalPhysicalMemory']);
        final value = _fluent(data['TotalPhysicalMemory']).parseInt().intValue;
        return value;
      default:
        _error();
    }

    return null;
  }

  static int _getTotalVirtualMemory() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        final data = _fluent(_exec('cat', ['/proc/meminfo']))
            .trim()
            .stringToMap(':')
            .mapValue;
        final physical = _fluent(data['MemTotal'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        final swap = _fluent(data['SwapTotal'])
            .split(' ')
            .elementAt(0)
            .parseInt()
            .intValue;
        return (physical + swap) * 1024;
      case 'macos':
        final data =
            _fluent(_exec('vm_stat', [])).trim().stringToMap(':').mapValue;
        final free =
            _fluent(data['Pages free']).replaceAll('.', '').parseInt().intValue;
        final active = _fluent(data['Pages active'])
            .replaceAll('.', '')
            .parseInt()
            .intValue;
        final inactive = _fluent(data['Pages inactive'])
            .replaceAll('.', '')
            .parseInt()
            .intValue;
        final speculative = _fluent(data['Pages speculative'])
            .replaceAll('.', '')
            .parseInt()
            .intValue;
        final wired = _fluent(data['Pages wired down'])
            .replaceAll('.', '')
            .parseInt()
            .intValue;
        final pageSize = _fluent(_exec('sysctl', ['-n', 'hw.pagesize']))
            .trim()
            .parseInt()
            .intValue;
        return (free + active + inactive + speculative + wired) * pageSize;
      case 'windows':
        final data = _wmicGetValueAsMap('OS', ['TotalVirtualMemorySize']);
        final value =
            _fluent(data['TotalVirtualMemorySize']).parseInt().intValue;
        return value * 1024;
      default:
        _error();
    }

    return null;
  }

  static String _getUserDirectory() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_environment['HOME']).stringValue;
      case 'windows':
        return _fluent(_environment['USERPROFILE']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getUserId() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_exec('id', ['-u'])).trim().stringValue;
      case 'windows':
        final data = _wmicGetValueAsMap('UserAccount', ['SID'],
            where: ['Name=\'$userName\'']);
        return _fluent(data['SID']).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getUserName() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        return _fluent(_exec('whoami', [])).trim().stringValue;
      case 'windows':
        final data = _wmicGetValueAsMap('ComputerSystem', ['UserName']);
        return _fluent(data['UserName']).split('\\').last().stringValue;
      default:
        _error();
    }

    return null;
  }

  static int _getUserSpaceBitness() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
        return _fluent(_exec('getconf', ['LONG_BIT']))
            .trim()
            .parseInt()
            .intValue;
      case 'macos':
        if (Platform.version.contains('macos_ia32')) {
          return 32;
        } else if (Platform.version.contains('macos_x64')) {
          return 64;
        } else {
          return kernelBitness;
        }

        break;
      case 'windows':
        final wow64 =
            _fluent(_environment['PROCESSOR_ARCHITEW6432']).stringValue;
        if (wow64.isNotEmpty) {
          return 32;
        }

        switch (_environment['PROCESSOR_ARCHITECTURE']) {
          case 'AMD64':
          case 'IA64':
            return 64;
        }

        return 32;
      default:
        _error();
    }

    return null;
  }

  static int _getVirtualMemorySize() {
    switch (_operatingSystem) {
      case 'android':
      case 'linux':
      case 'macos':
        final data = _fluent(_exec('ps', ['-o', 'vsz', '-p', '$pid']))
            .trim()
            .stringToList()
            .listValue;
        final size = _fluent(data.elementAt(1)).parseInt().intValue;
        return size * 1024;
      case 'windows':
        final data = _wmicGetValueAsMap('Process', ['VirtualSize'],
            where: ['Handle=\'$pid\'']);
        final value = _fluent(data['VirtualSize']).parseInt().intValue;
        return value;
      default:
        _error();
    }

    return null;
  }
}

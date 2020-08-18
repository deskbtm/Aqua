part of file_utils;

class FilePath {
  static final bool _isWindows = Platform.isWindows;

  /// Returns the expanded [path].
  ///
  /// Expands the following parts:
  ///  - Environment variables (IEEE Std 1003.1-2001), eg. $HOME/dart-sdk/pub
  ///  - Home directory of the current user, eg ~/dart-sdk/pub
  static String expand(String path) {
    if (path == null || path.isEmpty) {
      return path;
    }

    path = _expand(path);
    if (path[0] != '~') {
      return path;
    }

    // TODO: add support of '~user' format.
    String home;
    if (_isWindows) {
      final drive = Platform.environment['HOMEDRIVE'];
      final path = Platform.environment['HOMEPATH'];
      if (drive != null &&
          drive.isNotEmpty &&
          path != null &&
          path.isNotEmpty) {
        home = drive + path;
      } else {
        home = Platform.environment['USERPROFILE'];
      }

      home = home.replaceAll('\\', '/');
    } else {
      home = Platform.environment['HOME'];
    }

    if (home == null || home.isEmpty) {
      return path;
    }

    if (home.endsWith('/') || home.endsWith('\\')) {
      home = home.substring(0, home.length - 1);
    }

    if (path == '~' || path == '~/') {
      return home;
    }

    if (path.startsWith('~/')) {
      return home + '/' + path.substring(2);
    }

    return path;
  }

  /// Returns the full name of the path if possible.
  ///
  /// Resolves the following segments:
  /// - Segments '.' indicating the current directory
  /// - Segments '..' indicating the parent directory
  /// - Leading '~' character indicating the home directory
  /// - Environment variables in IEEE Std 1003.1-2001 format, eg. $HOME/dart-sdk
  ///
  /// Useful when you get path name in a format incompatible with POSIX, and
  /// intend to use it as part of the wildcard patterns.
  ///
  /// Do not use this method directly on wildcard patterns because it can deform
  /// the patterns.
  static String fullname(String path) {
    if (path == null || path.isEmpty) {
      return path;
    }

    var native = false;
    var normalized = false;
    if (path.startsWith('..')) {
      native = true;
      final current = Directory.current.parent.path;
      if (path == '..') {
        path = current;
        normalized = true;
      } else if (path.startsWith('../')) {
        path = pathos.join(current, path.substring(3));
      }
    } else if (path.startsWith('.')) {
      native = true;
      final current = Directory.current.path;
      if (path == '.') {
        path = current;
        normalized = true;
      } else if (path.startsWith('./')) {
        path = pathos.join(current, path.substring(2));
      }
    }

    if (!native) {
      path = FilePath.expand(path);
    }

    if (!normalized) {
      path = pathos.normalize(path);
    }

    if (_isWindows) {
      path = path.replaceAll('\\', '/');
    }

    return path;
  }

  static String _expand(String path) {
    final sb = StringBuffer();
    final length = path.length;
    for (var i = 0; i < length; i++) {
      var s = path[i];
      switch (s) {
        case '\$':
          if (i + 1 < length) {
            var pos = i + 1;
            final c = path.codeUnitAt(pos);
            if ((c >= 65 && c <= 90) || c == 95) {
              while (true) {
                if (pos == length) {
                  break;
                }

                final c = path.codeUnitAt(pos);
                if ((c >= 65 && c <= 90) || (c >= 48 && c <= 57) || c == 95) {
                  pos++;
                  continue;
                }

                break;
              }
            }

            if (pos > i + 1) {
              final key = path.substring(i + 1, pos);
              var value = Platform.environment[key];
              if (value == null) {
                value = '';
              } else if (_isWindows) {
                value = value.replaceAll('\\', '/');
              }

              sb.write(value);
              i = pos - 1;
            } else {
              sb.write(s);
            }
          } else {
            sb.write(s);
          }

          break;
        case '[':
          sb.write(s);
          if (i + 1 < length) {
            s = path[++i];
            sb.write(s);
            while (true) {
              if (i == length) {
                break;
              }

              s = path[++i];
              sb.write(s);
              if (s == ']') {
                break;
              }
            }
          }

          break;
        default:
          sb.write(s);
          break;
      }
    }

    return sb.toString();
  }
}

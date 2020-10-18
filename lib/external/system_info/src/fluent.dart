part of system_info;

_Fluent _fluent(Object value) => _Fluent(value);

class _Fluent {
  dynamic value;

  _Fluent(this.value);

  List<Map<String, String>> get groupsValue {
    if (value is List<Map<String, String>>) {
      return value as List<Map<String, String>>;
    }

    return <Map<String, String>>[];
  }

  int get intValue {
    if (value is int) {
      return value as int;
    }

    return 0;
  }

  List get listValue {
    if (value is List) {
      return value as List;
    }

    return [];
  }

  Map get mapValue {
    if (value is Map) {
      return value as Map;
    }

    return {};
  }

  String get stringValue {
    if (value is String) {
      return value as String;
    }

    return '';
  }

  _Fluent operator [](Object key) {
    try {
      value = value[key];
    } catch (e) {
      value = null;
    }

    return this;
  }

  _Fluent elementAt(int index, [Object defaultValue]) {
    try {
      value = value[index];
    } catch (e) {
      value = null;
    }

    if (value == null && defaultValue != null) {
      value = defaultValue;
    }

    return this;
  }

  _Fluent exec(String executable, List<String> arguments,
      {bool runInShell = false}) {
    try {
      final result =
          Process.runSync(executable, arguments, runInShell: runInShell);
      if (result.exitCode == 0) {
        value = result.stdout.toString();
      }
    } catch (e) {
      value = null;
    }

    return this;
  }

  _Fluent last() {
    if (value is Iterable) {
      value = value.last;
    } else {
      value = null;
    }

    return this;
  }

  _Fluent listToGroups(String separator) {
    final result = <Map<String, String>>[];
    if (value is! List) {
      value = result;
      return this;
    }

    final list = value as List;
    Map<String, String> map;
    for (var element in list) {
      final string = element.toString();
      final index = string.indexOf(separator);
      if (index != -1) {
        if (map == null) {
          map = {};
          result.add(map);
        }

        final key = string.substring(0, index).trim();
        final value = string.substring(index + 1).trim();
        if (map.containsKey(key)) {
          map = {};
          result.add(map);
        }

        map[key] = value;
      } else {
        map = null;
      }
    }

    value = result;
    return this;
  }

  _Fluent listToMap(String separator) {
    if (value is! List) {
      value = <String, String>{};
      return this;
    }

    final list = value as List;
    final map = <String, String>{};
    for (var element in list) {
      final string = element.toString();
      final index = string.indexOf(separator);
      if (index != -1) {
        final key = string.substring(0, index).trim();
        final value = string.substring(index + 1).trim();
        map[key] = value;
      }
    }

    value = map;
    return this;
  }

  _Fluent parseInt([int defaultValue = 0]) {
    if (value == null) {
      value = defaultValue;
    } else {
      value = int.parse(value.toString()) ?? defaultValue;
    }

    return this;
  }

  _Fluent replaceAll(String from, String replace) {
    value = value.toString().replaceAll(from, replace);
    return this;
  }

  _Fluent split(String separtor) {
    value = value.toString().split(separtor);
    return this;
  }

  _Fluent stringToList() {
    if (value == null) {
      value = <String>[];
      return this;
    }

    var string = value.toString();
    string = string.replaceAll('\r\n', '\n');
    //string = string.replaceAll('\r', '\n');
    value = string.split('\n');
    return this;
  }

  _Fluent stringToMap(String separator) {
    stringToList();
    listToMap(separator);
    return this;
  }

  _Fluent trim() {
    value = value.toString().trim();
    return this;
  }
}

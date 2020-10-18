part of system_info;

String _exec(String executable, List<String> arguments,
    {bool runInShell = false}) {
  try {
    final result =
        Process.runSync(executable, arguments, runInShell: runInShell);
    if (result.exitCode == 0) {
      return result.stdout.toString();
    }
  } catch (e) {
    //
  }

  return null;
}

String _resolveLink(String path) {
  while (true) {
    if (!FileUtils.testfile(path, 'link')) {
      break;
    }

    try {
      path = Link(path).resolveSymbolicLinksSync();
    } catch (e) {
      return null;
    }
  }

  return path;
}

void _parseLdConf(String path, List<String> paths, Set<String> processed) {
  path = _resolveLink(path);
  if (path == null) {
    return;
  }

  final file = File(path);
  if (!file.existsSync()) {
    return;
  }

  final dir = FileUtils.dirname(path);
  for (var line in file.readAsLinesSync()) {
    line = line.trim();
    final index = line.indexOf('#');
    if (index != -1) {
      line = line.substring(0, index);
    }

    if (line.isEmpty) {
      continue;
    }

    var include = false;
    if (line.startsWith('include ')) {
      line = line.substring(8);
      include = true;
    }

    if (pathos.isRelative(line)) {
      line = pathos.join(dir, line);
    }

    if (include) {
      for (var path in FileUtils.glob(line)) {
        if (!processed.contains(path)) {
          processed.add(path);
          _parseLdConf(path, paths, processed);
        }
      }
    } else {
      paths.add(line);
    }
  }
}

String _wmicGetValue(String section, List<String> fields,
    {List<String> where}) {
  final arguments = <String>[section];
  if (where != null) {
    arguments.add('where');
    arguments.addAll(where);
  }

  arguments.add('get');
  arguments.addAll(fields.join(', ').split(' '));
  arguments.add('/VALUE');
  return _exec('wmic', arguments);
}

List<Map<String, String>> _wmicGetValueAsGroups(
    String section, List<String> fields,
    {List<String> where}) {
  final string = _wmicGetValue(section, fields, where: where);
  return _fluent(string).stringToList().listToGroups('=').groupsValue;
}

Map<String, String> _wmicGetValueAsMap(String section, List<String> fields,
    {List<String> where}) {
  final string = _wmicGetValue(section, fields, where: where);
  return _fluent(string).stringToList().listToMap('=').mapValue
      as Map<String, String>;
}

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static Future<String> getString(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<int> getNumber(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<bool> setBool(String key, bool val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(key, val);
  }

  static Future<bool> setString(String key, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, content);
  }

  static Future<bool> setStringList(String key, List<String> content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(key, content);
  }

  static Future<List<String>> getStringList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  static Future<void> saveToList(String key, String val,
      {int limit = 20}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lists = prefs.getStringList(key);

    if (lists == null) {
      lists = [val];
    } else {
      if (!lists.contains(val)) {
        if (lists.length >= limit) {
          lists?.add(val);
          lists?.removeRange(0, 1);
        } else {
          lists?.add(val);
        }
      }
    }

    prefs.setStringList(key, lists);
  }

  static Future<void> removeFromList(String key, String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lists = prefs.getStringList(key);
    lists?.removeWhere((v) => v == val);
    prefs.setStringList(key, lists);
  }
}

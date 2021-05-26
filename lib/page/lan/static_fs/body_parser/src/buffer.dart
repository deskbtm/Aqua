import 'dart:convert';

class Buffer {
  final List<int> store;
  Buffer(List<int> store) : store = store;
  String get UTF8 => utf8.decode(this.store);

  @override
  String toString() => this.store.toString();
}

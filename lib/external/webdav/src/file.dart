import 'package:xml/xml.dart' as xml;

class FileInfo {
  String path;
  String size;
  String modificationTime;
  DateTime creationTime;
  String contentType;

  FileInfo(this.path, this.size, this.modificationTime, this.creationTime,
      this.contentType);

  String get name {
    if (this.isDirectory) {
      return Uri.decodeFull(
          this.path.substring(0, this.path.lastIndexOf("/")).split("/").last);
    }

    return Uri.decodeFull(this.path.split("/").last);
  }

  bool get isDirectory => this.path.endsWith("/");

  @override
  String toString() {
    return 'FileInfo{name: $name, isDirectory: $isDirectory ,path: $path, size: $size, modificationTime: $modificationTime, creationTime: $creationTime, contentType: $contentType}';
  }
}

String? prop(dynamic prop, String name, [String? defaultVal]) {
  if (prop is Map) {
    final val = prop['D:' + name];
    if (val == null) {
      return defaultVal;
    }
    return val;
  }
  return defaultVal;
}

List<FileInfo> treeFromWebDavXml(String xmlStr) {
  var tree = <FileInfo>[];

  var xmlDocument = xml.parse(xmlStr);

  findAllElementsFromDocument(xmlDocument, "response").forEach((response) {
    var davItemName = findElementsFromElement(response, "href").single.text;
    findElementsFromElement(
            findElementsFromElement(response, "propstat").first, "prop")
        .forEach((element) {
      final contentLengthElements =
          findElementsFromElement(element, "getcontentlength");
      final contentLength = contentLengthElements.isNotEmpty
          ? contentLengthElements.single.text
          : "";

      final lastModifiedElements =
          findElementsFromElement(element, "getlastmodified");
      final lastModified = lastModifiedElements.isNotEmpty
          ? lastModifiedElements.single.text
          : "";

      final creationTimeElements =
          findElementsFromElement(element, "creationdate");
      final creationTime = creationTimeElements.isNotEmpty
          ? creationTimeElements.single.text
          : DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();

      tree.add(new FileInfo(davItemName, contentLength, lastModified,
          DateTime.parse(creationTime), ""));
    });
  });

  return tree;
}

List<xml.XmlElement> findAllElementsFromDocument(
        xml.XmlDocument document, String tag) =>
    document.findAllElements(tag, namespace: '*').toList();

List<xml.XmlElement> findElementsFromElement(
        xml.XmlElement element, String tag) =>
    element.findElements(tag, namespace: '*').toList();

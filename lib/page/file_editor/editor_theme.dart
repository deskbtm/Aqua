import 'package:flutter/material.dart';

Map<String, TextStyle> setEditorTheme(bool isDark, TextStyle style) {
  return {
    'root': style,
    if (isDark) ...atomOneDarkTheme,
    if (!isDark) ...atomOneLightTheme,
  };
}

Map<String, TextStyle> atomOneDarkTheme = {
  'comment': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xff5c6370), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffc678dd)),
  'keyword': TextStyle(color: Color(0xffc678dd)),
  'formula': TextStyle(color: Color(0xffc678dd)),
  'section': TextStyle(color: Color(0xffe06c75)),
  'name': TextStyle(color: Color(0xffe06c75)),
  'selector-tag': TextStyle(color: Color(0xffe06c75)),
  'deletion': TextStyle(color: Color(0xffe06c75)),
  'subst': TextStyle(color: Color(0xffe06c75)),
  'literal': TextStyle(color: Color(0xff56b6c2)),
  'string': TextStyle(color: Color(0xff98c379)),
  'regexp': TextStyle(color: Color(0xff98c379)),
  'addition': TextStyle(color: Color(0xff98c379)),
  'attribute': TextStyle(color: Color(0xff98c379)),
  'meta-string': TextStyle(color: Color(0xff98c379)),
  'built_in': TextStyle(color: Color(0xffe6c07b)),
  'attr': TextStyle(color: Color(0xffd19a66)),
  'variable': TextStyle(color: Color(0xffd19a66)),
  'template-variable': TextStyle(color: Color(0xffd19a66)),
  'type': TextStyle(color: Color(0xffd19a66)),
  'selector-class': TextStyle(color: Color(0xffd19a66)),
  'selector-attr': TextStyle(color: Color(0xffd19a66)),
  'selector-pseudo': TextStyle(color: Color(0xffd19a66)),
  'number': TextStyle(color: Color(0xffd19a66)),
  'symbol': TextStyle(color: Color(0xff61aeee)),
  'bullet': TextStyle(color: Color(0xff61aeee)),
  'link': TextStyle(color: Color(0xff61aeee)),
  'meta': TextStyle(color: Color(0xff61aeee)),
  'selector-id': TextStyle(color: Color(0xff61aeee)),
  'title': TextStyle(color: Color(0xff61aeee)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

Map<String, TextStyle> atomOneLightTheme = {
  'comment': TextStyle(color: Color(0xffa0a1a7), fontStyle: FontStyle.italic),
  'quote': TextStyle(color: Color(0xffa0a1a7), fontStyle: FontStyle.italic),
  'doctag': TextStyle(color: Color(0xffa626a4)),
  'keyword': TextStyle(color: Color(0xffa626a4)),
  'formula': TextStyle(color: Color(0xffa626a4)),
  'section': TextStyle(color: Color(0xffe45649)),
  'name': TextStyle(color: Color(0xffe45649)),
  'selector-tag': TextStyle(color: Color(0xffe45649)),
  'deletion': TextStyle(color: Color(0xffe45649)),
  'subst': TextStyle(color: Color(0xffe45649)),
  'literal': TextStyle(color: Color(0xff0184bb)),
  'string': TextStyle(color: Color(0xff50a14f)),
  'regexp': TextStyle(color: Color(0xff50a14f)),
  'addition': TextStyle(color: Color(0xff50a14f)),
  'attribute': TextStyle(color: Color(0xff50a14f)),
  'meta-string': TextStyle(color: Color(0xff50a14f)),
  'built_in': TextStyle(color: Color(0xffc18401)),
  'attr': TextStyle(color: Color(0xff986801)),
  'variable': TextStyle(color: Color(0xff986801)),
  'template-variable': TextStyle(color: Color(0xff986801)),
  'type': TextStyle(color: Color(0xff986801)),
  'selector-class': TextStyle(color: Color(0xff986801)),
  'selector-attr': TextStyle(color: Color(0xff986801)),
  'selector-pseudo': TextStyle(color: Color(0xff986801)),
  'number': TextStyle(color: Color(0xff986801)),
  'symbol': TextStyle(color: Color(0xff4078f2)),
  'bullet': TextStyle(color: Color(0xff4078f2)),
  'link': TextStyle(color: Color(0xff4078f2)),
  'meta': TextStyle(color: Color(0xff4078f2)),
  'selector-id': TextStyle(color: Color(0xff4078f2)),
  'title': TextStyle(color: Color(0xff4078f2)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

const FontWeight fontWeight = FontWeight.w400;

// HTML
const Color tagColor = Color(0xFFF79AA5); // tag
const Color quoteColor = Color(0xFF6CD07A); // ""

// CSS
const Color attrColor = Color(0xFFCBBA7D); // CSS selectors
const Color propertyColor = Color(0xFF8CDCFE); // property
const Color idColor = Color(0xFFCBBA7D);
const Color classColor = Color(0xFFCBBA7D);

// JS
const Color keywordColor = Color(0xFF3E9CD6); // keywords (function, ...)
const Color methodsColor = Color(0xFFDCDC9D); // methods built in
const Color titlesColor = Color(0xFFDCDC9D); // titles (function's title)

/// The theme used by code_editor and created by code_editor. This is the default theme of the editor.
///
/// You can create your own or use
/// others themes by looking at :
///
/// `import 'package:flutter_highlight/themes/'`.
const myTheme = {
  'root': TextStyle(
    backgroundColor: Color(0xff2E3152),
    color: Color(0xffdddddd),
  ),
  'keyword': TextStyle(color: keywordColor),
  'params': TextStyle(color: Color(0xffde935f)),
  'selector-tag': TextStyle(color: attrColor),
  'selector-id': TextStyle(color: idColor),
  'selector-class': TextStyle(color: classColor),
  'regexp': TextStyle(color: Color(0xffcc6666)),
  'literal': TextStyle(color: Colors.white),
  'section': TextStyle(color: Colors.white),
  'link': TextStyle(color: Colors.white),
  'subst': TextStyle(color: Color(0xffdddddd)),
  'string': TextStyle(color: quoteColor),
  'title': TextStyle(color: titlesColor),
  'name': TextStyle(color: tagColor),
  'type': TextStyle(color: tagColor),
  'attribute': TextStyle(color: propertyColor),
  'symbol': TextStyle(color: tagColor),
  'bullet': TextStyle(color: tagColor),
  'built_in': TextStyle(color: methodsColor),
  'addition': TextStyle(color: tagColor),
  'variable': TextStyle(color: tagColor),
  'template-tag': TextStyle(color: tagColor),
  'template-variable': TextStyle(color: tagColor),
  'comment': TextStyle(color: Color(0xff777777)),
  'quote': TextStyle(color: Color(0xff777777)),
  'deletion': TextStyle(color: Color(0xff777777)),
  'meta': TextStyle(color: Color(0xff777777)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
};

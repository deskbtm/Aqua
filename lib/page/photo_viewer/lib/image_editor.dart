// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lan_express/external/color_picker/colorpicker.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/all_emojies.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/bottombar_container.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/colors_picker.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/emoji.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/text.dart';
// import 'package:lan_express/page/photo_viewer/lib/modules/textview.dart';
// import 'package:lan_express/model/theme.dart';
// import 'package:outline_material_icons/outline_material_icons.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:signature/signature.dart';

// TextEditingController heightcontroler = TextEditingController();
// TextEditingController widthcontroler = TextEditingController();
// var width = 300;
// var height = 300;

// List fontsize = [];
// var howmuchwidgetis = 0;
// List multiwidget = [];
// Color currentcolors = Colors.white;
// var opicity = 0.0;
// SignatureController _controller =
//     SignatureController(penStrokeWidth: 5, penColor: Colors.green);

// class ImageEditor extends StatefulWidget {
//   final Color appBarColor;
//   final Color bottomBarColor;
//   ImageEditor({this.appBarColor, this.bottomBarColor});

//   @override
//   _ImageEditorState createState() => _ImageEditorState();
// }

// var slider = 0.0;

// class _ImageEditorState extends State<ImageEditor> {
//   // create some values
//   Color pickerColor = Color(0xff443a49);
//   Color currentColor = Color(0xff443a49);
//   ThemeProvider _themeProvider;

// // ValueChanged<Color> callback
//   void changeColor(Color color) {
//     setState(() => pickerColor = color);
//     var points = _controller.points;
//     _controller =
//         SignatureController(penStrokeWidth: 5, penColor: color, points: points);
//   }

//   List<Offset> offsets = [];
//   Offset offset1 = Offset.zero;
//   Offset offset2 = Offset.zero;
//   final scaf = GlobalKey<ScaffoldState>();
//   var openbottomsheet = false;
//   List<Offset> _points = <Offset>[];
//   List type = [];
//   List aligment = [];

//   final GlobalKey container = GlobalKey();
//   final GlobalKey globalKey = GlobalKey();
//   File _image;
//   ScreenshotController screenshotController = ScreenshotController();
//   Timer timeprediction;
//   void timers() {
//     Timer.periodic(Duration(milliseconds: 10), (tim) {
//       setState(() {});
//       timeprediction = tim;
//     });
//   }

//   @override
//   void dispose() {
//     timeprediction.cancel();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     timers();
//     _controller.clear();
//     type.clear();
//     fontsize.clear();
//     offsets.clear();
//     multiwidget.clear();
//     howmuchwidgetis = 0;
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _themeProvider = Provider.of<ThemeProvider>(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.grey,
//         key: scaf,
//         appBar: AppBar(
//           actions: <Widget>[
//             IconButton(
//                 icon: Icon(OMIcons.accessAlarm),
//                 onPressed: () {
//                   showCupertinoDialog(
//                       context: context,
//                       builder: (context) {
//                         return AlertDialog(
//                           title: Text("Select Height Width"),
//                           actions: <Widget>[
//                             FlatButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     height = int.parse(heightcontroler.text);
//                                     width = int.parse(widthcontroler.text);
//                                   });
//                                   heightcontroler.clear();
//                                   widthcontroler.clear();
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text("Done"))
//                           ],
//                           content: SingleChildScrollView(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text("Define Height"),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextField(
//                                     controller: heightcontroler,
//                                     keyboardType:
//                                         TextInputType.numberWithOptions(),
//                                     decoration: InputDecoration(
//                                         hintText: 'Height',
//                                         contentPadding:
//                                             EdgeInsets.only(left: 10),
//                                         border: OutlineInputBorder())),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text("Define Width"),
//                                 SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextField(
//                                     controller: widthcontroler,
//                                     keyboardType:
//                                         TextInputType.numberWithOptions(),
//                                     decoration: InputDecoration(
//                                         hintText: 'Width',
//                                         contentPadding:
//                                             EdgeInsets.only(left: 10),
//                                         border: OutlineInputBorder())),
//                               ],
//                             ),
//                           ),
//                         );
//                       });
//                 }),
//             IconButton(
//                 icon: Icon(Icons.clear),
//                 onPressed: () {
//                   _controller.points.clear();
//                   setState(() {});
//                 }),
//             IconButton(
//                 icon: Icon(Icons.camera),
//                 onPressed: () {
//                   bottomsheets();
//                 }),
//             FlatButton(
//                 child: Text("Done"),
//                 textColor: Colors.white,
//                 onPressed: () {
//                   File _imageFile;
//                   _imageFile = null;
//                   screenshotController
//                       .capture(
//                           delay: Duration(milliseconds: 500), pixelRatio: 1.5)
//                       .then((File image) async {
//                     //print("Capture Done");
//                     setState(() {
//                       _imageFile = image;
//                     });
//                     final paths = await getExternalStorageDirectory();
//                     image.copy(paths.path +
//                         '/' +
//                         DateTime.now().millisecondsSinceEpoch.toString() +
//                         '.png');
//                     Navigator.pop(context, image);
//                   }).catchError((onError) {
//                     print(onError);
//                   });
//                 }),
//           ],
//           backgroundColor: widget.appBarColor,
//         ),
//         body: Center(
//           child: Screenshot(
//             controller: screenshotController,
//             child: Container(
//               margin: EdgeInsets.all(20),
//               color: Colors.white,
//               width: width.toDouble(),
//               height: height.toDouble(),
//               child: RepaintBoundary(
//                   key: globalKey,
//                   child: Stack(
//                     children: <Widget>[
//                       _image != null
//                           ? Image.file(
//                               _image,
//                               height: height.toDouble(),
//                               width: width.toDouble(),
//                               fit: BoxFit.cover,
//                             )
//                           : Container(),
//                       Container(
//                         child: GestureDetector(
//                             onPanUpdate: (DragUpdateDetails details) {
//                               setState(() {
//                                 RenderBox object = context.findRenderObject();
//                                 Offset _localPosition = object
//                                     .globalToLocal(details.globalPosition);
//                                 _points = List.from(_points)
//                                   ..add(_localPosition);
//                               });
//                             },
//                             onPanEnd: (DragEndDetails details) {
//                               _points.add(null);
//                             },
//                             child: Signat()),
//                       ),
//                       Stack(
//                         children: multiwidget.asMap().entries.map((f) {
//                           return type[f.key] == 1
//                               ? EmojiView(
//                                   left: offsets[f.key].dx,
//                                   top: offsets[f.key].dy,
//                                   ontap: () {
//                                     scaf.currentState
//                                         .showBottomSheet((context) {
//                                       return Sliders(
//                                         size: f.key,
//                                         sizevalue: fontsize[f.key].toDouble(),
//                                       );
//                                     });
//                                   },
//                                   onpanupdate: (details) {
//                                     setState(() {
//                                       offsets[f.key] = Offset(
//                                           offsets[f.key].dx + details.delta.dx,
//                                           offsets[f.key].dy + details.delta.dy);
//                                     });
//                                   },
//                                   value: f.value.toString(),
//                                   fontsize: fontsize[f.key].toDouble(),
//                                   align: TextAlign.center,
//                                 )
//                               : type[f.key] == 2
//                                   ? TextView(
//                                       left: offsets[f.key].dx,
//                                       top: offsets[f.key].dy,
//                                       ontap: () {
//                                         scaf.currentState
//                                             .showBottomSheet((context) {
//                                           return Sliders(
//                                             size: f.key,
//                                             sizevalue:
//                                                 fontsize[f.key].toDouble(),
//                                           );
//                                         });
//                                       },
//                                       onpanupdate: (details) {
//                                         setState(() {
//                                           offsets[f.key] = Offset(
//                                               offsets[f.key].dx +
//                                                   details.delta.dx,
//                                               offsets[f.key].dy +
//                                                   details.delta.dy);
//                                         });
//                                       },
//                                       value: f.value.toString(),
//                                       fontsize: fontsize[f.key].toDouble(),
//                                       align: TextAlign.center,
//                                     )
//                                   : Container();
//                         }).toList(),
//                       )
//                     ],
//                   )),
//             ),
//           ),
//         ),
//         bottomNavigationBar: openbottomsheet
//             ? Container()
//             : Container(
//                 decoration: BoxDecoration(
//                     color: widget.bottomBarColor,
//                     boxShadow: [BoxShadow(blurRadius: 10.9)]),
//                 height: 70,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: <Widget>[
//                     BottomBarContainer(
//                       colors: widget.bottomBarColor,
//                       icons: Icons.brush,
//                       ontap: () {
//                         // raise the [showDialog] widget
//                         showDialog(
//                             context: context,
//                             child: AlertDialog(
//                               title: const Text('Pick a color!'),
//                               content: SingleChildScrollView(
//                                 child: ColorPicker(
//                                   pickerColor: pickerColor,
//                                   onColorChanged: changeColor,
//                                   showLabel: true,
//                                   pickerAreaHeightPercent: 0.8,
//                                 ),
//                               ),
//                               actions: <Widget>[
//                                 FlatButton(
//                                   child: const Text('Got it'),
//                                   onPressed: () {
//                                     setState(() => currentColor = pickerColor);
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ],
//                             ));
//                       },
//                       title: 'Brush',
//                     ),
//                     BottomBarContainer(
//                       icons: Icons.text_fields,
//                       ontap: () async {
//                         final value = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => TextEditor()));
//                         if (value.toString().isEmpty) {
//                           print("true");
//                         } else {
//                           type.add(2);
//                           fontsize.add(20);
//                           offsets.add(Offset.zero);
//                           multiwidget.add(value);
//                           howmuchwidgetis++;
//                         }
//                       },
//                       title: 'Text',
//                     ),
//                     BottomBarContainer(
//                       icons: Icons.access_alarm,
//                       ontap: () {
//                         _controller.clear();
//                         type.clear();
//                         fontsize.clear();
//                         offsets.clear();
//                         multiwidget.clear();
//                         howmuchwidgetis = 0;
//                       },
//                       title: 'Eraser',
//                     ),
//                     BottomBarContainer(
//                       icons: Icons.photo,
//                       ontap: () {
//                         showModalBottomSheet(
//                             context: context,
//                             builder: (context) {
//                               return ColorPiskersSlider();
//                             });
//                       },
//                       title: 'Filter',
//                     ),
//                     BottomBarContainer(
//                       icons: Icons.face,
//                       ontap: () {
//                         Future getemojis = showModalBottomSheet(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return Emojies();
//                             });
//                         getemojis.then((value) {
//                           if (value != null) {
//                             type.add(1);
//                             fontsize.add(20);
//                             offsets.add(Offset.zero);
//                             multiwidget.add(value);
//                             howmuchwidgetis++;
//                           }
//                         });
//                       },
//                       title: 'Emoji',
//                     ),
//                   ],
//                 ),
//               ));
//   }

//   void bottomsheets() {
//     openbottomsheet = true;
//     setState(() {});
//     Future<void> future = showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           decoration: BoxDecoration(color: Colors.white, boxShadow: [
//             BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
//           ]),
//           height: 170,
//           child: Column(
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Text("Select Image Options"),
//               ),
//               Divider(
//                 height: 1,
//               ),
//               Container(
//                 padding: EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Container(
//                       child: InkWell(
//                         onTap: () {},
//                         child: Container(
//                           child: Column(
//                             children: <Widget>[
//                               IconButton(
//                                 icon: Icon(Icons.photo_library),
//                                 onPressed: () async {
//                                   // var image = await ImagePicker.pickImage(
//                                   //     source: ImageSource.gallery);
//                                   // var decodedImage = await decodeImageFromList(
//                                   //     image.readAsBytesSync());

//                                   // setState(() {
//                                   //   height = decodedImage.height;
//                                   //   width = decodedImage.width;
//                                   //   _image = image;
//                                   // });
//                                   // setState(() => _controller.clear());
//                                   // Navigator.pop(context);
//                                 },
//                               ),
//                               SizedBox(width: 10),
//                               Text("Open Gallery")
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 24),
//                     InkWell(
//                       onTap: () {},
//                       child: Container(
//                         child: Column(
//                           children: <Widget>[
//                             IconButton(
//                               icon: Icon(Icons.camera_alt),
//                               onPressed: () async {
//                                 //   var image = await ImagePicker.pickImage(
//                                 //       source: ImageSource.camera);
//                                 //   var decodedImage = await decodeImageFromList(
//                                 //       image.readAsBytesSync());

//                                 //   setState(() {
//                                 //     height = decodedImage.height;
//                                 //     width = decodedImage.width;
//                                 //     _image = image;
//                                 //   });
//                                 //   setState(() => _controller.clear());
//                                 //   Navigator.pop(context);
//                               },
//                             ),
//                             SizedBox(width: 10),
//                             Text("Open Camera")
//                           ],
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//         );
//       },
//     );
//     future.then((void value) => _closeModal(value));
//   }

//   void _closeModal(void value) {
//     openbottomsheet = false;
//     setState(() {});
//   }
// }

// class Signat extends StatefulWidget {
//   @override
//   _SignatState createState() => _SignatState();
// }

// class _SignatState extends State<Signat> {
//   @override
//   void initState() {
//     super.initState();
//     _controller.addListener(() => print("Value changed"));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return //SIGNATURE CANVAS
//         //SIGNATURE CANVAS
//         ListView(
//       children: <Widget>[
//         Signature(
//             controller: _controller,
//             height: height.toDouble(),
//             width: width.toDouble(),
//             backgroundColor: Colors.transparent),
//       ],
//     );
//   }
// }

// class Sliders extends StatefulWidget {
//   final int size;
//   final sizevalue;
//   const Sliders({Key key, this.size, this.sizevalue}) : super(key: key);
//   @override
//   _SlidersState createState() => _SlidersState();
// }

// class _SlidersState extends State<Sliders> {
//   @override
//   void initState() {
//     slider = widget.sizevalue;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: 120,
//         child: Column(
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text("Slider Size"),
//             ),
//             Divider(
//               height: 1,
//             ),
//             Slider(
//                 value: slider,
//                 min: 0.0,
//                 max: 100.0,
//                 onChangeEnd: (v) {
//                   setState(() {
//                     fontsize[widget.size] = v.toInt();
//                   });
//                 },
//                 onChanged: (v) {
//                   setState(() {
//                     slider = v;
//                     print(v.toInt());
//                     fontsize[widget.size] = v.toInt();
//                   });
//                 }),
//           ],
//         ));
//   }
// }

// class ColorPiskersSlider extends StatefulWidget {
//   @override
//   _ColorPiskersSliderState createState() => _ColorPiskersSliderState();
// }

// class _ColorPiskersSliderState extends State<ColorPiskersSlider> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       height: 260,
//       color: Colors.white,
//       child: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Text("Slider Filter Color"),
//           ),
//           Divider(
//             height: 1,
//           ),
//           SizedBox(height: 20),
//           Text("Slider Color"),
//           SizedBox(height: 10),
//           BarColorPicker(
//               width: 300,
//               thumbColor: Colors.white,
//               cornerRadius: 10,
//               pickMode: PickMode.Color,
//               colorListener: (int value) {
//                 setState(() {
//                   //  currentColor = Color(value);
//                 });
//               }),
//           SizedBox(height: 20),
//           Text("Slider Opicity"),
//           SizedBox(height: 10),
//           Slider(value: 0.1, min: 0.0, max: 1.0, onChanged: (v) {})
//         ],
//       ),
//     );
//   }
// }

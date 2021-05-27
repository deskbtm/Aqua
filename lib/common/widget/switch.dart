import 'package:flutter/widgets.dart';
import 'package:aqua/external/switch/xliv-switch.dart';

class AquaSwitch extends StatelessWidget {
  final bool value;

  final ValueChanged<bool> onChanged;

  final Color activeColor;

  final Color unActiveColor;

  final Color? thumbColor;

  const AquaSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xCE007BFF),
    this.unActiveColor = const Color(0xCE007BFF),
    this.thumbColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.78,
      child: XlivSwitch(
        unActiveColor: unActiveColor,
        activeColor: activeColor,
        thumbColor: thumbColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

// class AquaSwitch extends StatefulWidget {
//   final bool value;

//   final ValueChanged<bool> onChanged;

//   final Color activeColor;

//   final Color unActiveColor;

//   final Color thumbColor;

//   const AquaSwitch(
//       {Key? key,
//       this.value,
//       this.onChanged,
//       this.activeColor,
//       this.unActiveColor,
//       this.thumbColor})
//       : super(key: key);
//   @override
//   State<StatefulWidget> createState() {
//     return _AquaSwitchState();
//   }
// }

// class _AquaSwitchState extends State<AquaSwitch> {
//   ThemeModel _themeModel;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _themeModel = Provider.of<ThemeModel>(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     dynamic themeData = _themeModel?.themeData;
//     print(themeData.switchColor);
//     return Transform.scale(
//       scale: 0.9,
//       child: XlivSwitch(
//         unActiveColor: themeData.switchColor,
//         activeColor: themeData.switchColor,
//         value: widget.value,
//         onChanged: widget.onChanged,
//       ),
//     );
//   }
// }

import 'package:flutter/widgets.dart';
import 'package:lan_express/external/switch/xliv-switch.dart';

class LanSwitch extends StatelessWidget {
  final bool value;

  final ValueChanged<bool> onChanged;

  final Color activeColor;

  final Color unActiveColor;

  final Color thumbColor;

  const LanSwitch({
    Key key,
    this.value,
    this.onChanged,
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

// class LanSwitch extends StatefulWidget {
//   final bool value;

//   final ValueChanged<bool> onChanged;

//   final Color activeColor;

//   final Color unActiveColor;

//   final Color thumbColor;

//   const LanSwitch(
//       {Key key,
//       this.value,
//       this.onChanged,
//       this.activeColor,
//       this.unActiveColor,
//       this.thumbColor})
//       : super(key: key);
//   @override
//   State<StatefulWidget> createState() {
//     return _LanSwitchState();
//   }
// }

// class _LanSwitchState extends State<LanSwitch> {
//   ThemeProvider _themeProvider;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _themeProvider = Provider.of<ThemeProvider>(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     dynamic themeData = _themeProvider?.themeData;
//     print(themeData?.switchColor);
//     return Transform.scale(
//       scale: 0.9,
//       child: XlivSwitch(
//         unActiveColor: themeData?.switchColor,
//         activeColor: themeData?.switchColor,
//         value: widget.value,
//         onChanged: widget.onChanged,
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:lan_express/provider/theme.dart';

Widget loadingIndicator(BuildContext context, ThemeProvider provider) =>
    CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
          brightness: provider.isDark ? Brightness.dark : Brightness.light),
      child: CupertinoActivityIndicator(),
    );

// Widget loadingWithText(BuildContext context, ThemeProvider provider, ) => Column(
//       children: <Widget>[
//         loadingIndicator(context, provider),
//         SizedBox(height: 10),
//         Container(
//           width: MediaQuery.of(context).size.width - 100,
//           child: Text(
//             'dsadbsajkldhgskaujghdkjsagdjkagdhkasgdhka',
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         SizedBox(height: 10),
//         Text('1232MB/2132GB')
//       ],
//     );

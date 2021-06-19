import 'package:aqua/common/widget/no_resize_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            UniconsLine.band_aid,
            color: Colors.red[400],
            size: 33,
          ),
          NoResizeText('错误')
        ],
      ),
    );
  }
}

class EmptyBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            UniconsLine.box,
            color: Color(0xFF007AFF),
            size: 33,
          ),
          NoResizeText(AppLocalizations.of(context)!.empty)
        ],
      ),
    );
  }
}

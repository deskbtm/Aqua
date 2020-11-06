import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/common/widget/no_resize_text.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

class ImageLeadingTile extends StatefulWidget {
  final String imgUrl;
  final Function onTap;
  final String title;

  const ImageLeadingTile({
    Key key,
    this.imgUrl,
    this.onTap,
    this.title = '',
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageLeadingTileState();
  }
}

class _ImageLeadingTileState extends State<ImageLeadingTile> {
  ThemeModel _themeModel;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  Widget build(BuildContext context) {
    LanFileMoreTheme themeData = _themeModel.themeData;

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(color: themeData?.itemColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        widget.imgUrl,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Center(
                        child: NoResizeText(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            color: themeData?.itemFontColor,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

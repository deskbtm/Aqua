import 'dart:ui';

import 'package:aqua/common/theme.dart';
import 'package:aqua/common/widget/aqua_text_field.dart';
import 'package:aqua/model/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchBar extends StatefulWidget {
  final Function(String text, bool recursive)? onSubmit;

  const SearchBar({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SearchBarState();
  }
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  late ThemeModel _themeModel;
  bool _recursiveSearch = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _textEditingController.clear();
        _recursiveSearch = false;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  void setRecursiveSearch() {
    setState(() {
      _recursiveSearch = !_recursiveSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    AquaTheme themeData = _themeModel.themeData;

    return Container(
      margin: EdgeInsets.only(left: 5, right: 5, top: 6, bottom: 5),
      color: themeData.scaffoldBackgroundColor,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: themeData.searchBarColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  child: AquaTextField(
                    focusNode: _focusNode,
                    decoration: BoxDecoration(),
                    style: TextStyle(fontSize: 16),
                    controller: _textEditingController,
                    placeholder:
                        AppLocalizations.of(context)!.searching + '...',
                    onSubmitted: (text) {
                      if (widget.onSubmit != null) {
                        widget.onSubmit!(text, _recursiveSearch);
                      }
                    },
                    maxLines: 1,
                  ),
                ),
              ),
              Wrap(
                children: [
                  if (_focusNode.hasFocus)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _textEditingController.clear();
                        },
                        child: Container(
                          child: Icon(
                            UniconsLine.multiply,
                            color: themeData.searchBarInactiveIcon,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: setRecursiveSearch,
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          UniconsLine.layer_group,
                          color: _recursiveSearch
                              ? Color(0xFF007AFF)
                              : themeData.searchBarInactiveIcon,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

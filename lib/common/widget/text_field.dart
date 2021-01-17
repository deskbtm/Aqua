import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lan_file_more/model/theme_model.dart';
import 'package:lan_file_more/utils/theme.dart';
import 'package:provider/provider.dart';

export 'package:flutter/services.dart'
    show
        TextInputType,
        TextInputAction,
        TextCapitalization,
        SmartQuotesType,
        SmartDashesType;

// Value inspected from Xcode 11 & iOS 13.0 Simulator.
const BorderSide _kDefaultRoundedBorderSide = BorderSide(
  color: CupertinoDynamicColor.withBrightness(
    color: Color(0x33000000),
    darkColor: Color(0x33FFFFFF),
  ),
  style: BorderStyle.solid,
  width: 0.0,
);
const Border _kDefaultRoundedBorder = Border(
  top: _kDefaultRoundedBorderSide,
  bottom: _kDefaultRoundedBorderSide,
  left: _kDefaultRoundedBorderSide,
  right: _kDefaultRoundedBorderSide,
);

const BoxDecoration _kDefaultRoundedBorderDecoration = BoxDecoration(
  color: CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: CupertinoColors.black,
  ),
  border: _kDefaultRoundedBorder,
  borderRadius: BorderRadius.all(Radius.circular(5.0)),
);

const Color _kDisabledBackground = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFFAFAFA),
  darkColor: Color(0xFF050505),
);

// Value inspected from Xcode 11 & iOS 13.0 Simulator.
// Note it may not be consistent with https://developer.apple.com/design/resources/.
const CupertinoDynamicColor _kClearButtonColor =
    CupertinoDynamicColor.withBrightness(
  color: Color(0xFF636366),
  darkColor: Color(0xFFAEAEB2),
);

// An eyeballed value that moves the cursor slightly left of where it is
// rendered for text on Android so it's positioning more accurately matches the
// native iOS text cursor positioning.
//
// This value is in device pixels, not logical pixels as is typically used
// throughout the codebase.
const int _iOSHorizontalCursorOffsetPixels = -2;

enum OverlayVisibilityMode {
  never,

  editing,

  notEditing,

  always,
}

class _CupertinoTextFieldSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _CupertinoTextFieldSelectionGestureDetectorBuilder({
    @required _LanTextFieldState state,
  })  : _state = state,
        super(delegate: state);

  final _LanTextFieldState _state;

  @override
  void onSingleTapUp(TapUpDetails details) {
    // Because TextSelectionGestureDetector listens to taps that happen on
    // widgets in front of it, tapping the clear button will also trigger
    // this handler. If the clear button widget recognizes the up event,
    // then do not handle it.
    if (_state._clearGlobalKey.currentContext != null) {
      final RenderBox renderBox =
          _state._clearGlobalKey.currentContext.findRenderObject() as RenderBox;
      final Offset localOffset =
          renderBox.globalToLocal(details.globalPosition);
      if (renderBox.hitTest(BoxHitTestResult(), position: localOffset)) {
        return;
      }
    }
    super.onSingleTapUp(details);
    _state._requestKeyboard();
    if (_state.widget.onTap != null) _state.widget.onTap();
  }

  @override
  void onDragSelectionEnd(DragEndDetails details) {
    _state._requestKeyboard();
  }
}

class LanTextField extends StatefulWidget {
  const LanTextField({
    Key key,
    this.controller,
    this.focusNode,
    this.decoration = _kDefaultRoundedBorderDecoration,
    this.padding = const EdgeInsets.all(6.0),
    this.placeholder,
    this.placeholderStyle = const TextStyle(
      fontWeight: FontWeight.w400,
      color: CupertinoColors.placeholderText,
    ),
    this.prefix,
    this.prefixMode = OverlayVisibilityMode.always,
    this.suffix,
    this.suffixMode = OverlayVisibilityMode.always,
    this.clearButtonMode = OverlayVisibilityMode.never,
    TextInputType keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.readOnly = false,
    ToolbarOptions toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType smartDashesType,
    SmartQuotesType smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorRadius = const Radius.circular(2.0),
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.scrollController,
    this.scrollPhysics,
  })  : assert(textAlign != null),
        assert(readOnly != null),
        assert(autofocus != null),
        assert(obscureText != null),
        assert(autocorrect != null),
        smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        assert(enableSuggestions != null),
        assert(maxLengthEnforced != null),
        assert(scrollPadding != null),
        assert(dragStartBehavior != null),
        assert(selectionHeightStyle != null),
        assert(selectionWidthStyle != null),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(expands != null),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength > 0),
        assert(clearButtonMode != null),
        assert(prefixMode != null),
        assert(suffixMode != null),
        keyboardType = keyboardType ??
            (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
        toolbarOptions = toolbarOptions ??
            (obscureText
                ? const ToolbarOptions(
                    selectAll: true,
                    paste: true,
                  )
                : const ToolbarOptions(
                    copy: true,
                    cut: true,
                    selectAll: true,
                    paste: true,
                  )),
        super(key: key);

  final TextEditingController controller;

  final FocusNode focusNode;

  final BoxDecoration decoration;

  final EdgeInsetsGeometry padding;

  final String placeholder;

  final TextStyle placeholderStyle;

  final Widget prefix;

  final OverlayVisibilityMode prefixMode;

  final Widget suffix;

  final OverlayVisibilityMode suffixMode;

  final OverlayVisibilityMode clearButtonMode;

  final TextInputType keyboardType;

  final TextInputAction textInputAction;

  final TextCapitalization textCapitalization;

  final TextStyle style;

  final StrutStyle strutStyle;

  final TextAlign textAlign;

  final ToolbarOptions toolbarOptions;

  final TextAlignVertical textAlignVertical;

  final bool readOnly;

  final bool showCursor;

  final bool autofocus;

  final bool obscureText;

  final bool autocorrect;

  final SmartDashesType smartDashesType;

  final SmartQuotesType smartQuotesType;

  final bool enableSuggestions;

  final int maxLines;

  final int minLines;

  final bool expands;

  final int maxLength;

  final bool maxLengthEnforced;

  final ValueChanged<String> onChanged;

  final VoidCallback onEditingComplete;

  final ValueChanged<String> onSubmitted;

  final List<TextInputFormatter> inputFormatters;

  final bool enabled;

  final double cursorWidth;

  final Radius cursorRadius;

  final Color cursorColor;

  final ui.BoxHeightStyle selectionHeightStyle;

  final ui.BoxWidthStyle selectionWidthStyle;

  final Brightness keyboardAppearance;

  final EdgeInsets scrollPadding;

  final bool enableInteractiveSelection;

  final DragStartBehavior dragStartBehavior;

  final ScrollController scrollController;

  final ScrollPhysics scrollPhysics;

  bool get selectionEnabled => enableInteractiveSelection;

  final GestureTapCallback onTap;

  @override
  _LanTextFieldState createState() => _LanTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'controller', controller,
        defaultValue: null));
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<BoxDecoration>('decoration', decoration));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding));
    properties.add(StringProperty('placeholder', placeholder));
    properties.add(
        DiagnosticsProperty<TextStyle>('placeholderStyle', placeholderStyle));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'prefix', prefix == null ? null : prefixMode));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'suffix', suffix == null ? null : suffixMode));
    properties.add(DiagnosticsProperty<OverlayVisibilityMode>(
        'clearButtonMode', clearButtonMode));
    properties.add(DiagnosticsProperty<TextInputType>(
        'keyboardType', keyboardType,
        defaultValue: TextInputType.text));
    properties.add(
        DiagnosticsProperty<TextStyle>('style', style, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('autofocus', autofocus, defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('obscureText', obscureText,
        defaultValue: false));
    properties.add(DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: true));
    properties.add(EnumProperty<SmartDashesType>(
        'smartDashesType', smartDashesType,
        defaultValue:
            obscureText ? SmartDashesType.disabled : SmartDashesType.enabled));
    properties.add(EnumProperty<SmartQuotesType>(
        'smartQuotesType', smartQuotesType,
        defaultValue:
            obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled));
    properties.add(DiagnosticsProperty<bool>(
        'enableSuggestions', enableSuggestions,
        defaultValue: true));
    properties.add(IntProperty('maxLines', maxLines, defaultValue: 1));
    properties.add(IntProperty('minLines', minLines, defaultValue: null));
    properties.add(
        DiagnosticsProperty<bool>('expands', expands, defaultValue: false));
    properties.add(IntProperty('maxLength', maxLength, defaultValue: null));
    properties.add(FlagProperty('maxLengthEnforced',
        value: maxLengthEnforced, ifTrue: 'max length enforced'));
    properties.add(createCupertinoColorProperty('cursorColor', cursorColor,
        defaultValue: null));
    properties.add(FlagProperty('selectionEnabled',
        value: selectionEnabled,
        defaultValue: true,
        ifFalse: 'selection disabled'));
    properties.add(DiagnosticsProperty<ScrollController>(
        'scrollController', scrollController,
        defaultValue: null));
    properties.add(DiagnosticsProperty<ScrollPhysics>(
        'scrollPhysics', scrollPhysics,
        defaultValue: null));
    properties.add(EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: TextAlign.start));
    properties.add(DiagnosticsProperty<TextAlignVertical>(
        'textAlignVertical', textAlignVertical,
        defaultValue: null));
  }
}

class _LanTextFieldState extends State<LanTextField>
    with AutomaticKeepAliveClientMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  final GlobalKey _clearGlobalKey = GlobalKey();

  TextEditingController _controller;
  TextEditingController get _effectiveController =>
      widget.controller ?? _controller;

  FocusNode _focusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());

  bool _showSelectionHandles = false;

  _CupertinoTextFieldSelectionGestureDetectorBuilder
      _selectionGestureDetectorBuilder;

  // API for TextSelectionGestureDetectorBuilderDelegate.
  @override
  bool get forcePressEnabled => true;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled => widget.selectionEnabled;
  // End of API for TextSelectionGestureDetectorBuilderDelegate.

  @override
  void initState() {
    super.initState();
    _selectionGestureDetectorBuilder =
        _CupertinoTextFieldSelectionGestureDetectorBuilder(state: this);
    if (widget.controller == null) {
      _controller = TextEditingController();
      _controller.addListener(updateKeepAlive);
    }
  }

  @override
  void didUpdateWidget(LanTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
      _controller.addListener(updateKeepAlive);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller = null;
    }
    final bool isEnabled = widget.enabled ?? true;
    final bool wasEnabled = oldWidget.enabled ?? true;
    if (wasEnabled && !isEnabled) {
      _effectiveFocusNode.unfocus();
    }
  }

  ThemeModel _themeModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeModel = Provider.of<ThemeModel>(context);
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.removeListener(updateKeepAlive);
    super.dispose();
  }

  EditableTextState get _editableText => editableTextKey.currentState;

  void _requestKeyboard() {
    _editableText?.requestKeyboard();
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar)
      return false;

    // On iOS, we don't show handles when the selection is collapsed.
    if (_effectiveController.selection.isCollapsed) return false;

    if (cause == SelectionChangedCause.keyboard) return false;

    if (_effectiveController.text.isNotEmpty) return true;

    return false;
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause cause) {
    if (cause == SelectionChangedCause.longPress) {
      _editableText?.bringIntoView(selection.base);
    }
    final bool willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }
  }

  @override
  bool get wantKeepAlive => _controller?.text?.isNotEmpty == true;

  bool _shouldShowAttachment({
    OverlayVisibilityMode attachment,
    bool hasText,
  }) {
    switch (attachment) {
      case OverlayVisibilityMode.never:
        return false;
      case OverlayVisibilityMode.always:
        return true;
      case OverlayVisibilityMode.editing:
        return hasText;
      case OverlayVisibilityMode.notEditing:
        return !hasText;
    }
    assert(false);
    return null;
  }

  bool _showPrefixWidget(TextEditingValue text) {
    return widget.prefix != null &&
        _shouldShowAttachment(
          attachment: widget.prefixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showSuffixWidget(TextEditingValue text) {
    return widget.suffix != null &&
        _shouldShowAttachment(
          attachment: widget.suffixMode,
          hasText: text.text.isNotEmpty,
        );
  }

  bool _showClearButton(TextEditingValue text) {
    return _shouldShowAttachment(
      attachment: widget.clearButtonMode,
      hasText: text.text.isNotEmpty,
    );
  }

  // True if any surrounding decoration widgets will be shown.
  bool get _hasDecoration {
    return widget.placeholder != null ||
        widget.clearButtonMode != OverlayVisibilityMode.never ||
        widget.prefix != null ||
        widget.suffix != null;
  }

  // Provide default behavior if widget.textAlignVertical is not set.
  // LanTextField has top alignment by default, unless it has decoration
  // like a prefix or suffix, in which case it's aligned to the center.
  TextAlignVertical get _textAlignVertical {
    if (widget.textAlignVertical != null) {
      return widget.textAlignVertical;
    }
    return _hasDecoration ? TextAlignVertical.center : TextAlignVertical.top;
  }

  Widget _addTextDependentAttachments(
      Widget editableText, TextStyle textStyle, TextStyle placeholderStyle) {
    assert(editableText != null);
    assert(textStyle != null);
    assert(placeholderStyle != null);
    // If there are no surrounding widgets, just return the core editable text
    // part.
    if (!_hasDecoration) {
      return editableText;
    }

    // Otherwise, listen to the current state of the text entry.
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      child: editableText,
      builder: (BuildContext context, TextEditingValue text, Widget child) {
        return Row(children: <Widget>[
          // Insert a prefix at the front if the prefix visibility mode matches
          // the current text state.
          if (_showPrefixWidget(text)) widget.prefix,
          // In the middle part, stack the placeholder on top of the main EditableText
          // if needed.
          Expanded(
            child: Stack(
              children: <Widget>[
                if (widget.placeholder != null && text.text.isEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: widget.padding,
                      child: Text(
                        widget.placeholder,
                        maxLines: widget.maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: placeholderStyle,
                        textAlign: widget.textAlign,
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
          // First add the explicit suffix if the suffix visibility mode matches.
          if (_showSuffixWidget(text))
            widget.suffix
          // Otherwise, try to show a clear button if its visibility mode matches.
          else if (_showClearButton(text))
            GestureDetector(
              key: _clearGlobalKey,
              onTap: widget.enabled ?? true
                  ? () {
                      // Special handle onChanged for ClearButton
                      // Also call onChanged when the clear button is tapped.
                      final bool textChanged =
                          _effectiveController.text.isNotEmpty;
                      _effectiveController.clear();
                      if (widget.onChanged != null && textChanged)
                        widget.onChanged(_effectiveController.text);
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Icon(
                  CupertinoIcons.clear_thick_circled,
                  size: 18.0,
                  color: CupertinoDynamicColor.resolve(
                      _kClearButtonColor, context),
                ),
              ),
            ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(debugCheckHasDirectionality(context));
    final TextEditingController controller = _effectiveController;
    final List<TextInputFormatter> formatters =
        widget.inputFormatters ?? <TextInputFormatter>[];
    final bool enabled = widget.enabled ?? true;
    final Offset cursorOffset = Offset(
        _iOSHorizontalCursorOffsetPixels /
            MediaQuery.of(context).devicePixelRatio,
        0);
    if (widget.maxLength != null && widget.maxLengthEnforced) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    final CupertinoThemeData themeData = CupertinoTheme.of(context);

    final TextStyle resolvedStyle = widget.style?.copyWith(
      color: CupertinoDynamicColor.resolve(widget.style?.color, context),
      backgroundColor:
          CupertinoDynamicColor.resolve(widget.style?.backgroundColor, context),
    );

    final TextStyle textStyle =
        themeData.textTheme.textStyle.merge(resolvedStyle);

    // final TextStyle resolvedPlaceholderStyle =
    //     widget.placeholderStyle?.copyWith(
    //   color: CupertinoDynamicColor.resolve(
    //       widget.placeholderStyle?.color, context),
    //   backgroundColor: CupertinoDynamicColor.resolve(
    //       widget.placeholderStyle?.backgroundColor, context),
    // );

    // final TextStyle placeholderStyle =
    //     textStyle.merge(resolvedPlaceholderStyle);

    final Brightness keyboardAppearance =
        widget.keyboardAppearance ?? CupertinoTheme.brightnessOf(context);
    final Color cursorColor =
        CupertinoDynamicColor.resolve(widget.cursorColor, context) ??
            themeData.primaryColor;
    // final Color disabledColor =
    // CupertinoDynamicColor.resolve(_kDisabledBackground, context);

    // final Color decorationColor =
    // CupertinoDynamicColor.resolve(widget.decoration?.color, context);

    // final BoxBorder border = widget.decoration?.border;
    // Border resolvedBorder = border as Border;
    // if (border is Border) {
    //   BorderSide resolveBorderSide(BorderSide side) {
    //     return side == BorderSide.none
    //         ? side
    //         : side.copyWith(
    //             color: CupertinoDynamicColor.resolve(side.color, context));
    //   }

    //   resolvedBorder = border == null || border.runtimeType != Border
    //       ? border
    //       : Border(
    //           top: resolveBorderSide(border.top),
    //           left: resolveBorderSide(border.left),
    //           bottom: resolveBorderSide(border.bottom),
    //           right: resolveBorderSide(border.right),
    //         );
    // }

    // final BoxDecoration effectiveDecoration = widget.decoration?.copyWith(
    //   border: resolvedBorder,
    //   color: enabled ? decorationColor : (decorationColor ?? disabledColor),
    // );

    final Widget paddedEditable = Padding(
      padding: widget.padding,
      child: RepaintBoundary(
        child: EditableText(
          key: editableTextKey,
          controller: controller,
          readOnly: widget.readOnly,
          toolbarOptions: widget.toolbarOptions,
          showCursor: widget.showCursor,
          showSelectionHandles: _showSelectionHandles,
          focusNode: _effectiveFocusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          style: textStyle,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          autofocus: widget.autofocus,
          obscureText: widget.obscureText,
          autocorrect: widget.autocorrect,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          enableSuggestions: widget.enableSuggestions,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          selectionColor:
              CupertinoTheme.of(context).primaryColor.withOpacity(0.2),
          selectionControls:
              widget.selectionEnabled ? materialTextSelectionControls : null,
          onChanged: widget.onChanged,
          onSelectionChanged: _handleSelectionChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
          inputFormatters: formatters,
          rendererIgnoresPointer: true,
          cursorWidth: widget.cursorWidth,
          cursorRadius: widget.cursorRadius,
          cursorColor: cursorColor,
          cursorOpacityAnimates: true,
          cursorOffset: cursorOffset,
          paintCursorAboveText: true,
          backgroundCursorColor: CupertinoDynamicColor.resolve(
              CupertinoColors.inactiveGray, context),
          selectionHeightStyle: widget.selectionHeightStyle,
          selectionWidthStyle: widget.selectionWidthStyle,
          scrollPadding: widget.scrollPadding,
          keyboardAppearance: keyboardAppearance,
          dragStartBehavior: widget.dragStartBehavior,
          scrollController: widget.scrollController,
          scrollPhysics: widget.scrollPhysics,
          enableInteractiveSelection: widget.enableInteractiveSelection,
        ),
      ),
    );
    LanFileMoreTheme theme = _themeModel.themeData;

    return Semantics(
      enabled: enabled,
      onTap: !enabled
          ? null
          : () {
              if (!controller.selection.isValid) {
                controller.selection =
                    TextSelection.collapsed(offset: controller.text.length);
              }
              _requestKeyboard();
            },
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          decoration: inputDecoration(
            color: theme.inputColor,
            borderColor: theme.inputBorderColor,
          ),
          child: _selectionGestureDetectorBuilder.buildGestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Align(
              alignment: Alignment(-1.0, _textAlignVertical.y),
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: _addTextDependentAttachments(
                  paddedEditable,
                  textStyle,
                  TextStyle(
                    fontWeight: FontWeight.w400,
                    color: theme.itemFontColor,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

BorderSide kDefaultRoundedBorderSide(color) => BorderSide(
      color: color,
      // CupertinoDynamicColor.withBrightness(
      //   color: Color(0x33000000),
      //   darkColor: Color(0x33FFFFFF),
      // ),
      style: BorderStyle.solid,
      width: 0.0,
    );
Border defaultRoundedBorder({color}) => Border(
      top: kDefaultRoundedBorderSide(color),
      bottom: kDefaultRoundedBorderSide(color),
      left: kDefaultRoundedBorderSide(color),
      right: kDefaultRoundedBorderSide(color),
    );

BoxDecoration inputDecoration(
        {color = CupertinoColors.white, Color borderColor}) =>
    BoxDecoration(
      color: color,
      border: defaultRoundedBorder(color: borderColor),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );

import 'dart:async';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const double _kDefaultTextViewWidth = 240.0;
const double _kDefaultTextViewHeight = 120.0;

/// A native macOS multiline text view backed by NSTextView.
class CNTextView extends StatefulWidget {
  /// Creates a native multiline text view.
  const CNTextView({
    super.key,
    this.controller,
    this.placeholder,
    this.textColor,
    this.placeholderColor,
    this.backgroundColor,
    this.font,
    this.placeholderFont,
    this.width,
    this.height = _kDefaultTextViewHeight,
    this.onChanged,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The text color of the text view.
  final Color? textColor;

  /// The placeholder color of the text view.
  final Color? placeholderColor;

  /// The background color drawn behind the text area.
  final Color? backgroundColor;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Optional native NSFont descriptor for placeholder text.
  final CNFont? placeholderFont;

  /// Optional fixed width for the native control.
  final double? width;

  /// Fixed height for the native control.
  final double height;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Whether the native control should be interactive.
  bool get enabled => onChanged != null;

  @override
  State<CNTextView> createState() => _CNTextViewState();
}

/// Alias of [CNTextView] for developers preferring "Text Area" naming.
typedef CNTextArea = CNTextView;

class _CNTextViewState extends State<CNTextView> {
  MethodChannel? _channel;
  late TextEditingController _controller;
  bool _isUpdatingFromNative = false;
  TextSelection? _pendingSelection;

  String? _lastTextSent;
  int? _lastSelectionBaseSent;
  int? _lastSelectionExtentSent;

  String? _lastPlaceholder;
  int? _lastTextColor;
  int? _lastPlaceholderColor;
  int? _lastBackgroundColor;
  CNFont? _lastFont;
  CNFont? _lastPlaceholderFont;
  bool? _lastEnabled;
  bool? _lastIsDark;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _controller =
          widget.controller ?? TextEditingController(text: _controller.text);
      _controller.addListener(_onControllerChanged);
    }
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  void _onControllerChanged() {
    if (_isUpdatingFromNative) {
      return;
    }

    if (_controller.text != _lastTextSent) {
      _lastTextSent = _controller.text;
      _channel?.invokeMethod('setText', {'value': _controller.text});
    }

    final selection = _controller.selection;
    if (selection.isValid) {
      if (selection.baseOffset != _lastSelectionBaseSent ||
          selection.extentOffset != _lastSelectionExtentSent) {
        _lastSelectionBaseSent = selection.baseOffset;
        _lastSelectionExtentSent = selection.extentOffset;
        _channel?.invokeMethod('setSelection', {
          'base': selection.baseOffset,
          'extent': selection.extentOffset,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return SizedBox(
        width: widget.width ?? _kDefaultTextViewWidth,
        height: widget.height,
        child: CupertinoTextField(
          controller: _controller,
          placeholder: widget.placeholder,
          maxLines: null,
          readOnly: !widget.enabled,
          onChanged: widget.onChanged,
        ),
      );
    }

    const viewType = 'CupertinoNativeTextView';

    final creationParams = <String, dynamic>{
      'text': _controller.text,
      'selectionBase': _controller.selection.isValid
          ? _controller.selection.baseOffset
          : null,
      'selectionExtent': _controller.selection.isValid
          ? _controller.selection.extentOffset
          : null,
      'placeholder': widget.placeholder,
      'textColor': resolveColorToArgb(widget.textColor, context),
      'placeholderColor': resolveColorToArgb(widget.placeholderColor, context),
      'backgroundColor': resolveColorToArgb(widget.backgroundColor, context),
      'font': widget.font?.toMap(),
      'placeholderFont': widget.placeholderFont?.toMap(),
      'enabled': widget.enabled,
      'isDark': _isDark,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            widget.width ??
            (constraints.hasBoundedWidth
                ? constraints.maxWidth
                : _kDefaultTextViewWidth);

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.hasBoundedWidth
                ? width.clamp(0.0, constraints.maxWidth)
                : width,
            height: widget.height,
            child: AppKitView(
              viewType: viewType,
              creationParamsCodec: const StandardMessageCodec(),
              creationParams: creationParams,
              onPlatformViewCreated: _onPlatformViewCreated,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
              },
            ),
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeTextView_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _lastTextSent = _controller.text;
    if (_controller.selection.isValid) {
      _lastSelectionBaseSent = _controller.selection.baseOffset;
      _lastSelectionExtentSent = _controller.selection.extentOffset;
    }
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final value = (call.arguments as String?) ?? '';
        if (_controller.text != value) {
          _isUpdatingFromNative = true;
          _lastTextSent = value;

          TextSelection newSelection;
          if (_pendingSelection != null &&
              _pendingSelection!.baseOffset <= value.length &&
              _pendingSelection!.extentOffset <= value.length) {
            newSelection = _pendingSelection!;
            _pendingSelection = null;
          } else {
            final previousSelection = _controller.selection;
            newSelection = previousSelection.copyWith(
              baseOffset: previousSelection.baseOffset.clamp(0, value.length),
              extentOffset: previousSelection.extentOffset.clamp(
                0,
                value.length,
              ),
            );
          }

          _controller.value = TextEditingValue(
            text: value,
            selection: newSelection,
          );

          _isUpdatingFromNative = false;
          widget.onChanged?.call(value);
        }
        break;
      case 'selectionChanged':
        final args = call.arguments as Map<dynamic, dynamic>?;
        if (args != null) {
          final base = args['base'] as int?;
          final extent = args['extent'] as int?;
          if (base != null && extent != null && base >= 0 && extent >= 0) {
            final currentSelection = _controller.selection;
            if (currentSelection.baseOffset != base ||
                currentSelection.extentOffset != extent) {
              final selection = TextSelection(
                baseOffset: base,
                extentOffset: extent,
              );
              _isUpdatingFromNative = true;
              _lastSelectionBaseSent = base;
              _lastSelectionExtentSent = extent;
              if (base <= _controller.text.length &&
                  extent <= _controller.text.length) {
                _controller.selection = selection;
                _pendingSelection = null;
              } else {
                _pendingSelection = selection;
              }
              _isUpdatingFromNative = false;
            }
          }
        }
        break;
    }

    return null;
  }

  void _cacheCurrentProps() {
    _lastPlaceholder = widget.placeholder;
    _lastTextColor = resolveColorToArgb(widget.textColor, context);
    _lastPlaceholderColor = resolveColorToArgb(
      widget.placeholderColor,
      context,
    );
    _lastBackgroundColor = resolveColorToArgb(widget.backgroundColor, context);
    _lastFont = widget.font;
    _lastPlaceholderFont = widget.placeholderFont;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null || !mounted) return;

    final textColor = resolveColorToArgb(widget.textColor, context);
    final placeholderColor = resolveColorToArgb(
      widget.placeholderColor,
      context,
    );
    final backgroundColor = resolveColorToArgb(widget.backgroundColor, context);

    if (_lastPlaceholder != widget.placeholder) {
      await channel.invokeMethod('setPlaceholder', {
        'value': widget.placeholder,
      });
      _lastPlaceholder = widget.placeholder;
    }

    if (_lastTextColor != textColor) {
      await channel.invokeMethod('setTextColor', {'value': textColor});
      _lastTextColor = textColor;
    }

    if (_lastPlaceholderColor != placeholderColor) {
      await channel.invokeMethod('setPlaceholderColor', {
        'value': placeholderColor,
      });
      _lastPlaceholderColor = placeholderColor;
    }

    if (_lastBackgroundColor != backgroundColor) {
      await channel.invokeMethod('setBackgroundColor', {
        'value': backgroundColor,
      });
      _lastBackgroundColor = backgroundColor;
    }

    if (_lastFont != widget.font) {
      await channel.invokeMethod('setFont', {'value': widget.font?.toMap()});
      _lastFont = widget.font;
    }

    if (_lastPlaceholderFont != widget.placeholderFont) {
      await channel.invokeMethod('setPlaceholderFont', {
        'value': widget.placeholderFont?.toMap(),
      });
      _lastPlaceholderFont = widget.placeholderFont;
    }

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastIsDark != _isDark) {
      await channel.invokeMethod('setIsDark', {'value': _isDark});
      _lastIsDark = _isDark;
    }
  }
}

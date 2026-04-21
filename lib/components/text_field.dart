import 'dart:async';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const double _kDefaultTextFieldWidth = 120.0;
const double _kDefaultTextFieldHeight = 24.0;

/// A native macOS text field backed by NSTextField.
class CNTextField extends StatefulWidget {
  /// Creates a native text field.
  const CNTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.textColor,
    this.placeholderColor,
    this.backgroundColor,
    this.font,
    this.placeholderFont,
    this.controlSize = CNControlSize.regular,
    this.bezelStyle = CNTextFieldBezelStyle.round,
    this.width,
    this.onChanged,
    this.onSubmitted,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The text color of the text field.
  final Color? textColor;

  /// The placeholder color of the text field.
  final Color? placeholderColor;

  /// The background color drawn behind the text field text area.
  final Color? backgroundColor;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Optional native NSFont descriptor for the placeholder text.
  final CNFont? placeholderFont;

  /// Optional fixed width for the native control.
  final double? width;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// The border/bezel style of the text field.
  final CNTextFieldBezelStyle bezelStyle;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  // ignore: public_member_api_docs
  bool get enabled => onChanged != null || onSubmitted != null;

  @override
  State<CNTextField> createState() => _CNTextFieldState();
}

class _CNTextFieldState extends State<CNTextField> {
  MethodChannel? _channel;
  late TextEditingController _controller;
  bool _isUpdatingFromNative = false;
  TextSelection? _pendingSelection;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  String? _lastTextSent;
  int? _lastSelectionBaseSent;
  int? _lastSelectionExtentSent;

  String? _lastPlaceholder;
  int? _lastTextColor;
  int? _lastPlaceholderColor;
  int? _lastBackgroundColor;
  CNFont? _lastFont;
  CNFont? _lastPlaceholderFont;
  CNControlSize? _lastControlSize;
  CNTextFieldBezelStyle? _lastBezelStyle;
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
  void didUpdateWidget(covariant CNTextField oldWidget) {
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

    // Send text to native if changed
    if (_controller.text != _lastTextSent) {
      _lastTextSent = _controller.text;
      _channel?.invokeMethod('setText', {'value': _controller.text});
    }

    // Send selection to native if changed
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
      return const Placeholder();
    }

    const viewType = 'CupertinoNativeTextField';

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
      'controlSize': widget.controlSize.name,
      'bezelStyle': widget.bezelStyle.name,
      'enabled': widget.enabled,
      'isDark': _isDark,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            widget.width ??
            _intrinsicWidth ??
            (constraints.hasBoundedWidth
                ? constraints.maxWidth
                : _kDefaultTextFieldWidth);
        final height =
            _intrinsicHeight ??
            (constraints.hasBoundedHeight
                ? constraints.maxHeight
                : _kDefaultTextFieldHeight);

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.hasBoundedWidth
                ? width.clamp(0.0, constraints.maxWidth)
                : width,
            height: height,
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
    final channel = MethodChannel('CupertinoNativeTextField_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _lastTextSent = _controller.text;
    if (_controller.selection.isValid) {
      _lastSelectionBaseSent = _controller.selection.baseOffset;
      _lastSelectionExtentSent = _controller.selection.extentOffset;
    }
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
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
            } else {
              // debugPrint('Selection already set');
            }
          } else {
            // debugPrint('Invalid selection');
          }
        } else {
          // debugPrint('Invalid selection args');
        }
        break;
      case 'submitted':
        final value = (call.arguments as String?) ?? '';
        widget.onSubmitted?.call(value);
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
    _lastControlSize = widget.controlSize;
    _lastBezelStyle = widget.bezelStyle;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null || !mounted) return;

    bool requiresIntrinsicSize = false;

    if (_lastPlaceholder != widget.placeholder) {
      await channel.invokeMethod('setPlaceholder', {
        'value': widget.placeholder,
      });
      _lastPlaceholder = widget.placeholder;
    }

    if (!mounted) return;
    final textColor = resolveColorToArgb(widget.textColor, context);
    if (_lastTextColor != textColor) {
      await channel.invokeMethod('setTextColor', {'value': textColor});
      _lastTextColor = textColor;
    }

    if (!mounted) return;
    final placeholderColor = resolveColorToArgb(
      widget.placeholderColor,
      context,
    );
    if (_lastPlaceholderColor != placeholderColor) {
      await channel.invokeMethod('setPlaceholderColor', {
        'value': placeholderColor,
      });
      _lastPlaceholderColor = placeholderColor;
    }

    if (!mounted) return;
    final backgroundColor = resolveColorToArgb(widget.backgroundColor, context);
    if (_lastBackgroundColor != backgroundColor) {
      await channel.invokeMethod('setBackgroundColor', {
        'value': backgroundColor,
      });
      _lastBackgroundColor = backgroundColor;
    }

    if (!mounted) return;
    if (_lastFont != widget.font) {
      await channel.invokeMethod('setFont', {'value': widget.font?.toMap()});
      _lastFont = widget.font;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (_lastPlaceholderFont != widget.placeholderFont) {
      await channel.invokeMethod('setPlaceholderFont', {
        'value': widget.placeholderFont?.toMap(),
      });
      _lastPlaceholderFont = widget.placeholderFont;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (!mounted) return;
    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      _lastControlSize = widget.controlSize;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (_lastBezelStyle != widget.bezelStyle) {
      await channel.invokeMethod('setBezelStyle', {
        'value': widget.bezelStyle.name,
      });
      _lastBezelStyle = widget.bezelStyle;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (requiresIntrinsicSize) {
      _requestIntrinsicSize();
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

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final channel = _channel;
        if (channel == null) return;
        final size = await channel.invokeMethod<Map>('getIntrinsicSize');
        final width = (size?['width'] as num?)?.toDouble();
        final height = (size?['height'] as num?)?.toDouble();

        if (width != null && height != null && mounted) {
          setState(() {
            _intrinsicWidth = width > -1 ? width : null;
            _intrinsicHeight = height > -1 ? height : null;
          });
        }
      });
    } catch (_) {}
  }
}

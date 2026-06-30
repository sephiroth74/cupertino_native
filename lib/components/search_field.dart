import 'dart:async';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const double _kDefaultSearchFieldWidth = 180.0;
const double _kDefaultSearchFieldHeight = 24.0;

/// Callback invoked by native code when updated suggestions are needed.
typedef CNSearchSuggestionsRequested = FutureOr<List<String>> Function(String query);

/// A native macOS search field backed by NSSearchField.
class CNSearchField extends StatefulWidget {
  /// Creates a native search field.
  const CNSearchField({
    super.key,
    required this.text,
    this.placeholder,
    this.textColor,
    this.placeholderColor,
    this.backgroundColor,
    this.font,
    this.suggestions,
    this.onSuggestionsRequested,
    this.controlSize = CNControlSize.regular,
    this.bezelStyle = CNTextFieldBezelStyle.round,
    this.width,
    this.onChanged,
    this.onSubmitted,
  });

  /// The background color drawn behind the search field text area.
  final Color? backgroundColor;

  /// The border/bezel style of the search field.
  final CNTextFieldBezelStyle bezelStyle;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Called whenever the user changes the search text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search text.
  final ValueChanged<String>? onSubmitted;

  /// Callback used to fetch suggestions from Flutter when native code requests
  /// updates while the user types.
  final CNSearchSuggestionsRequested? onSuggestionsRequested;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The placeholder color of the search field.
  final Color? placeholderColor;

  /// Optional list of suggestion strings shown in the native completion dropdown
  /// as the user types. Filtering is case-insensitive and uses substring matching.
  /// Pass null or an empty list to disable suggestions.
  final List<String>? suggestions;

  /// The current text shown in the field.
  final String text;

  /// The text color of the search field.
  final Color? textColor;

  /// Optional fixed width for the native control.
  final double? width;

  @override
  State<CNSearchField> createState() => _CNSearchFieldState();

  /// Whether the native control accepts user interaction.
  bool get enabled => onChanged != null || onSubmitted != null;
}

class _CNSearchFieldState extends State<CNSearchField> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  int? _lastBackgroundColor;
  CNTextFieldBezelStyle? _lastBezelStyle;
  CNControlSize? _lastControlSize;
  bool? _lastEnabled;
  CNFont? _lastFont;
  bool? _lastIsDark;
  String? _lastPlaceholder;
  int? _lastPlaceholderColor;
  List<String>? _lastSuggestions;
  String? _lastText;
  int? _lastTextColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveTextColor => widget.textColor ?? CNTheme.of(context).labelColor;

  Color? get _effectivePlaceholderColor => widget.placeholderColor ?? CNTheme.of(context).secondaryLabelColor;

  Color? get _effectiveBackgroundColor => widget.backgroundColor ?? CNTheme.of(context).fillPrimaryColor;

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSearchField_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final value = (call.arguments as String?) ?? '';
        _lastText = value;
        widget.onChanged?.call(value);
        break;
      case 'submitted':
        final value = (call.arguments as String?) ?? '';
        _lastText = value;
        widget.onSubmitted?.call(value);
        break;
      case 'requestSuggestions':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final query = (args?['query'] as String?) ?? '';

        if (widget.onSuggestionsRequested != null) {
          final results = await widget.onSuggestionsRequested!(query);
          return results;
        }

        final source = widget.suggestions ?? <String>[];
        if (query.isEmpty) return source;

        final lower = query.toLowerCase();
        return source.where((item) => item.toLowerCase().contains(lower)).toList();
    }

    return null;
  }

  void _cacheCurrentProps() {
    _lastText = widget.text;
    _lastPlaceholder = widget.placeholder;
    _lastTextColor = resolveColorToArgb(_effectiveTextColor, context);
    _lastPlaceholderColor = resolveColorToArgb(_effectivePlaceholderColor, context);
    _lastBackgroundColor = resolveColorToArgb(_effectiveBackgroundColor, context);
    _lastFont = widget.font;
    _lastControlSize = widget.controlSize;
    _lastBezelStyle = widget.bezelStyle;
    _lastSuggestions = widget.suggestions;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    bool requiresIntrinsicSize = false;

    if (_lastText != widget.text) {
      await channel.invokeMethod('setText', {'value': widget.text});
      _lastText = widget.text;
    }

    if (_lastPlaceholder != widget.placeholder) {
      await channel.invokeMethod('setPlaceholder', {'value': widget.placeholder});
      _lastPlaceholder = widget.placeholder;
    }

    if (!mounted) return;
    final textColor = resolveColorToArgb(_effectiveTextColor, context);
    if (_lastTextColor != textColor) {
      await channel.invokeMethod('setTextColor', {'value': textColor});
      _lastTextColor = textColor;
    }

    if (!mounted) return;
    final placeholderColor = resolveColorToArgb(_effectivePlaceholderColor, context);
    if (_lastPlaceholderColor != placeholderColor) {
      await channel.invokeMethod('setPlaceholderColor', {'value': placeholderColor});
      _lastPlaceholderColor = placeholderColor;
    }

    if (!mounted) return;
    final backgroundColor = resolveColorToArgb(_effectiveBackgroundColor, context);
    if (_lastBackgroundColor != backgroundColor) {
      await channel.invokeMethod('setBackgroundColor', {'value': backgroundColor});
      _lastBackgroundColor = backgroundColor;
    }

    if (!mounted) return;
    if (_lastFont != widget.font) {
      await channel.invokeMethod('setFont', {'value': widget.font?.toMap()});
      _lastFont = widget.font;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (!mounted) return;
    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {'value': widget.controlSize.name});
      _lastControlSize = widget.controlSize;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (_lastBezelStyle != widget.bezelStyle) {
      await channel.invokeMethod('setBezelStyle', {'value': widget.bezelStyle.name});
      _lastBezelStyle = widget.bezelStyle;
      requiresIntrinsicSize = true;
    }

    if (!mounted) return;
    if (!listEquals(_lastSuggestions, widget.suggestions)) {
      await channel.invokeMethod('setSuggestions', {'value': widget.suggestions ?? <String>[]});
      _lastSuggestions = widget.suggestions;
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

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeSearchField';

    final creationParams = <String, dynamic>{
      'text': widget.text,
      'placeholder': widget.placeholder,
      'textColor': resolveColorToArgb(_effectiveTextColor, context),
      'placeholderColor': resolveColorToArgb(_effectivePlaceholderColor, context),
      'backgroundColor': resolveColorToArgb(_effectiveBackgroundColor, context),
      'font': widget.font?.toMap(),
      'controlSize': widget.controlSize.name,
      'bezelStyle': widget.bezelStyle.name,
      'suggestions': widget.suggestions,
      'enabled': widget.enabled,
      'isDark': _isDark,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            widget.width ?? _intrinsicWidth ?? (constraints.hasBoundedWidth ? constraints.maxWidth : _kDefaultSearchFieldWidth);
        final height = _intrinsicHeight ?? (constraints.hasBoundedHeight ? constraints.maxHeight : _kDefaultSearchFieldHeight);

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.hasBoundedWidth ? width.clamp(0.0, constraints.maxWidth) : width,
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
}

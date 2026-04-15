import 'dart:async';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const double _kDefaultComboBoxWidth = 120.0;
const double _kDefaultComboBoxHeight = 24.0;

/// A native macOS combo box backed by NSComboBox.
class CNComboBox extends StatefulWidget {
  /// Creates a native combo box.
  const CNComboBox({
    super.key,
    required this.items,
    required this.text,
    this.behavior = CNComboBoxBehavior.editable,
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

  /// The list of items to display in the dropdown.
  final List<String> items;

  /// The current text shown in the field.
  final String text;

  /// Controls the interaction mode of the combo box.
  final CNComboBoxBehavior behavior;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The text color of the combo box.
  final Color? textColor;

  /// The placeholder color of the combo box.
  final Color? placeholderColor;

  /// The background color drawn behind the text area.
  final Color? backgroundColor;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Optional native NSFont descriptor for the placeholder text.
  final CNFont? placeholderFont;

  /// Optional fixed width for the native control.
  final double? width;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// The border/bezel style of the combo box.
  final CNTextFieldBezelStyle bezelStyle;

  /// Called whenever the user changes the text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Whether the native control accepts user interaction.
  bool get enabled => onChanged != null || onSubmitted != null;

  @override
  State<CNComboBox> createState() => _CNComboBoxState();
}

class _CNComboBoxState extends State<CNComboBox> {
  MethodChannel? _channel;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  String? _lastText;
  CNComboBoxBehavior? _lastBehavior;
  List<String>? _lastItems;
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

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[CNComboBox ${identityHashCode(this)}] $message');
    }
  }

  @override
  void dispose() {
    _log('dispose');
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return const Placeholder();
    }

    const viewType = 'CupertinoNativeComboBox';

    final creationParams = <String, dynamic>{
      'items': widget.items,
      'text': widget.text,
      'behavior': widget.behavior.name,
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
                : _kDefaultComboBoxWidth);
        final height =
            _intrinsicHeight ??
            (constraints.hasBoundedHeight
                ? constraints.maxHeight
                : _kDefaultComboBoxHeight);

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width + 2,
            height: height + 2,
            child: AppKitView(
              viewType: viewType,
              creationParamsCodec: const StandardMessageCodec(),
              creationParams: creationParams,
              onPlatformViewCreated: _onPlatformViewCreated,
              gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
            ),
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    _log('onPlatformViewCreated id=$id');
    final channel = MethodChannel('CupertinoNativeComboBox_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    _log('Native -> Dart method=${call.method}');
    switch (call.method) {
      case 'textChanged':
        final value = (call.arguments as String?) ?? '';
        _lastText = value;
        _log('Native -> Dart textChanged value="$value"');
        widget.onChanged?.call(value);
        break;
      case 'submitted':
        final value = (call.arguments as String?) ?? '';
        _log('Native -> Dart submitted value="$value"');
        widget.onSubmitted?.call(value);
        break;
      case 'debugLog':
        final value = (call.arguments as String?) ?? '';
        _log(value);
        break;
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastText = widget.text;
    _lastBehavior = widget.behavior;
    _lastItems = widget.items;
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

    if (_lastText != widget.text) {
      _log('setText value="${widget.text}"');
      await channel.invokeMethod('setText', {'value': widget.text});
      _lastText = widget.text;
    }

    if (_lastBehavior != widget.behavior) {
      _log('setBehavior value=${widget.behavior.name}');
      await channel.invokeMethod('setBehavior', {
        'value': widget.behavior.name,
      });
      _lastBehavior = widget.behavior;
    }

    if (!listEquals(_lastItems, widget.items)) {
      _log('setItems items=${widget.items.length}');
      await channel.invokeMethod('setItems', {'value': widget.items});
      _lastItems = widget.items;
      requiresIntrinsicSize = true;
    }

    if (_lastPlaceholder != widget.placeholder) {
      _log('setPlaceholder value="${widget.placeholder}"');
      await channel.invokeMethod('setPlaceholder', {
        'value': widget.placeholder,
      });
      _lastPlaceholder = widget.placeholder;
    }

    if (!mounted) return;
    final textColor = resolveColorToArgb(widget.textColor, context);
    if (_lastTextColor != textColor) {
      _log('setTextColor');
      await channel.invokeMethod('setTextColor', {'value': textColor});
      _lastTextColor = textColor;
    }

    if (!mounted) return;
    final placeholderColor = resolveColorToArgb(
      widget.placeholderColor,
      context,
    );
    if (_lastPlaceholderColor != placeholderColor) {
      _log('setPlaceholderColor');
      await channel.invokeMethod('setPlaceholderColor', {
        'value': placeholderColor,
      });
      _lastPlaceholderColor = placeholderColor;
    }

    if (!mounted) return;
    final backgroundColor = resolveColorToArgb(widget.backgroundColor, context);
    if (_lastBackgroundColor != backgroundColor) {
      _log('setBackgroundColor');
      await channel.invokeMethod('setBackgroundColor', {
        'value': backgroundColor,
      });
      _lastBackgroundColor = backgroundColor;
    }

    if (_lastFont != widget.font) {
      _log('setFont');
      await channel.invokeMethod('setFont', {'value': widget.font?.toMap()});
      _lastFont = widget.font;
      requiresIntrinsicSize = true;
    }

    if (_lastPlaceholderFont != widget.placeholderFont) {
      _log('setPlaceholderFont');
      await channel.invokeMethod('setPlaceholderFont', {
        'value': widget.placeholderFont?.toMap(),
      });
      _lastPlaceholderFont = widget.placeholderFont;
      requiresIntrinsicSize = true;
    }

    if (_lastEnabled != widget.enabled) {
      _log('setEnabled value=${widget.enabled}');
      await channel.invokeMethod('setEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (_lastControlSize != widget.controlSize) {
      _log('setControlSize value=${widget.controlSize.name}');
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      _lastControlSize = widget.controlSize;
      requiresIntrinsicSize = true;
    }

    if (_lastBezelStyle != widget.bezelStyle) {
      _log('setBezelStyle value=${widget.bezelStyle.name}');
      await channel.invokeMethod('setBezelStyle', {
        'value': widget.bezelStyle.name,
      });
      _lastBezelStyle = widget.bezelStyle;
      requiresIntrinsicSize = true;
    }

    if (requiresIntrinsicSize) {
      _log('syncPropsToNativeIfNeeded requesting intrinsic size');
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastIsDark != _isDark) {
      _log('setIsDark value=$_isDark');
      await channel.invokeMethod('setIsDark', {'value': _isDark});
      _lastIsDark = _isDark;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      _log('requestIntrinsicSize start');
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ch = _channel;
        if (ch == null) return;
        final size = await ch.invokeMethod<Map>('getIntrinsicSize');
        final width = (size?['width'] as num?)?.toDouble();
        final height = (size?['height'] as num?)?.toDouble();
        _log('requestIntrinsicSize result width=$width height=$height');

        if (width != null && height != null && mounted) {
          setState(() {
            _intrinsicWidth = width > -1 ? width : null;
            _intrinsicHeight = height > -1 ? height : null;
          });
        }
      });
    } catch (e) {
      _log('requestIntrinsicSize error=$e');
    }
  }
}

import 'dart:convert';

import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultSliderWidth = 140.0;

/// A native macOS SwiftUI `Slider`.
///
/// On non-macOS platforms, this falls back to Flutter's [Slider].
class CNSlider extends StatefulWidget with CNViewModifiable {
  /// Creates a native SwiftUI slider.
  const CNSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onEditingChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step,
    this.controller,
    this.modifiers,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(step == null || step > 0);

  /// Optional imperative controller.
  final CNSliderController? controller;

  /// Maximum value.
  final double max;

  /// Minimum value.
  final double min;

  /// Called when slider value changes.
  final ValueChanged<double>? onChanged;

  /// Called when editing starts/ends.
  final ValueChanged<bool>? onEditingChanged;

  /// Optional step increment.
  final double? step;

  /// Current value.
  final double value;

  @override
  final CNViewModifiers? modifiers;

  @override
  State<CNSlider> createState() => _CNSliderState();
}

/// Controller for [CNSlider], allowing imperative updates to native state.
class CNSliderController {
  MethodChannel? _channel;

  /// Sets the slider range.
  Future<void> setRange({required double min, required double max}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setRange', {'min': min, 'max': max});
  }

  /// Sets the current slider [value].
  Future<void> setValue(double value) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {'value': value});
  }

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }
}

class _CNSliderState extends State<CNSlider> {
  MethodChannel? _channel;
  CNSliderController? _internalController;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  bool _isEditingFromNative = false;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  double? _layoutHeight;
  double? _layoutWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  CNSliderController get _controller => widget.controller ?? (_internalController ??= CNSliderController());

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _computePayloadPatch(Map<String, dynamic> previous, Map<String, dynamic> next) {
    final patch = <String, dynamic>{};
    final keys = <String>{...previous.keys, ...next.keys};

    for (final key in keys) {
      final hadPrevious = previous.containsKey(key);
      final hasNext = next.containsKey(key);
      final oldValue = hadPrevious ? previous[key] : null;
      final newValue = hasNext ? next[key] : null;

      final changed = jsonEncode(oldValue) != jsonEncode(newValue);
      if (!changed) continue;

      patch[key] = hasNext ? newValue : null;
    }

    return patch;
  }

  double _defaultHeightForControlSize() {
    switch (widget.modifiers?.controlSize ?? CNControlSize.regular) {
      case CNControlSize.mini:
        return 16.0;
      case CNControlSize.small:
        return 18.0;
      case CNControlSize.regular:
        return 22.0;
      case CNControlSize.large:
        return 26.0;
      case CNControlSize.extraLarge:
        return 30.0;
    }
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;
    if (width == _intrinsicWidth && height == _intrinsicHeight) return;
    setState(() {
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'valueChanged':
        final args = call.arguments as Map?;
        final value = (args?['value'] as num?)?.toDouble();
        if (value != null) {
          widget.onChanged?.call(value);
        }
        break;
      case 'editingChanged':
        final args = call.arguments as Map?;
        final editing = (args?['editing'] as bool?) ?? (args?['editing'] as num?)?.toInt() == 1;
        _isEditingFromNative = editing;
        widget.onEditingChanged?.call(editing);
        break;
      case 'intrinsicSizeChanged':
        final args = call.arguments as Map?;
        _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
        break;
      default:
        break;
    }

    return null;
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSlider_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
      _onIntrinsicSizeChanged((size?['width'] as num?)?.toDouble(), (size?['height'] as num?)?.toDouble());
    } catch (_) {
      // Ignored.
    }
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNSlider] setData -> $payload');
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      _requestIntrinsicSize();
      return;
    }

    final patch = _computePayloadPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    final isValueOnlyPatch = patch.length == 1 && patch.containsKey('value');
    if (isValueOnlyPatch && _isEditingFromNative) {
      debugPrint('[CNSlider] skip patch during native editing -> $patch');
      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    debugPrint('[CNSlider] applyPatch -> $patch');
    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'step': widget.step,
      'isDark': _isDark,
    };

    widget.writeModifiers(payload, context);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final resolvedWidth = widget.width ?? (hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _kDefaultSliderWidth);
        final resolvedHeight =
            widget.height ?? (hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? _defaultHeightForControlSize());

        if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
          _layoutWidth = resolvedWidth;
          _layoutHeight = resolvedHeight;
          _syncPropsToNativeIfNeeded();
        }

        final creationParams = _toPayload();

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight + 10,
          child: AppKitView(
            viewType: 'CupertinoNativeSlider',
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      },
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';

const Map<CNControlSize, double> _kDefaultSwitchWidth = {
  CNControlSize.mini: 36.0,
  CNControlSize.small: 44.0,
  CNControlSize.regular: 54.0,
  CNControlSize.large: 64.0,
  CNControlSize.extraLarge: 64.0,
};

const Map<CNControlSize, double> _kDefaultSwitchHeight = {
  CNControlSize.mini: 12.0,
  CNControlSize.small: 14.0,
  CNControlSize.regular: 16.0,
  CNControlSize.large: 18.0,
  CNControlSize.extraLarge: 18.0,
};

/// A Cupertino-native checkbox rendered by the host platform.
///
/// On iOS/macOS this uses a platform view to embed UISwitch/NSSwitch, and
/// falls back to Flutter's [Switch] on unsupported platforms.
class CNCheckbox extends StatefulWidget {
  /// Creates a Cupertino-native checkbox.
  const CNCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.controlSize = CNControlSize.regular,
    this.color,
    this.label,
    this.systemImage,
  });

  /// An optional label to display next to the checkbox.
  final String? label;

  /// An optional system image name to display next to the checkbox.
  final String? systemImage;

  /// Whether the checkbox is on.
  final bool value;

  /// Whether the checkbox is interactive.
  bool get enabled => onChanged != null;

  /// Callback invoked when the user toggles the value.
  final ValueChanged<bool>? onChanged;

  /// The size of the checkbox control.
  final CNControlSize controlSize;

  /// Optional tint color to apply to the checkbox.
  final Color? color;

  @override
  State<CNCheckbox> createState() => _CNCheckboxState();
}

class _CNCheckboxState extends State<CNCheckbox> {
  MethodChannel? _channel;
  double? _intrinsicWidth;
  double? _intrinsicHeight;

  String? _lastSystemImage;
  String? _lastLabel;
  bool? _lastValue;
  bool? _lastIsDark;
  bool? _lastEnabled;
  CNControlSize? _lastControlSize;
  Color? _lastEffectiveColor;

  // int _pendingToggleId = 0;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveColor =>
      widget.color ?? CupertinoTheme.of(context).primaryColor;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNCheckbox oldWidget) {
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
    // Fallback to Flutter Checkbox on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeCheckbox';

    final creationParams = <String, dynamic>{
      'value': widget.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_effectiveColor, context),
      'label': widget.label,
      'systemImage': widget.systemImage,
    };

    // macOS
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasBoundedWidth = constraints.hasBoundedWidth;
        final bool hasBoundedHeight = constraints.hasBoundedHeight;
        double? width;
        double? height;

        if (hasBoundedWidth) {
          width = constraints.maxWidth;
        } else if (_intrinsicWidth != null) {
          width = _intrinsicWidth;
        }

        if (hasBoundedHeight) {
          height = constraints.maxHeight;
        } else if (_intrinsicHeight != null) {
          height = _intrinsicHeight;
        }

        width ??= _kDefaultSwitchWidth[widget.controlSize];
        height ??= _kDefaultSwitchHeight[widget.controlSize];

        return SizedBox(
          height: height,
          width: width,
          child: AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeCheckbox_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    debugPrint(
      '[checkbox] Method call from native: ${call.method} with args: ${call.arguments}',
    );

    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = args?['value'] as bool?;
      if (value != null) {
        widget.onChanged?.call(value);
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastControlSize = widget.controlSize;
    _lastEffectiveColor = _effectiveColor;
    _lastLabel = widget.label;
    _lastSystemImage = widget.systemImage;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    bool requiresIntrinsicSizeUpdate = false;

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setIsEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (_lastValue != widget.value) {
      await channel.invokeMethod('setValue', {
        'value': widget.value,
        'animated': false,
      });
      _lastValue = widget.value;
    }

    // Style updates (e.g., tint color)
    if (_lastEffectiveColor != _effectiveColor &&
        _effectiveColor != null &&
        mounted) {
      await channel.invokeMethod('setTint', {
        'value': resolveColorToArgb(_effectiveColor, context),
      });
      _lastEffectiveColor = _effectiveColor;
    }

    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      _lastControlSize = widget.controlSize;
      requiresIntrinsicSizeUpdate = true;
    }

    if (_lastLabel != widget.label) {
      await channel.invokeMethod('setLabel', {'value': widget.label});
      _lastLabel = widget.label;
      requiresIntrinsicSizeUpdate = true;
    }

    if (_lastSystemImage != widget.systemImage) {
      await channel.invokeMethod('setSystemImage', {
        'value': widget.systemImage,
      });
      _lastSystemImage = widget.systemImage;
      requiresIntrinsicSizeUpdate = true;
    }

    if (requiresIntrinsicSizeUpdate) {
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;

    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setIsDark', {'value': isDark});
      _lastIsDark = isDark;
    }

    if (_lastEffectiveColor != _effectiveColor &&
        _effectiveColor != null &&
        mounted) {
      await channel.invokeMethod('setTint', {
        'value': resolveColorToArgb(_effectiveColor, context),
      });
      _lastEffectiveColor = _effectiveColor;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ch = _channel;
        if (ch == null) return;
        final size = await ch.invokeMethod<Map>('getIntrinsicSize');
        final w = (size?['width'] as num?)?.toDouble();
        final h = (size?['height'] as num?)?.toDouble();
        _onIntrinsicSizeChanged(w, h);
      });
    } catch (_) {}
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (width != null && height != null && mounted) {
      setState(() {
        debugPrint('Intrinsic size updated: $width x $height');

        _intrinsicWidth = width > -1 ? width : null;
        _intrinsicHeight = height > -1 ? height : null;
      });
    }
  }
}

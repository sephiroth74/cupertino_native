import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import '../channel/params.dart';

const Map<CNControlSize, double> _kDefaultSwitchWidth = {
  CNControlSize.mini: 36.0,
  CNControlSize.small: 44.0,
  CNControlSize.regular: 54.0,
  CNControlSize.large: 64.0,
  CNControlSize.extraLarge: 64.0,
};

const Map<CNControlSize, double> _kDefaultSwitchHeight = {
  CNControlSize.mini: 16.0,
  CNControlSize.small: 20.0,
  CNControlSize.regular: 24.0,
  CNControlSize.large: 28.0,
  CNControlSize.extraLarge: 28.0,
};

/// Controller for a [CNSwitch] that allows imperative updates from Dart
/// to the underlying native NSSwitch instance.
class CNSwitchController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  /// Sets the switch [value]. When [animated] is true the change is animated
  /// on the native control.
  Future<void> setValue(bool value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  /// Enables or disables user interaction on the native switch.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setIsEnabled', {'value': enabled});
  }
}

/// A Cupertino-native switch rendered by the host platform.
///
/// On macOS this uses a platform view to embed NSSwitch, and
/// falls back to Flutter's [Switch] on unsupported platforms.
class CNSwitch extends StatefulWidget {
  /// Creates a Cupertino-native switch.
  const CNSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.controlSize = CNControlSize.regular,
    this.controller,
    this.color,
  });

  /// Whether the switch is on.
  final bool value;

  /// Whether the switch is interactive.
  bool get enabled => onChanged != null;

  /// Callback invoked when the user toggles the value.
  final ValueChanged<bool>? onChanged;

  /// Optional controller to imperatively control the native view.
  final CNSwitchController? controller;

  /// The size of the switch control.
  final CNControlSize controlSize;

  /// Optional tint color to apply to the switch.
  final Color? color;

  @override
  State<CNSwitch> createState() => _CNSwitchState();
}

class _CNSwitchState extends State<CNSwitch> {
  MethodChannel? _channel;
  double? _intrinsicWidth;
  double? _intrinsicHeight;

  bool? _lastValue;
  bool? _lastIsDark;
  bool? _lastEnabled;
  CNControlSize? _lastControlSize;
  Color? _lastEffectiveColor;

  int _pendingToggleId = 0;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveColor =>
      widget.color ?? CupertinoTheme.of(context).primaryColor;

  CNSwitchController? _internalController;

  CNSwitchController get _controller =>
      widget.controller ?? (_internalController ??= CNSwitchController());

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSwitch oldWidget) {
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
    // Fallback to Flutter Switch on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeSwitch';

    final creationParams = <String, dynamic>{
      'value': widget.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_effectiveColor, context),
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
    final channel = MethodChannel('CupertinoNativeSwitch_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = args?['value'] as bool?;
      if (value != null) {
        final int toggleId = ++_pendingToggleId;
        widget.onChanged?.call(value);

        // Ensure we get a frame even if setState is not called.
        SchedulerBinding.instance.scheduleFrame();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_pendingToggleId != toggleId) return;
          final channel = _channel;
          if (channel == null) return;
          if (widget.value != value) {
            channel.invokeMethod('setValue', {
              'value': widget.value,
              'animated': true,
            });
          } else {
            _lastValue = widget.value;
          }
        });
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
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

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
        _intrinsicWidth = width > -1 ? width : null;
        _intrinsicHeight = height > -1 ? height : null;
      });
    }
  }
}

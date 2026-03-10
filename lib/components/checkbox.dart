import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
class CNCheckbox extends StatefulWidget {
  /// Creates a Cupertino-native checkbox.
  const CNCheckbox({
    super.key,
    required this.state,
    this.onChanged,
    this.controlSize = CNControlSize.regular,
    this.allowMixedState = false,
    this.color,
    this.title,
  });

  /// Whether the checkbox supports a mixed state. If true, the checkbox can have a third "indeterminate" state in addition to on/off.
  final bool allowMixedState;

  /// An optional title to display next to the checkbox.
  final String? title;

  /// The state of the checkbox.
  final CNCheckboxState state;

  /// Whether the checkbox is interactive.
  bool get enabled => onChanged != null;

  /// Callback invoked when the user toggles the value.
  final ValueChanged<CNCheckboxState>? onChanged;

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

  String? _lastTitle;
  CNCheckboxState? _lastState;
  bool? _lastIsDark;
  bool? _lastEnabled;
  CNControlSize? _lastControlSize;
  Color? _lastTint;
  bool _lastAllowMixedState = false;

  // int _pendingToggleId = 0;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _tint => widget.color ?? CupertinoTheme.of(context).primaryColor;

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
      'state': widget.state.value,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_tint, context),
      'title': widget.title,
      'allowMixedState': widget.allowMixedState,
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

    if (call.method == 'stateChanged') {
      final args = call.arguments as Map?;
      final value = args?['value'] as int?;
      if (value != null) {
        widget.onChanged?.call(
          CNCheckboxState.values.firstWhere((s) => s.value == value),
        );
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastState = widget.state;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastControlSize = widget.controlSize;
    _lastTint = _tint;
    _lastTitle = widget.title;
    _lastAllowMixedState = widget.allowMixedState;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    bool requiresIntrinsicSizeUpdate = false;

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setIsEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }

    if (_lastState != widget.state) {
      await channel.invokeMethod('setState', {
        'value': widget.state.value,
        'animated': false,
      });
      _lastState = widget.state;
    }

    // Style updates (e.g., tint color)
    if (_lastTint != _tint && _tint != null && mounted) {
      await channel.invokeMethod('setTint', {
        'value': resolveColorToArgb(_tint, context),
      });
      _lastTint = _tint;
    }

    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      _lastControlSize = widget.controlSize;
      requiresIntrinsicSizeUpdate = true;
    }

    if (_lastTitle != widget.title) {
      await channel.invokeMethod('setTitle', {'value': widget.title});
      _lastTitle = widget.title;
      requiresIntrinsicSizeUpdate = true;
    }

    if (_lastAllowMixedState != widget.allowMixedState) {
      await channel.invokeMethod('setAllowsMixedState', {
        'value': widget.allowMixedState,
      });
      _lastAllowMixedState = widget.allowMixedState;
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

    if (_lastTint != _tint && _tint != null && mounted) {
      await channel.invokeMethod('setTint', {
        'value': resolveColorToArgb(_tint, context),
      });
      _lastTint = _tint;
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

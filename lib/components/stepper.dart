import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

/// A macOS native stepper rendered by the host platform.
/// On unsupported platforms, this renders a placeholder.
class CNStepper extends StatefulWidget {
  /// Creates a [CNStepper] with the given properties.
  const CNStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.isAutorepeat = true,
    this.valueWraps = false,
    this.controlSize = CNControlSize.regular,
  }) : assert(min < max),
       assert(step > 0);

  /// Current value of the stepper.
  final double value;

  /// Callback invoked when the user changes the value.
  final ValueChanged<double>? onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Increment step for each action.
  final double step;

  /// Whether holding the stepper repeats the action.
  final bool isAutorepeat;

  /// Whether the value wraps at min/max.
  final bool valueWraps;

  /// Control size of the stepper.
  final CNControlSize controlSize;

  /// Whether the stepper is enabled.
  bool get isEnabled => onChanged != null;

  @override
  State<CNStepper> createState() => _CNStepperState();
}

class _CNStepperState extends State<CNStepper> {
  MethodChannel? _channel;
  double? _intrinsicWidth;
  double? _intrinsicHeight;
  bool _lastIsDark = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeStepper';
    final creationParams = <String, dynamic>{
      'min': widget.min,
      'max': widget.max,
      'value': widget.value,
      'step': widget.step,
      'isEnabled': widget.isEnabled,
      'isAutorepeat': widget.isAutorepeat,
      'valueWraps': widget.valueWraps,
      'controlSize': widget.controlSize.name,
      'isDark': _isDark,
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final preferIntrinsicWidth = !hasBoundedWidth;

        double? width;
        if (preferIntrinsicWidth) {
          width = _intrinsicWidth ?? 20.0;
        } else {
          width = _intrinsicWidth;
        }
        final height = _intrinsicHeight ?? 26.0;

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeStepper_$id');
    _channel!.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (width != null && height != null && mounted) {
      setState(() {
        _intrinsicWidth = width > -1 ? width : null;
        _intrinsicHeight = height > -1 ? height : null;
      });
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = (args?['value'] as num?)?.toDouble();
      if (value != null) {
        widget.onChanged?.call(value);
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      final w = (args?['width'] as num?)?.toDouble();
      final h = (args?['height'] as num?)?.toDouble();
      _onIntrinsicSizeChanged(w, h);
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      await Future.delayed(Duration.zero);
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();
      _onIntrinsicSizeChanged(w, h);
    } catch (_) {}
  }

  void _cacheCurrentProps() {
    _lastIsDark = _isDark;
    _requestIntrinsicSize();
  }

  Future<void> _syncPropsToNativeIfNeeded(CNStepper oldWidget) async {
    final ch = _channel;
    if (ch == null || !mounted) return;

    var needsIntrinsicSize = false;

    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      await ch.invokeMethod('setRange', {'min': widget.min, 'max': widget.max});
    }

    final double clamped = widget.value
        .clamp(widget.min, widget.max)
        .toDouble();
    if (oldWidget.value != clamped) {
      await ch.invokeMethod('setValue', {'value': clamped});
    }

    if (oldWidget.step != widget.step) {
      await ch.invokeMethod('setIncrement', {'value': widget.step});
    }

    if (oldWidget.isEnabled != widget.isEnabled) {
      await ch.invokeMethod('setIsEnabled', {'value': widget.isEnabled});
    }

    if (oldWidget.isAutorepeat != widget.isAutorepeat) {
      await ch.invokeMethod('setIsAutorepeat', {'value': widget.isAutorepeat});
    }

    if (oldWidget.valueWraps != widget.valueWraps) {
      await ch.invokeMethod('setValueWraps', {'value': widget.valueWraps});
    }

    if (oldWidget.controlSize != widget.controlSize) {
      await ch.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      needsIntrinsicSize = true;
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    if (_lastIsDark != _isDark) {
      await ch.invokeMethod('setIsDark', {'value': _isDark});
      _lastIsDark = _isDark;
    }
  }
}

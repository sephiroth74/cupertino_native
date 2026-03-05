import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';

/// Controller for a [CNSlider] allowing imperative changes to the native
/// NSSlider/UISlider instance.
class CNSliderController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }

  /// Sets the current slider [value]. When [animated] is true, animates to it.
  Future<void> setValue(double value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {
      'value': value,
      'animated': animated,
    });
  }

  /// Sets the valid [min] and [max] range of the slider.
  Future<void> setRange({required double min, required double max}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setRange', {'min': min, 'max': max});
  }

  /// Enables or disables user interaction on the slider.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setEnabled', {'enabled': enabled});
  }
}

/// A Cupertino-native slider rendered by the host platform.
///
/// On iOS/macOS this embeds UISlider/NSSlider via a platform view and falls
/// back to Flutter's [Slider] on other platforms.
class CNSlider extends StatefulWidget {
  /// Creates a Cupertino-native slider.
  const CNSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.type = CNSliderType.linear,
    this.size = CNControlSize.regular,
    this.continuous = true,
    this.min = 0.0,
    this.max = 1.0,
    this.controller,
    this.color,
    this.thickMarks,
    this.thickMarkPosition,
    this.isVertical = false,
  });

  /// Creates a Cupertino-native circular slider.
  factory CNSlider.circular({
    required double value,
    ValueChanged<double>? onChanged,
    CNControlSize size = CNControlSize.regular,
    bool continuous = true,
    double min = 0.0,
    double max = 1.0,
    CNSliderController? controller,
    Color? color,
    int? thickMarks,
  }) => CNSlider(
    value: value,
    onChanged: onChanged,
    type: CNSliderType.circular,
    continuous: continuous,
    min: min,
    max: max,
    controller: controller,
    color: color,
    thickMarks: thickMarks,
  );

  /// Creates a Cupertino-native vertical slider.
  factory CNSlider.vertical({
    required double value,
    ValueChanged<double>? onChanged,
    CNControlSize size = CNControlSize.regular,
    bool continuous = true,
    double min = 0.0,
    double max = 1.0,
    CNSliderController? controller,
    Color? color,
    int? thickMarks,
    CNSliderTickmarkPosition? thickMarkPosition,
  }) => CNSlider(
    value: value,
    onChanged: onChanged,
    type: CNSliderType.linear,
    continuous: continuous,
    min: min,
    max: max,
    controller: controller,
    color: color,
    thickMarks: thickMarks,
    thickMarkPosition: thickMarkPosition,
    isVertical: true,
  );

  /// Size of the slider.
  final CNControlSize size;

  /// Current slider value.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Type of slider.
  final CNSliderType type;

  /// Whether the slider is continuous.
  final bool continuous;

  /// Callback when the value changes due to user interaction.
  final ValueChanged<double>? onChanged;

  /// Optional controller to imperatively interact with the native view.
  final CNSliderController? controller;

  /// General accent/tint color for the control.
  final Color? color;

  /// Number of thick marks.
  final int? thickMarks;

  /// Position of the thick marks.
  final CNSliderTickmarkPosition? thickMarkPosition;

  /// Whether the slider is vertical.
  final bool isVertical;

  @override
  State<CNSlider> createState() => _CNSliderState();
}

class _CNSliderState extends State<CNSlider> {
  MethodChannel? _channel;

  double? _lastValue;
  double? _lastMin;
  double? _lastMax;
  bool? _lastIsDark;
  Color? _lastTint;
  int? _lastThickMarks;
  CNSliderTickmarkPosition? _lastThickMarkPosition;
  CNSliderType? _lastType;
  bool? _lastContinuous;
  bool? _lastIsVertical;
  bool? _lastEnabled;
  CNControlSize? _lastSize;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  bool get _enabled => widget.onChanged != null;

  CNSliderController? _internalController;

  CNSliderController get _controller =>
      widget.controller ?? (_internalController ??= CNSliderController());

  Color? get _tint => widget.color ?? CupertinoTheme.of(context).primaryColor;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Theme may have changed
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback to Flutter Slider on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeSlider';
    final creationParams = <String, dynamic>{
      'min': widget.min,
      'max': widget.max,
      'value': widget.value,
      'isDark': _isDark,
      'enabled': _enabled,
      'type': widget.type.name,
      'isContinuous': widget.continuous,
      'isVertical': widget.isVertical,
      'tickMarks': widget.thickMarks,
      'tickMarkPosition': widget.thickMarkPosition?.name,
      'tint': resolveColorToArgb(_tint, context),
      'size': widget.size.name,
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onPlatformViewCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
        ),
        Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(),
        ),
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        // debugPrint('constraints: $constraints');
        // debugPrint('hasBoundedWidth: $hasBoundedWidth');
        // debugPrint('hasBoundedHeight: $hasBoundedHeight');
        // debugPrint('intrinsicWidth: $_intrinsicWidth');
        // debugPrint('intrinsicHeight: $_intrinsicHeight');

        // Use intrinsicWidth if type is circular, or linear and it's vertical
        final useIntrinsicWidth =
            widget.type == CNSliderType.circular || widget.isVertical;

        // Use intrinsicHeight if type is circular, or linear and it's not vertical
        final useIntrinsicHeight =
            widget.type == CNSliderType.circular || !widget.isVertical;

        final preferIntrinsicWidth = !hasBoundedWidth && useIntrinsicWidth;
        final preferIntrinsicHeight = !hasBoundedHeight && useIntrinsicHeight;

        double? width;
        if (preferIntrinsicWidth) {
          width = _intrinsicWidth ?? 44.0;
        } else {
          width = _intrinsicWidth;
        }
        double? height;
        if (preferIntrinsicHeight) {
          height = _intrinsicHeight ?? 44.0;
        } else {
          height = _intrinsicHeight;
        }

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSlider_$id');
    _channel = channel;
    _controller._attach(channel);
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = (args?['value'] as num?)?.toDouble();
      if (value != null) {
        widget.onChanged?.call(value);
        _lastValue = value;
      }
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();

      if ((w != null || h != null) && mounted) {
        setState(() {
          _intrinsicWidth = w != null && w > -1 ? w + 18 : null;
          _intrinsicHeight = h != null && h > -1 ? h + 18 : null;
        });
      }
    } catch (_) {}
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastMin = widget.min;
    _lastMax = widget.max;
    _lastEnabled = _enabled;
    _lastIsDark = _isDark;
    _lastTint = _tint;
    _lastThickMarks = widget.thickMarks;
    _lastThickMarkPosition = widget.thickMarkPosition;
    _lastType = widget.type;
    _lastContinuous = widget.continuous;
    _lastIsVertical = widget.isVertical;
    _lastSize = widget.size;
    _requestIntrinsicSize();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    bool needsIntrinsicSize = false;

    if (_lastMin != widget.min || _lastMax != widget.max) {
      await channel.invokeMethod('setRange', {
        'min': widget.min,
        'max': widget.max,
      });
      _lastMin = widget.min;
      _lastMax = widget.max;
    }

    if (_lastEnabled != _enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': _enabled});
      _lastEnabled = _enabled;
    }

    final double clamped = widget.value
        .clamp(widget.min, widget.max)
        .toDouble();
    if (_lastValue != clamped) {
      await channel.invokeMethod('setValue', {
        'value': clamped,
        'animated': false,
      });
      _lastValue = clamped;
    }

    if (_lastSize != widget.size) {
      await channel.invokeMethod('setSize', {'size': widget.size.name});
      _lastSize = widget.size;
      needsIntrinsicSize = true;
    }

    if (_lastThickMarks != widget.thickMarks) {
      await channel.invokeMethod('setTickMarks', {
        'tickMarks': widget.thickMarks,
      });
      _lastThickMarks = widget.thickMarks;
      needsIntrinsicSize = true;
    }

    if (_lastThickMarkPosition != widget.thickMarkPosition) {
      await channel.invokeMethod('setTickMarkPosition', {
        'tickMarkPosition': widget.thickMarkPosition?.name,
      });
      _lastThickMarkPosition = widget.thickMarkPosition;
      needsIntrinsicSize = true;
    }

    if (_lastType != widget.type) {
      await channel.invokeMethod('setType', {'type': widget.type.name});
      _lastType = widget.type;
      needsIntrinsicSize = true;
    }

    if (_lastContinuous != widget.continuous) {
      await channel.invokeMethod('setIsContinuous', {
        'isContinuous': widget.continuous,
      });
      _lastContinuous = widget.continuous;
    }

    if (_lastIsVertical != widget.isVertical) {
      await channel.invokeMethod('setIsVertical', {
        'isVertical': widget.isVertical,
      });
      _lastIsVertical = widget.isVertical;
      needsIntrinsicSize = true;
    }

    if (_lastTint != _tint) {
      _lastTint = _tint;
      await channel.invokeMethod('setStyle', {'tint': _tint});
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    // Resolve theme-dependent values before awaiting.
    final isDark = _isDark;

    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }

    if (_lastTint != _tint) {
      _lastTint = _tint;
      await channel.invokeMethod('setStyle', {'tint': _tint});
    }
  }
}

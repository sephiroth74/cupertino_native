import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';

/// Controller for a [CNSlider] allowing imperative changes to the native
/// NSSlider instance.
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
}

/// A Cupertino-native slider rendered by the host platform.
///
/// On macOS this embeds NSSlider via a platform view and falls
/// back to Flutter's [Slider] on other platforms.
class CNSlider extends StatefulWidget {
  /// Creates a Cupertino-native slider.
  const CNSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.sliderType = CNSliderType.linear,
    this.controlSize = CNControlSize.regular,
    this.isContinuous = true,
    this.min = 0.0,
    this.max = 1.0,
    this.controller,
    this.color,
    this.tickMarks,
    this.tickMarkPosition,
    this.isVertical = false,
    this.allowsTickMarkValuesOnly = false,
  }) : assert(min < max),
       assert(value >= min && value <= max);

  /// Creates a Cupertino-native circular slider.
  factory CNSlider.circular({
    required double value,
    ValueChanged<double>? onChanged,
    CNControlSize controlSize = CNControlSize.regular,
    bool isContinuous = true,
    double min = 0.0,
    double max = 1.0,
    CNSliderController? controller,
    Color? color,
    int? tickMarks,
    bool allowsTickMarkValuesOnly = false,
  }) => CNSlider(
    value: value,
    onChanged: onChanged,
    sliderType: CNSliderType.circular,
    isContinuous: isContinuous,
    min: min,
    max: max,
    controller: controller,
    color: color,
    tickMarks: tickMarks,
    controlSize: controlSize,
    allowsTickMarkValuesOnly: allowsTickMarkValuesOnly,
  );

  /// Creates a Cupertino-native vertical slider.
  factory CNSlider.vertical({
    required double value,
    ValueChanged<double>? onChanged,
    CNControlSize controlSize = CNControlSize.regular,
    bool isContinuous = true,
    double min = 0.0,
    double max = 1.0,
    CNSliderController? controller,
    Color? color,
    int? tickMarks,
    CNSliderTickmarkPosition? tickMarkPosition,
    bool allowsTickMarkValuesOnly = false,
  }) => CNSlider(
    value: value,
    onChanged: onChanged,
    sliderType: CNSliderType.linear,
    isContinuous: isContinuous,
    min: min,
    max: max,
    controller: controller,
    color: color,
    tickMarks: tickMarks,
    tickMarkPosition: tickMarkPosition,
    allowsTickMarkValuesOnly: allowsTickMarkValuesOnly,
    isVertical: true,
  );

  /// Size of the slider.
  final CNControlSize controlSize;

  /// Current slider value.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Type of slider.
  final CNSliderType sliderType;

  /// Whether the slider is continuous.
  final bool isContinuous;

  /// Callback when the value changes due to user interaction.
  final ValueChanged<double>? onChanged;

  /// Optional controller to imperatively interact with the native view.
  final CNSliderController? controller;

  /// General accent/tint color for the control.
  final Color? color;

  /// Number of tick marks.
  final int? tickMarks;

  /// Position of the tick marks.
  final CNSliderTickmarkPosition? tickMarkPosition;

  /// Whether the slider is vertical.
  final bool isVertical;

  /// Wheter the slider allows only tick mark values.
  final bool allowsTickMarkValuesOnly;

  // ignore: public_member_api_docs
  bool get isEnabled => onChanged != null;

  @override
  State<CNSlider> createState() => _CNSliderState();
}

class _CNSliderState extends State<CNSlider> {
  MethodChannel? _channel;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  bool get _enabled => widget.onChanged != null;

  CNSliderController? _internalController;

  CNSliderController get _controller =>
      widget.controller ?? (_internalController ??= CNSliderController());

  Color? get _tint => widget.color ?? CupertinoTheme.of(context).primaryColor;

  bool _lastIsDark = false;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSlider oldWidget) {
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
      'isEnabled': _enabled,
      'sliderType': widget.sliderType.name,
      'isContinuous': widget.isContinuous,
      'isVertical': widget.isVertical,
      'tickMarks': widget.tickMarks,
      'tickMarkPosition': widget.tickMarkPosition?.name,
      'tint': resolveColorToArgb(_tint, context),
      'controlSize': widget.controlSize.name,
      'allowsTickMarkValuesOnly': widget.allowsTickMarkValuesOnly,
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

        // Use intrinsicWidth if type is circular, or linear and it's vertical
        final useIntrinsicWidth =
            widget.sliderType == CNSliderType.circular || widget.isVertical;

        // Use intrinsicHeight if type is circular, or linear and it's not vertical
        final useIntrinsicHeight =
            widget.sliderType == CNSliderType.circular || !widget.isVertical;

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
          _intrinsicWidth = w != null && w > -1 ? w + 20 : null;
          _intrinsicHeight = h != null && h > -1 ? h + 20 : null;
        });
      }
    } catch (_) {}
  }

  void _cacheCurrentProps() {
    _lastIsDark = _isDark;
    _requestIntrinsicSize();
  }

  Future<void> _syncPropsToNativeIfNeeded(CNSlider oldWidget) async {
    final channel = _channel;
    if (channel == null || !mounted) return;

    bool needsIntrinsicSize = false;

    if (oldWidget.min != widget.min || oldWidget.max != widget.max) {
      await channel.invokeMethod('setRange', {
        'min': widget.min,
        'max': widget.max,
      });
    }

    if (oldWidget.isEnabled != widget.isEnabled) {
      await channel.invokeMethod('setIsEnabled', {'value': widget.isEnabled});
    }

    final double clamped = widget.value
        .clamp(widget.min, widget.max)
        .toDouble();
    if (oldWidget.value != clamped) {
      await channel.invokeMethod('setValue', {
        'value': clamped,
        'animated': false,
      });
    }

    if (oldWidget.controlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      debugPrint(
        'called setControlSize with value: ${widget.controlSize.name} for type: ${widget.sliderType}',
      );
      needsIntrinsicSize = true;
    }

    if (oldWidget.tickMarks != widget.tickMarks) {
      await channel.invokeMethod('setTickMarks', {'value': widget.tickMarks});
      needsIntrinsicSize = true;
    }

    if (oldWidget.tickMarkPosition != widget.tickMarkPosition) {
      await channel.invokeMethod('setTickMarkPosition', {
        'value': widget.tickMarkPosition?.name,
      });
      needsIntrinsicSize = true;
    }

    if (oldWidget.allowsTickMarkValuesOnly != widget.allowsTickMarkValuesOnly) {
      await channel.invokeMethod('setAllowsTickMarkValuesOnly', {
        'value': widget.allowsTickMarkValuesOnly,
      });
    }

    if (oldWidget.sliderType != widget.sliderType) {
      await channel.invokeMethod('setSliderType', {
        'value': widget.sliderType.name,
      });
      needsIntrinsicSize = true;
    }

    if (oldWidget.isContinuous != widget.isContinuous) {
      await channel.invokeMethod('setIsContinuous', {
        'value': widget.isContinuous,
      });
    }

    if (oldWidget.isVertical != widget.isVertical) {
      await channel.invokeMethod('setIsVertical', {'value': widget.isVertical});
      needsIntrinsicSize = true;
    }

    if (!mounted) return;
    if (oldWidget.color != widget.color) {
      await channel.invokeMethod('setTint', {
        'value': resolveColorToArgb(widget.color, context),
      });
    }

    if (needsIntrinsicSize) {
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
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const _kDefaultWidthSpinningSmall = 16.0;
const _kDefaultHeightSpinningSmall = 16.0;

const _kDefaultWidthSpinningRegular = 32.0;
const _kDefaultHeightSpinningRegular = 32.0;

const _kDefaultWidthBarSmall = 16.0;
const _kDefaultHeightBarSmall = 12.0;

const _kDefaultWidthBarRegular = 32.0;
const _kDefaultHeightBarRegular = 20.0;

/// A Cupertino-native progress indicator.
///
/// Embeds a native UIActivityIndicatorView/NSProgressIndicator for authentic visuals and behavior on macOS.
/// Falls back to [CupertinoActivityIndicator] on other platforms.
class CNProgressIndicator extends StatefulWidget {
  /// The style of the progress indicator.
  final CNProgressStyle style;

  /// The size of the progress indicator.
  final CNControlSize size;

  /// The value of the progress indicator.
  final double value;

  /// The minimum value of the progress indicator.
  final double minValue;

  /// The maximum value of the progress indicator.
  final double maxValue;

  /// Whether the progress indicator is indeterminate.
  final bool indeterminate;

  /// Default constructor for a progress indicator.
  const CNProgressIndicator({
    super.key,
    required this.style,
    required this.indeterminate,
    this.size = CNControlSize.regular,
    this.value = 0.0,
    this.minValue = 0.0,
    this.maxValue = 1.0,
  });

  /// Creates a circular progress indicator.
  factory CNProgressIndicator.circular({
    required bool indeterminate,
    CNControlSize size = CNControlSize.regular,
    double value = 0.0,
    double minValue = 0.0,
    double maxValue = 1.0,
  }) => CNProgressIndicator(
    style: CNProgressStyle.spinning,
    size: size,
    indeterminate: indeterminate,
    value: value,
    minValue: minValue,
    maxValue: maxValue,
  );

  /// Creates a bar progress indicator.
  factory CNProgressIndicator.bar({
    required bool indeterminate,
    CNControlSize size = CNControlSize.regular,
    double value = 0.0,
    double minValue = 0.0,
    double maxValue = 1.0,
  }) => CNProgressIndicator(
    style: CNProgressStyle.bar,
    size: size,
    indeterminate: indeterminate,
    value: value,
    minValue: minValue,
    maxValue: maxValue,
  );

  @override
  State<CNProgressIndicator> createState() => _CNProgressIndicatorState();
}

class _CNProgressIndicatorState extends State<CNProgressIndicator> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  late CNProgressStyle _lastStyle;
  late CNControlSize _lastControlSize;
  late bool _lastIndeterminate;
  late double _lastValue;
  late double _lastMinValue;
  late double _lastMaxValue;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  @override
  void initState() {
    super.initState();
    _lastStyle = widget.style;
    _lastControlSize = widget.size;
    _lastIndeterminate = widget.indeterminate;
    _lastValue = widget.value;
    _lastMinValue = widget.minValue;
    _lastMaxValue = widget.maxValue;
  }

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeProgressIndicator';

    final creationParams = <String, dynamic>{
      'progressStyle': widget.style.name,
      'progressSize': widget.size.name,
      'progressIndeterminate': widget.indeterminate,
      'progressValue': widget.value,
      'progressMinValue': widget.minValue,
      'progressMaxValue': widget.maxValue,
      'isDark': _isDark,
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final preferIntrinsicWidth = !hasBoundedWidth;
        final preferIntrinsicHeight = !hasBoundedHeight;
        double? width;
        if (preferIntrinsicWidth) {
          width =
              _intrinsicWidth ??
              (_lastStyle == CNProgressStyle.spinning
                  ? (_lastControlSize.index >= CNControlSize.regular.index
                        ? _kDefaultWidthSpinningRegular
                        : _kDefaultWidthSpinningSmall)
                  : (_lastControlSize.index >= CNControlSize.regular.index
                        ? _kDefaultWidthBarRegular
                        : _kDefaultWidthBarSmall));
        } else {
          width = hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth;
        }
        double? height;
        if (preferIntrinsicHeight) {
          height =
              _intrinsicHeight ??
              (_lastStyle == CNProgressStyle.spinning
                  ? (_lastControlSize.index >= CNControlSize.regular.index
                        ? _kDefaultHeightSpinningRegular
                        : _kDefaultHeightSpinningSmall)
                  : (_lastControlSize.index >= CNControlSize.regular.index
                        ? _kDefaultHeightBarRegular
                        : _kDefaultHeightBarSmall));
        } else {
          height = hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight;
        }

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeProgressIndicator_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastIsDark = _isDark;
    _lastStyle = widget.style;
    _lastControlSize = widget.size;
    _lastIndeterminate = widget.indeterminate;
    _lastValue = widget.value;
    _lastMinValue = widget.minValue;
    _lastMaxValue = widget.maxValue;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'changed':
        debugPrint('changed');
        break;
    }
    return null;
  }

  // ignore: unused_element
  Future<void> _startAnimation() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      await ch.invokeMethod('startAnimation');
    } catch (e) {
      debugPrint('Failed to start animation: $e');
    }
  }

  // ignore: unused_element
  Future<void> _stopAnimation() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      await ch.invokeMethod('stopAnimation');
    } catch (e) {
      debugPrint('Failed to stop animation: $e');
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();

      if (w != null && h != null && mounted) {
        setState(() {
          if (w > 0) {
            _intrinsicWidth = w;
          } else {
            _intrinsicWidth = null;
          }
          if (h > 0) {
            _intrinsicHeight = h;
          } else {
            _intrinsicHeight = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture context-derived values before any awaits
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    debugPrint('syncPropsToNativeIfNeeded');

    final ch = _channel;
    if (ch == null) return;
    bool needsIntrinsicSize = false;

    if (_lastStyle != widget.style) {
      await ch.invokeMethod('updateProgress', {
        'progressStyle': widget.style.name,
      });
      _lastStyle = widget.style;
    }
    if (_lastControlSize != widget.size) {
      await ch.invokeMethod('updateProgress', {
        'progressSize': widget.size.name,
      });
      _lastControlSize = widget.size;
      needsIntrinsicSize = true;
    }
    if (_lastIndeterminate != widget.indeterminate) {
      await ch.invokeMethod('updateProgress', {
        'progressIndeterminate': widget.indeterminate,
      });
      _lastIndeterminate = widget.indeterminate;
    }
    if (_lastValue != widget.value) {
      await ch.invokeMethod('updateProgress', {'progressValue': widget.value});
      _lastValue = widget.value;
    }
    if (_lastMinValue != widget.minValue) {
      await ch.invokeMethod('updateProgress', {
        'progressMinValue': widget.minValue,
      });
      _lastMinValue = widget.minValue;
    }
    if (_lastMaxValue != widget.maxValue) {
      await ch.invokeMethod('updateProgress', {
        'progressMaxValue': widget.maxValue,
      });
      _lastMaxValue = widget.maxValue;
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }
}

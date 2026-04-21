import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A MacOS native level indicator rendered by the host platform.
/// On unsupported platforms, this renders a placeholder.
class CNLevelIndicator extends StatefulWidget {
  /// Level indicator style. This controls the overall appearance of the control and
  /// behavior of the level indicator.
  final CNLevelIndicatorStyle levelIndicatorStyle;

  /// Whether the level indicator sends value change events continuously as the
  final bool isContinuous;

  /// Whether the level indicator is editable by the user. When false, the control
  final bool isEditable;

  /// Called when the user changes the value of the level indicator. The new
  final ValueChanged<double>? onChanged;

  /// The current value of the level indicator. This is clamped to be between
  final double value;

  /// The minimum value of the level indicator. Defaults to 0.0.
  final double minValue;

  /// The maximum value of the level indicator. Defaults to 1.0.
  final double maxValue;

  /// The fill color of the level indicator.
  final Color? fillColor;

  /// The warning color of the level indicator, used when the value is in a
  final Color? warningColor;

  /// The critical color of the level indicator, used when the value is in a
  final Color? criticalColor;

  /// The value at which the level indicator starts showing the warning color. If
  /// null, the warning color is not used.
  final double? warningValue;

  /// The value at which the level indicator starts showing the critical color. If
  /// null, the critical color is not used.
  final double? criticalValue;

  /// Whether the level indicator is enabled. This is true if [onChanged] is not null.
  bool get isEnabled => onChanged != null;

  /// Creates a [CNLevelIndicator] with the given properties.
  const CNLevelIndicator({
    super.key,
    required this.levelIndicatorStyle,
    required this.value,
    this.minValue = 0.0,
    this.maxValue = 10.0,
    this.fillColor,
    this.warningColor,
    this.criticalColor,
    this.isContinuous = true,
    this.isEditable = true,
    required this.onChanged,
    this.warningValue,
    this.criticalValue,
  });

  @override
  State<CNLevelIndicator> createState() => _CNLevelIndicatorState();
}

class _CNLevelIndicatorState extends State<CNLevelIndicator> {
  MethodChannel? channel;
  double? intrinsicWidth;
  double? intrinsicHeight;
  bool lastIsDark = false;

  bool get isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    // Fallback to Flutter Slider on unsupported platforms.
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeLevelIndicator';
    final creationParams = <String, dynamic>{
      'min': widget.minValue,
      'max': widget.maxValue,
      'value': widget.value,
      'isDark': isDark,
      'isEnabled': widget.isEnabled,
      'levelIndicatorStyle': widget.levelIndicatorStyle.name,
      'isContinuous': widget.isContinuous,
      'isEditable': widget.isEditable,
      'fillColor': resolveColorToArgb(widget.fillColor, context),
      'warningColor': resolveColorToArgb(widget.warningColor, context),
      'criticalColor': resolveColorToArgb(widget.criticalColor, context),
      'warningValue': widget.warningValue,
      'criticalValue': widget.criticalValue,
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: onPlatformViewCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
        ),
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;

        final preferIntrinsicWidth = !hasBoundedWidth;

        double? width;
        if (preferIntrinsicWidth) {
          width = intrinsicWidth ?? 44.0;
        } else {
          width = intrinsicWidth;
        }
        double? height;
        height = intrinsicHeight ?? 24.0;

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  void onPlatformViewCreated(int id) {
    channel = MethodChannel('CupertinoNativeLevelIndicator_$id');
    channel!.setMethodCallHandler(onMethodCall);
    cacheCurrentProps();
    syncBrightnessIfNeeded();
  }

  Future<dynamic> onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final value = (args?['value'] as num?)?.toDouble();
      if (value != null) {
        widget.onChanged?.call(value);
      }
    }
    return null;
  }

  Future<void> requestIntrinsicSize() async {
    final ch = channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();

      if ((w != null || h != null) && mounted) {
        debugPrint('Received intrinsic size from native: width=$w, height=$h');
        setState(() {
          intrinsicWidth = w != null && w > -1 ? w + 20 : null;
          intrinsicHeight = h != null && h > -1 ? h + 20 : null;
        });
      }
    } catch (_) {}
  }

  void cacheCurrentProps() {
    lastIsDark = isDark;
    requestIntrinsicSize();
  }

  Future<void> syncPropsToNativeIfNeeded(CNLevelIndicator oldWidget) async {
    final ch = channel;
    if (ch == null || !mounted) return;

    bool needsIntrinsicSize = false;

    if (oldWidget.minValue != widget.minValue ||
        oldWidget.maxValue != widget.maxValue) {
      await ch.invokeMethod('setRange', {
        'min': widget.minValue,
        'max': widget.maxValue,
      });
    }

    final double clamped = widget.value
        .clamp(widget.minValue, widget.maxValue)
        .toDouble();
    if (oldWidget.value != clamped) {
      await ch.invokeMethod('setValue', {'value': clamped, 'animated': false});
    }

    if (oldWidget.isEnabled != widget.isEnabled) {
      await ch.invokeMethod('setIsEnabled', {'value': widget.isEnabled});
    }

    if (oldWidget.levelIndicatorStyle != widget.levelIndicatorStyle) {
      await ch.invokeMethod('setLevelIndicatorStyle', {
        'value': widget.levelIndicatorStyle.name,
      });
      needsIntrinsicSize = true;
    }

    if (oldWidget.isContinuous != widget.isContinuous) {
      await ch.invokeMethod('setIsContinuous', {'value': widget.isContinuous});
    }

    if (oldWidget.isEditable != widget.isEditable) {
      await ch.invokeMethod('setIsEditable', {'value': widget.isEditable});
    }

    if (!mounted) return;
    if (oldWidget.fillColor != widget.fillColor) {
      // ignore: use_build_context_synchronously
      await ch.invokeMethod('setFillColor', {
        'value': resolveColorToArgb(widget.fillColor, context),
      });
    }

    if (!mounted) return;
    if (oldWidget.warningColor != widget.warningColor) {
      // ignore: use_build_context_synchronously
      await ch.invokeMethod('setWarningColor', {
        'value': resolveColorToArgb(widget.warningColor, context),
      });
    }

    if (!mounted) return;
    if (oldWidget.criticalColor != widget.criticalColor) {
      // ignore: use_build_context_synchronously
      await ch.invokeMethod('setCriticalColor', {
        'value': resolveColorToArgb(widget.criticalColor, context),
      });
    }

    if (!mounted) return;
    if (oldWidget.warningValue != widget.warningValue) {
      await ch.invokeMethod('setWarningValue', {'value': widget.warningValue});
    }

    if (!mounted) return;
    if (oldWidget.criticalValue != widget.criticalValue) {
      await ch.invokeMethod('setCriticalValue', {
        'value': widget.criticalValue,
      });
    }

    if (!mounted) return;
    if (needsIntrinsicSize) {
      requestIntrinsicSize();
    }
  }

  Future<void> syncBrightnessIfNeeded() async {
    final ch = channel;
    if (ch == null) return;

    if (lastIsDark != isDark) {
      await ch.invokeMethod('setIsDark', {'value': isDark});
      lastIsDark = isDark;
    }
  }
}

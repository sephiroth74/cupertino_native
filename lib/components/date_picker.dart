import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Callback for when the date picker value changes, providing the new date and the time interval since the last change.
typedef CNDatePickerChanged = void Function(DateTime date, Duration interval);

/// A Cupertino-style date picker widget that wraps the native NSDatePicker on macOS.
class CNDatePicker extends StatefulWidget {
  /// The mode of the date picker, determining whether it allows selection of a single date or a date range.
  final CNDatePickerMode datePickerMode;

  /// The style of the date picker, determining its visual appearance and layout.
  final CNDatePickerStyle datePickerStyle;

  /// The elements to display in the date picker, such as year, month, day, hour, minute, etc.
  final List<CNDatePickerElements> datePickerElements;

  /// Whether the date picker should have a border.
  final bool isBordered;

  /// The initial date value of the date picker. For range mode, this represents the start date.
  final DateTime? dateValue;

  /// Whether the date picker should draw a background.
  final bool drawsBackground;

  /// The background color of the date picker. If null, the default system background color is used.
  final Color? backgroundColor;

  /// The text color of the date picker. If null, the default system text color is used.
  final Color? textColor;

  /// The minimum selectable date in the date picker. If null, there is no minimum limit.
  final DateTime? minDate;

  /// The maximum selectable date in the date picker. If null, there is no maximum limit.
  final DateTime? maxDate;

  /// The locale to use for the date picker. If null, the system locale is used.
  final Locale? locale;

  /// Whether the date picker is enabled for user interaction. If false, the date picker is disabled and does not respond to user input.
  final CNDatePickerChanged? onDateChanged;

  /// An optional fixed width for the date picker. If null, the date picker will size itself based on its content and available space.
  final double? width;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Creates a new CNDatePicker with the specified configuration.
  const CNDatePicker({
    super.key,
    this.datePickerMode = CNDatePickerMode.single,
    required this.datePickerStyle,
    required this.datePickerElements,
    required this.onDateChanged,
    this.isBordered = true,
    this.drawsBackground = true,
    this.dateValue,
    this.backgroundColor,
    this.textColor,
    this.minDate,
    this.maxDate,
    this.font,
    this.locale,
    this.width,
  });

  @override
  State<CNDatePicker> createState() => _CNDatePickerState();
}

class _CNDatePickerState extends State<CNDatePicker> {
  MethodChannel? _channel;

  bool _lastIsDark = false;
  bool _lastIsEnabled = false;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  bool get _isEnabled => widget.onDateChanged != null;

  double? _intrinsicWidth;
  double? _intrinsicHeight;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeDatePicker';

    final creationParams = <String, dynamic>{
      'isDark': _isDark,
      'datePickerMode': widget.datePickerMode.name,
      'datePickerStyle': widget.datePickerStyle.name,
      'datePickerElements': widget.datePickerElements
          .map((e) => e.name)
          .toList(),
      'isBordered': widget.isBordered,
      'dateValue': widget.dateValue?.millisecondsSinceEpoch,
      'drawsBackground': widget.drawsBackground,
      'backgroundColor': resolveColorToArgb(widget.backgroundColor, context),
      'textColor': resolveColorToArgb(widget.textColor, context),
      'minDate': widget.minDate?.millisecondsSinceEpoch,
      'maxDate': widget.maxDate?.millisecondsSinceEpoch,
      'font': widget.font?.toMap(),
      'locale': widget.locale?.toLanguageTag(),
      'isEnabled': _isEnabled,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        bool hasBoundedWidth = constraints.hasBoundedWidth;
        bool hasBoundedHeight = constraints.hasBoundedHeight;

        double? width;
        double? height;

        if (widget.datePickerStyle == CNDatePickerStyle.clockAndCalendar) {
          // we must use the intrinsic sizes, or the max available constraints, in case the intrinsic sizes are not available yet
          width =
              _intrinsicWidth ??
              (hasBoundedWidth ? constraints.maxWidth : null);
          height =
              _intrinsicHeight ??
              (hasBoundedHeight ? constraints.maxHeight : null);
        } else {
          // for textField styles we can expand to fill the available width, but height should be intrinsic or max 32
          width =
              widget.width ??
              _intrinsicWidth ??
              (hasBoundedWidth ? constraints.maxWidth : null);
          height =
              _intrinsicHeight ??
              (hasBoundedHeight ? constraints.maxHeight : 21.0);
        }

        if (hasBoundedWidth && width != null) {
          width = width.clamp(0.0, constraints.maxWidth);
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: width,
            height: height,
            child: AppKitView(
              viewType: viewType,
              creationParamsCodec: const StandardMessageCodec(),
              creationParams: creationParams,
              onPlatformViewCreated: _onPlatformViewCreated,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant CNDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeDatePicker_$id');
    channel.setMethodCallHandler(_onMethodCall);
    _channel = channel;
    _cacheLastValues();
    _requestIntrinsicSize();
  }

  Future<void> _onMethodCall(MethodCall call) async {
    // debugPrint('Received method call: ${call.method} with arguments: ${call.arguments}');
    if (call.method == 'onDateChanged') {
      final args = call.arguments as Map;
      final timestamp = args['timestamp'] as num;
      final interval = args['interval'] as num;
      final duration = Duration(milliseconds: interval.toInt());
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
      widget.onDateChanged?.call(date, duration);
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

  void _cacheLastValues() {
    _lastIsDark = _isDark;
    _lastIsEnabled = _isEnabled;
  }

  Future<void> _syncPropsToNativeIfNeeded(CNDatePicker oldWidget) async {
    final channel = _channel;
    if (channel == null) return;

    bool requiresIntrinsicSizeUpdate = false;

    if (_lastIsEnabled != _isEnabled) {
      await channel.invokeMethod('setIsEnabled', {'value': _isEnabled});
      _lastIsEnabled = _isEnabled;
    }

    if (!mounted) return;
    if (oldWidget.datePickerStyle != widget.datePickerStyle) {
      await channel.invokeMethod('setDatePickerStyle', {
        'value': widget.datePickerStyle.name,
      });
      requiresIntrinsicSizeUpdate = true;
    }

    if (!mounted) return;
    // check if the datePickerElements lists are different, ignoring order
    final oldElementsSet = oldWidget.datePickerElements.toSet();
    final newElementsSet = widget.datePickerElements.toSet();

    if (oldElementsSet.length != newElementsSet.length ||
        !oldElementsSet.containsAll(newElementsSet)) {
      await channel.invokeMethod('setDatePickerElements', {
        'value': widget.datePickerElements.map((e) => e.name).toList(),
      });
      requiresIntrinsicSizeUpdate = true;
    }

    if (!mounted) return;
    if (oldWidget.width != widget.width) {
      requiresIntrinsicSizeUpdate = true;
    }

    if (oldWidget.font != widget.font) {
      await channel.invokeMethod('setFont', {'value': widget.font?.toMap()});
      requiresIntrinsicSizeUpdate = true;
    }

    if (!mounted) return;
    if (oldWidget.backgroundColor != widget.backgroundColor) {
      await channel.invokeMethod('setBackgroundColor', {
        'value': resolveColorToArgb(widget.backgroundColor, context),
      });
    }

    if (!mounted) return;
    if (oldWidget.textColor != widget.textColor) {
      await channel.invokeMethod('setTextColor', {
        'value': resolveColorToArgb(widget.textColor, context),
      });
    }

    if (!mounted) return;
    if (oldWidget.minDate != widget.minDate) {
      await channel.invokeMethod('setMinDate', {
        'value': widget.minDate?.millisecondsSinceEpoch,
      });
    }

    if (!mounted) return;
    if (oldWidget.maxDate != widget.maxDate) {
      await channel.invokeMethod('setMaxDate', {
        'value': widget.maxDate?.millisecondsSinceEpoch,
      });
    }

    if (!mounted) return;
    if (oldWidget.locale != widget.locale) {
      await channel.invokeMethod('setLocale', {
        'value': widget.locale?.toLanguageTag(),
      });
    }

    if (!mounted) return;
    if (oldWidget.isBordered != widget.isBordered) {
      await channel.invokeMethod('setIsBordered', {'value': widget.isBordered});
    }

    if (!mounted) return;
    if (oldWidget.drawsBackground != widget.drawsBackground) {
      await channel.invokeMethod('setDrawsBackground', {
        'value': widget.drawsBackground,
      });
    }

    if (!mounted) return;
    if (oldWidget.dateValue != widget.dateValue) {
      await channel.invokeMethod('setDateValue', {
        'value': widget.dateValue?.millisecondsSinceEpoch,
      });
    }

    if (!mounted) return;
    if (oldWidget.datePickerMode != widget.datePickerMode) {
      await channel.invokeMethod('setDatePickerMode', {
        'value': widget.datePickerMode.name,
      });
    }

    if (!mounted) return;
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
  }
}

/// Date picker elements, used to specify which components are shown in the date picker.
enum CNDatePickerElements {
  /// The date picker displays the hour and minute components.
  hourMinute,

  /// The date picker displays the hour, minute, and second components.
  hourMinuteSecond,

  /// The date picker displays the time zone component.
  timeZone,

  /// The date picker displays the year and month components.
  yearMonth,

  /// The date picker displays the year, month, and day components.
  yearMonthDay,

  /// The date picker displays the era component.
  era,
}

/// A wrapper for NSDatePicker.Mode
enum CNDatePickerMode {
  /// The date picker allows selection of a single date and time.
  single,

  /// The date picker allows selection of a date range.
  range,
}

/// A wrapper for NSDatePicker.Style, with some custom styles that combine multiple native styles.
enum CNDatePickerStyle {
  /// The date picker displays a text field and stepper.
  textFieldAndStepper,

  /// The date picker displays a clock and calendar.
  clockAndCalendar,

  /// The date picker displays a text field.
  textField,
}

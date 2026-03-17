import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

typedef CNDatePickerChanged = void Function(DateTime date, Duration interval);

class CNDatePicker extends StatefulWidget {
  final CNDatePickerMode datePickerMode;
  final CNDatePickerStyle datePickerStyle;
  final List<CNDatePickerElements> datePickerElements;
  final bool isBordered;
  final DateTime? dateValue;
  final bool drawsBackground;
  final Color? backgroundColor;
  final Color? textColor;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Locale? locale;
  final CNDatePickerChanged? onDateChanged;
  final double? width;

  /// Optional native NSFont descriptor.
  final CNFont? font;

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

        debugPrint('constraints: $constraints');
        debugPrint(
          'hasBoundedWidth: $hasBoundedWidth, hasBoundedHeight: $hasBoundedHeight',
        );
        debugPrint('Using width: $width, height: $height');

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

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeDatePicker_$id');
    channel.setMethodCallHandler(_onMethodCall);
    _channel = channel;
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
}

enum CNDatePickerElements {
  hourMinute,
  hourMinuteSecond,
  timeZone,
  yearMonth,
  yearMonthDay,
  era,
}

enum CNDatePickerMode { single, range }

enum CNDatePickerStyle { textFieldAndStepper, clockAndCalendar, textField }

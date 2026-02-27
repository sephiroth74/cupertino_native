import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const double _kDefaultHeight = 24.0;
const double _kDefaultWidth = 44.0;

/// A Cupertino color well.
/// Embeds a native NSColorWell for authentic visuals and behavior on macOS.
/// Falls back to [CupertinoColorPicker] on other platforms.

class CNColorWell extends StatefulWidget {
  /// Creates a color well.
  ///
  /// The [color] parameter is optional and defaults to [Colors.transparent].
  /// The [onColorChanged] parameter is optional and defaults to null.
  /// The [style] parameter is optional and defaults to [CNColorWellStyle.regular].
  ///
  const CNColorWell({super.key, this.color, this.onColorChanged, this.style = CNColorWellStyle.regular});

  /// The color of the color well.
  final Color? color;

  /// The callback that is called when the color well's color changes.
  final ValueChanged<Color>? onColorChanged;

  /// The style of the color well.
  final CNColorWellStyle style;

  @override
  State<CNColorWell> createState() => _CNColorWellState();
}

class _CNColorWellState extends State<CNColorWell> {
  MethodChannel? _channel;
  bool _lastIsDark = false;
  Color? _lastColor;
  CNColorWellStyle _lastStyle = CNColorWellStyle.regular;

  double? _intrinsicWidth;

  double? _intrinsicHeight;

  bool get isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  bool get enabled => widget.onColorChanged != null;

  @override
  void didUpdateWidget(covariant CNColorWell oldWidget) {
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
    const viewType = 'CupertinoNativeColorWell';
    final creationParams = <String, dynamic>{
      'color': resolveColorToArgb(widget.color, context),
      'style': widget.style.name,
      'enabled': enabled,
      'isDark': isDark,
      'continuous': true,
    };

    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return Placeholder();
    }

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        // Forward taps to native; let Flutter keep drags for scrolling.
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasWidth = constraints.hasBoundedWidth;
        final hasHeight = constraints.hasBoundedHeight;
        final width = hasWidth ? constraints.maxWidth : _kDefaultWidth;
        final height = hasHeight ? constraints.maxHeight : _kDefaultHeight;

        if (_intrinsicWidth != null && _intrinsicHeight != null && !hasWidth && !hasHeight) {
          debugPrint('Using intrinsic size: $_intrinsicWidth x $_intrinsicHeight');
          return SizedBox(width: _intrinsicWidth, height: _intrinsicHeight, child: platformView);
        }

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeColorWell_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastIsDark = isDark;
    _lastColor = widget.color;
    _lastStyle = widget.style;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'colorChanged':
        if (widget.onColorChanged != null) {
          final colorValue = call.arguments as int;
          widget.onColorChanged!(Color(colorValue));
        }
        break;
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

      if (w != null && h != null && mounted) {
        setState(() {
          _intrinsicWidth = w;
          _intrinsicHeight = h;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    bool needsIntrinsicSize = false;

    if (_lastColor != widget.color) {
      ch.invokeMethod('setColor', {'color': resolveColorToArgb(widget.color, context)});
      _lastColor = widget.color;
    }

    if (_lastStyle != widget.style) {
      ch.invokeMethod('setStyle', {'style': widget.style.name});
      _lastStyle = widget.style;
      needsIntrinsicSize = true;
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }
}

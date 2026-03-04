import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/style/path_control_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kDefaultWidth = 44.0;
const _kDefaultHeight = 24.0;

/// A native macOS path control.
///
/// This widget is a wrapper around the native macOS path control.
///
/// ```dart
/// CNPathControl(
///   url: Uri.parse("/Users/alessandro/Documents"),
///   onPressed: (url) {
///     print(url);
///   },
/// )
/// ```
class CNPathControl extends StatefulWidget {
  /// The path to display.
  final Uri url;

  /// Whether the path is a directory.
  final bool isDirectory;

  /// Callback for when a path is pressed.
  final ValueChanged<String>? onPressed;

  /// The size of the control.
  final CNControlSize controlSize;

  /// The style of the control.
  final CNPathControlStyle controlStyle;

  /// Accent/tint color.
  final Color? tint;

  /// Allowed file types (extensions).
  final List<String>? allowedTypes;

  const CNPathControl({
    super.key,
    required this.url,
    required this.isDirectory,
    required this.onPressed,
    this.tint,
    this.controlSize = CNControlSize.regular,
    this.controlStyle = CNPathControlStyle.standard,
    this.allowedTypes,
  });

  @override
  State<CNPathControl> createState() => _CNPathControlState();
}

class _CNPathControlState extends State<CNPathControl> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  Uri? _lastUri;
  bool? _lastIsDirectory;
  double? _intrinsicWidth;
  double? _intrinsicHeight;
  CNPathControlStyle? _lastStyle;
  CNControlSize? _lastControlSize;
  List<String>? _lastAllowedTypes;
  int? _lastTint;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNPathControl oldWidget) {
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
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativePathControl';

    final creationParams = <String, dynamic>{
      'path': widget.url.toString(),
      'style': widget.controlStyle.name,
      'controlSize': widget.controlSize.name,
      'isDirectory': widget.isDirectory,
      'tint': resolveColorToArgb(_effectiveTint, context),
      'enabled': widget.onPressed != null,
      'allowedTypes': widget.allowedTypes,
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
          width = _intrinsicWidth ?? _kDefaultWidth;
        } else {
          width = _intrinsicWidth;
        }
        double? height;
        if (preferIntrinsicHeight) {
          height = _intrinsicHeight ?? _kDefaultHeight;
        } else {
          height = _intrinsicHeight;
        }

        return SizedBox(width: width, height: height, child: platformView);
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePathControl_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastUri = widget.url;
    _lastIsDirectory = widget.isDirectory;
    _lastStyle = widget.controlStyle;
    _lastControlSize = widget.controlSize;
    _lastAllowedTypes = widget.allowedTypes;
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.onPressed != null) {
          widget.onPressed!(call.arguments);
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

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture context-derived values before any awaits
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    // Also propagate theme-driven tint changes (e.g., accent color changes)
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final tint = resolveColorToArgb(_effectiveTint, context);
    bool needsIntrinsicSize = false;

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setTint', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.controlStyle) {
      await ch.invokeMethod('setStyle', {'style': widget.controlStyle.name});
      _lastStyle = widget.controlStyle;
    }
    if (_lastControlSize != widget.controlSize) {
      await ch.invokeMethod('setControlSize', {
        'controlSize': widget.controlSize.name,
      });
      _lastControlSize = widget.controlSize;
      needsIntrinsicSize = true;
    }
    // Enabled state
    await ch.invokeMethod('setEnabled', {
      'enabled': (widget.onPressed != null),
    });

    if (_lastUri != widget.url || _lastIsDirectory != widget.isDirectory) {
      await ch.invokeMethod('setPath', {
        'path': widget.url.toString(),
        'isDirectory': widget.isDirectory,
      });
      _lastUri = widget.url;
      _lastIsDirectory = widget.isDirectory;
      needsIntrinsicSize = true;
    }

    if (_lastAllowedTypes != widget.allowedTypes) {
      await ch.invokeMethod('setAllowedTypes', {
        'allowedTypes': widget.allowedTypes,
      });
      _lastAllowedTypes = widget.allowedTypes;
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }
}

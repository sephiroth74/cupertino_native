import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// A native menu button backed by SwiftUI on macOS.
///
/// This widget renders a native menu button and supports nested submenus,
/// optional item subtitles, and SF Symbol icons.
class CNMenuButton extends StatefulWidget {
  /// Creates a generic menu button.
  const CNMenuButton({
    super.key,
    required this.menu,
    required this.onSelected,
    this.label,
    this.systemImage,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.focusable = false,
    this.tint,
    this.symbolRenderingMode,
  }) : assert(label != null || systemImage != null, 'CNMenuButton requires a label or systemImage.'),
       super();

  /// Control size for the native button.
  final CNControlSize controlSize;

  /// Whether the native button should be focusable.
  final bool focusable;

  /// Optional text label shown on the button.
  final String? label;

  /// The menu model to show.
  final CNMenu menu;

  /// Visual style applied to the button.
  final CNMenuStyle menuStyle;

  /// Called when a leaf menu item is selected.
  final ValueChanged<CNMenuItem> onSelected;

  /// Optional symbol rendering mode applied to the button icon.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// Optional SF Symbol icon shown on the button.
  final String? systemImage;

  /// Optional tint color applied to the button and icon.
  final Color? tint;

  @override
  State<CNMenuButton> createState() => _CNMenuButtonState();
}

class _CNMenuButtonState extends State<CNMenuButton> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  bool? _lastFocusable;
  String? _lastIconName;
  bool _lastIsDark = false;
  CNMenu? _lastMenu;
  CNMenuStyle? _lastStyle;
  CNSymbolRenderingMode? _lastSymbolRenderingMode;
  Color? _lastTint;
  String? _lastTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onCreated(int id) {
    _channel = MethodChannel('CupertinoNativeMenuButton_$id')..setMethodCallHandler(_onMethodCall);
    _lastIsDark = CNTheme.of(context).brightness == Brightness.dark;
    _lastMenu = widget.menu;
    _lastTitle = widget.label;
    _lastStyle = widget.menuStyle;
    _lastFocusable = widget.focusable;
    _lastTint = widget.tint;
    _lastSymbolRenderingMode = widget.symbolRenderingMode;
    _lastIconName = widget.systemImage;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map<dynamic, dynamic>?;
      final identifier = args?['identifier'] as String?;
      if (identifier != null) {
        final item = widget.menu.findItemByIdentifier(identifier);
        if (item != null && item.enabled) {
          widget.onSelected(item);
        }
      }
    }
    return null;
  }

  Future<void> _syncBrightnessIfNeeded() async {
    debugPrint('_syncBrightnessIfNeeded()');

    final ch = _channel;
    if (ch == null) return;

    final isDark = CNTheme.of(context).brightness == Brightness.dark;

    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setIsDark', {'value': isDark});
      _lastIsDark = isDark;
    }
  }

  Future<void> _syncPropsToNativeIfNeeded(CNMenuButton oldWidget) async {
    debugPrint('_syncPropsToNativeIfNeeded()');
    final ch = _channel;
    if (ch == null) return;

    final currentMenuMap = widget.menu.toMap(context);

    if (_lastMenu != widget.menu) {
      _lastMenu = widget.menu;
      await ch.invokeMethod('setMenu', {'menu': currentMenuMap});
    }

    if (_lastStyle != widget.menuStyle) {
      _lastStyle = widget.menuStyle;
      await ch.invokeMethod('setStyle', {'menuStyle': widget.menuStyle.name});
    }

    if (_lastFocusable != widget.focusable) {
      _lastFocusable = widget.focusable;
      await ch.invokeMethod('setFocusable', {'focusable': widget.focusable});
    }

    if (_lastTitle != widget.label) {
      _lastTitle = widget.label;
      await ch.invokeMethod('setLabel', {'label': widget.label});
    }

    if (_lastIconName != oldWidget.systemImage) {
      _lastIconName = widget.systemImage;
      await ch.invokeMethod('setSystemImage', {'systemImage': widget.systemImage});
    }

    if (_lastTint != widget.tint) {
      _lastTint = widget.tint;
      if (mounted) {
        await ch.invokeMethod('setTint', {'tint': resolveColorToArgb(_lastTint, context)});
      }
    }

    if (_lastSymbolRenderingMode != widget.symbolRenderingMode) {
      _lastSymbolRenderingMode = widget.symbolRenderingMode;
      await ch.invokeMethod('setSymbolRenderingMode', {'symbolRenderingMode': widget.symbolRenderingMode?.name});
    }

    if (oldWidget.controlSize != widget.controlSize) {
      await ch.invokeMethod('setControlSize', {'controlSize': widget.controlSize.name});
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();
      if (mounted && w != null && h != null) {
        setState(() {
          _intrinsicWidth = w;
          _intrinsicHeight = h;
        });
      }
    } catch (_) {
      // Ignored.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    final isDark = CNTheme.of(context).brightness == Brightness.dark;

    final creationParams = <String, dynamic>{
      'menu': widget.menu.toMap(context),
      'label': widget.label,
      'style': widget.menuStyle.name,
      'controlSize': widget.controlSize.name,
      'focusable': widget.focusable,
      'isDark': isDark,
      'systemImage': widget.systemImage,
      'tint': resolveColorToArgb(widget.tint, context),
      'symbolRenderingMode': widget.symbolRenderingMode?.name,
    };

    // Constrain the platform view size to avoid infinite width when this
    // button is placed in unbounded horizontal layouts like rows.
    final height = _intrinsicHeight ?? 28.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('constraints: $constraints, intrinsicWidth: $_intrinsicWidth, intrinsicHeight: $_intrinsicHeight');

        final width = constraints.hasBoundedWidth
            ? (_intrinsicWidth != null ? _intrinsicWidth!.clamp(0.0, constraints.maxWidth) : constraints.maxWidth)
            : (_intrinsicWidth ?? 100.0);

        return SizedBox(
          width: width,
          height: height,
          child: AppKitView(
            viewType: 'CupertinoNativeMenuButton',
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          ),
        );
      },
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/channel/channel_serialization.dart';
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
    this.image,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.focusable = false,
  }) : assert(label != null || image != null, 'CNMenuButton requires a label or image.'),
       super();

  /// Control size for the native button.
  final CNControlSize controlSize;

  /// Whether the native button should be focusable.
  final bool focusable;

  /// Optional icon shown on the button.
  final CNImage? image;

  /// Optional text label shown on the button.
  final String? label;

  /// The menu model to show.
  final CNMenu menu;

  /// Visual style applied to the button.
  final CNMenuStyle menuStyle;

  /// Called when a leaf menu item is selected.
  final ValueChanged<CNMenuItem> onSelected;

  @override
  State<CNMenuButton> createState() => _CNMenuButtonState();
}

class _CNMenuButtonState extends State<CNMenuButton> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  bool? _lastFocusable;
  CNImage? _lastImage;
  bool _lastIsDark = false;
  CNMenu? _lastMenu;
  CNMenuStyle? _lastStyle;
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
    _lastImage = widget.image;
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

    final currentMenuMap = widget.menu.toChannelMap(context);
    final currentImageMap = CNChannelSerialization.object(widget.image, context);

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

    if (_lastImage != widget.image) {
      _lastImage = widget.image;
      await ch.invokeMethod('setImage', {'image': currentImageMap});
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
      'menu': widget.menu.toChannelMap(context),
      'label': widget.label,
      'style': widget.menuStyle.name,
      'controlSize': widget.controlSize.name,
      'focusable': widget.focusable,
      'isDark': isDark,
      'image': CNChannelSerialization.object(widget.image, context),
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

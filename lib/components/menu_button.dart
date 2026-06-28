import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/menu.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/style/menu_style.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
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
    this.buttonLabel,
    this.buttonIcon,
    this.tint,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.focusable = false,
  }) : assert(buttonLabel != null || buttonIcon != null, 'CNMenuButton requires a label, icon.'),
       super();

  /// Creates a menu button that shows only an icon.
  const CNMenuButton.icon({
    super.key,
    required this.buttonIcon,
    required this.menu,
    required this.onSelected,
    this.tint,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.focusable = false,
  }) : buttonLabel = null,
       super();

  /// Creates a menu button with a label.
  const CNMenuButton.label({
    super.key,
    required this.buttonLabel,
    required this.menu,
    required this.onSelected,
    this.tint,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.focusable = false,
  }) : buttonIcon = null,
       super();

  /// Optional SF Symbol icon shown on the button.
  final CNSymbol? buttonIcon;

  /// Optional text label shown on the button.
  final String? buttonLabel;

  /// Control size for the native button.
  final CNControlSize controlSize;

  /// Whether the native button should be focusable.
  final bool focusable;

  /// The menu model to show.
  final CNMenu menu;

  /// Visual style applied to the button.
  final CNMenuStyle menuStyle;

  /// Called when a leaf menu item is selected.
  final ValueChanged<CNMenuItem> onSelected;

  /// Optional tint color for the native control.
  final Color? tint;

  @override
  State<CNMenuButton> createState() => _CNMenuButtonState();
}

class _CNMenuButtonState extends State<CNMenuButton> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  bool? _lastFocusable;
  int? _lastIconColor;
  String? _lastIconName;
  double? _lastIconSize;
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

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveTint => widget.tint ?? CupertinoTheme.of(context).primaryColor;

  void _onCreated(int id) {
    _channel = MethodChannel('CupertinoNativeMenuButton_$id')..setMethodCallHandler(_onMethodCall);
    _lastIsDark = _isDark;
    _lastMenu = widget.menu;
    _lastTitle = widget.buttonLabel;
    _lastIconName = widget.buttonIcon?.name;
    _lastIconSize = widget.buttonIcon?.size;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.menuStyle;
    _lastFocusable = widget.focusable;
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
    final ch = _channel;
    if (ch == null) return;

    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);

    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setIsDark', {'value': isDark});
      _lastIsDark = isDark;
    }

    if (tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
    }
  }

  Future<void> _syncPropsToNativeIfNeeded(CNMenuButton oldWidget) async {
    final ch = _channel;
    if (ch == null) return;

    final currentMenuMap = widget.menu.toMap(context);
    final currentIconName = widget.buttonIcon?.name;
    final currentIconSize = widget.buttonIcon?.size;
    final currentIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    final currentIconPaletteColors = widget.buttonIcon?.paletteColors?.map((c) => resolveColorToArgb(c, context)).toList();
    final currentIconRenderingMode = widget.buttonIcon?.mode?.name;
    final currentIconGradientEnabled = widget.buttonIcon?.gradient;

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

    if (_lastTitle != widget.buttonLabel) {
      _lastTitle = widget.buttonLabel;
      await ch.invokeMethod('setButtonTitle', {'buttonTitle': widget.buttonLabel});
    }

    if (_lastIconName != currentIconName || _lastIconSize != currentIconSize || _lastIconColor != currentIconColor) {
      _lastIconName = currentIconName;
      _lastIconSize = currentIconSize;
      _lastIconColor = currentIconColor;
      await ch.invokeMethod('setButtonIcon', {
        'buttonIconName': currentIconName,
        'buttonIconSize': currentIconSize,
        'buttonIconColor': currentIconColor,
        'buttonIconRenderingMode': currentIconRenderingMode,
        'buttonIconPaletteColors': currentIconPaletteColors,
        'buttonIconGradientEnabled': currentIconGradientEnabled,
      });
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

    final creationParams = <String, dynamic>{
      'menu': widget.menu.toMap(context),
      'buttonTitle': widget.buttonLabel,
      'buttonIconName': widget.buttonIcon?.name,
      'buttonIconSize': widget.buttonIcon?.size,
      'buttonIconColor': resolveColorToArgb(widget.buttonIcon?.color, context),
      'buttonStyle': widget.menuStyle.name,
      'controlSize': widget.controlSize.name,
      'focusable': widget.focusable,
      'style': encodeStyle(context, tint: _effectiveTint),
    };

    // Constrain the platform view size to avoid infinite width when this
    // button is placed in unbounded horizontal layouts like rows.
    final height = _intrinsicHeight ?? 28.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? (_intrinsicWidth != null ? _intrinsicWidth!.clamp(0.0, constraints.maxWidth) : constraints.maxWidth)
            : (_intrinsicWidth ?? 100.0);

        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
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
          ),
        );
      },
    );
  }
}

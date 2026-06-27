import 'package:cupertino_native/model/picker_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../model/control_size.dart';
import '../style/sf_symbol.dart';

/// A Cupertino-native picker with segmented control style.
///
/// Embeds a native SwiftUI Picker for pixel-perfect fidelity on macOS.
class CNPicker extends StatefulWidget {
  /// Creates a Cupertino-native picker.
  const CNPicker({
    super.key,
    required this.selectedIndex,
    required this.onValueChanged,
    this.label,
    this.sublabel,
    this.enabled = true,
    this.color,
    this.controlSize = CNControlSize.regular,
    this.pickerStyle = CNPickerStyle.segmented,
    List<String>? items,
    List<CNSymbol>? icons,
    this.iconSize,
    this.iconColor,
    this.iconPaletteColors,
    this.iconGradientEnabled,
    this.iconRenderingMode,
  }) : assert(items != null || icons != null, 'Either items or icons must be provided.'),
       assert(items == null || icons == null, 'Cannot provide both items and icons.'),
       assert(items == null || items.length > 0, 'Items list cannot be empty.'),
       assert(icons == null || icons.length > 0, 'Icons list cannot be empty.'),
       this.items = items ?? const [],
       this.icons = icons ?? const [];

  /// Accent/tint color used for the picker.
  final Color? color;

  /// Control size for the picker.
  final CNControlSize controlSize;

  /// Whether the picker is interactive.
  final bool enabled;

  /// Global icon color override.
  final Color? iconColor;

  /// Enables gradient rendering where supported.
  final bool? iconGradientEnabled;

  /// Global icon palette colors override.
  final List<Color>? iconPaletteColors;

  /// Global icon rendering mode.
  final CNSymbolRenderingMode? iconRenderingMode;

  /// Overrides the symbol size (for all options).
  final double? iconSize;

  /// Optional SF Symbols for options; complements [labels].
  final List<CNSymbol> icons;

  /// Picker items to display, in order.
  final List<String> items;

  /// Optional primary label.
  final String? label;

  /// Called when the user selects an option.
  final ValueChanged<int> onValueChanged;

  /// Picker style for the picker.
  final CNPickerStyle pickerStyle;

  /// The index of the selected option.
  final int selectedIndex;

  /// Optional secondary label/subtitle.
  final String? sublabel;

  @override
  State<CNPicker> createState() => _CNPickerState();
}

class _CNPickerState extends State<CNPicker> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  CNControlSize? _lastControlSize;
  bool? _lastEnabled;
  bool? _lastIsDark;
  CNPickerStyle? _lastPickerStyle;
  int? _lastSelected;
  int? _lastTint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativePicker_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
  }

  Future<void> _queryIntrinsicSize() async {
    try {
      final result = await _channel?.invokeMethod<Map>('getIntrinsicSize');
      if (result != null) {
        debugPrint('Picker intrinsic size: $result');
        _onIntrinsicSizeChanged((result['width'] as num?)?.toDouble(), (result['height'] as num?)?.toDouble());
      }
    } catch (e) {
      // Fallback to default height
      _intrinsicWidth = null;
      _intrinsicHeight = null;
    }
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;
    debugPrint('_onIntrinsicSizeChanged: width=$width, height=$height');
    setState(() {
      _intrinsicWidth = width > -1 ? width : null;
      _intrinsicHeight = height > -1 ? height + 28 : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged(idx);
        _lastSelected = idx;
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastSelected = widget.selectedIndex;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(widget.color, context);
    _lastControlSize = widget.controlSize;
    _lastPickerStyle = widget.pickerStyle;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final tint = resolveColorToArgb(widget.color, context);

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }
    if (_lastSelected != widget.selectedIndex) {
      await channel.invokeMethod('setSelectedIndex', {'index': widget.selectedIndex});
      _lastSelected = widget.selectedIndex;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {'controlSize': widget.controlSize.name});
      _lastControlSize = widget.controlSize;
      _queryIntrinsicSize();
    }
    if (_lastPickerStyle != widget.pickerStyle) {
      await channel.invokeMethod('setPickerStyle', {'pickerStyle': widget.pickerStyle.name});
      _lastPickerStyle = widget.pickerStyle;
      _queryIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(widget.color, context);
    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    const viewType = 'CupertinoNativePicker';
    final creationParams = <String, dynamic>{
      'items': widget.items,
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'pickerStyle': widget.pickerStyle.name,
      if (widget.label != null) 'label': widget.label,
      if (widget.sublabel != null) 'sublabel': widget.sublabel,
      'style': encodeStyle(context, tint: widget.color)
        ..addAll({
          if (widget.iconSize != null) 'iconSize': widget.iconSize,
          if (widget.iconColor != null) 'iconColor': resolveColorToArgb(widget.iconColor, context),
          if (widget.iconPaletteColors != null)
            'iconPaletteColors': widget.iconPaletteColors!.map((c) => resolveColorToArgb(c, context)).toList(),
          if (widget.iconGradientEnabled != null) 'iconGradientEnabled': widget.iconGradientEnabled,
          if (widget.iconRenderingMode != null) 'iconRenderingMode': widget.iconRenderingMode!.name,
        }),
      if (widget.icons != null) 'sfSymbols': widget.icons!.map((e) => e.name).toList(),
      if (widget.icons != null) 'sfSymbolSizes': widget.icons!.map((e) => e.size).toList(),
      if (widget.icons != null)
        'sfSymbolColors': widget.icons!.map((e) => resolveColorToArgb(e.color, context)).toList(),
      if (widget.icons != null)
        'sfSymbolPaletteColors': widget.icons!
            .map((e) => (e.paletteColors ?? []).map((c) => resolveColorToArgb(c, context)).toList())
            .toList(),
      if (widget.icons != null) 'sfSymbolRenderingModes': widget.icons!.map((e) => e.mode?.name).toList(),
      if (widget.icons != null) 'sfSymbolGradientEnabled': widget.icons!.map((e) => e.gradient).toList(),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('Picker constraints: $constraints');
        final bool hasBoundedWidth = constraints.hasBoundedWidth;
        final bool hasBoundedHeight = constraints.hasBoundedHeight;
        debugPrint('Picker hasBoundedWidth=$hasBoundedWidth, hasBoundedHeight=$hasBoundedHeight');

        double? width;
        double? height;

        if (hasBoundedWidth) {
          width = constraints.maxWidth;
        } else if (_intrinsicWidth != null) {
          width = _intrinsicWidth;
        }

        if (hasBoundedHeight) {
          height = constraints.maxHeight;
        } else if (_intrinsicHeight != null) {
          height = _intrinsicHeight;
        }

        width ??= double.infinity;
        height ??= 38.0;

        debugPrint('Picker final size: width=$width, height=$height');

        return SizedBox(
          height: height,
          width: width,
          child: AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      },
    );
  }
}

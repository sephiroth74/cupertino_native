import 'package:cupertino_native/model/picker_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../model/control_size.dart';
import '../style/sf_symbol.dart';
import '../theme/cn_theme.dart';

const double _kDefaultPickerHeight = 38.0;
const double _kDefaultPickerWidth = 300.0;

/// A Cupertino-native picker with segmented control style.
///
/// Embeds a native SwiftUI Picker for pixel-perfect fidelity on macOS.
class CNPickerItem {
  /// Creates an icon-based picker item.
  const CNPickerItem.icon(this.icon) : text = null;

  /// Creates a text-based picker item.
  const CNPickerItem.text(this.text) : icon = null;

  /// The symbol for an icon item.
  final CNSymbol? icon;

  /// The display text for a text item.
  final String? text;

  /// Converts the picker item to a platform-friendly map.
  Map<String, dynamic> toMap(BuildContext context) {
    if (text != null) {
      return {'type': 'text', 'text': text};
    }
    if (icon != null) {
      return {
        'type': 'icon',
        'symbolName': icon!.name,
        if (icon!.color != null) 'symbolColor': resolveColorToArgb(icon!.color, context),
        if (icon!.paletteColors != null)
          'symbolPaletteColors': icon!.paletteColors!.map((c) => resolveColorToArgb(c, context)).toList(),
        if (icon!.mode != null) 'symbolRenderingMode': icon!.mode!.name,
        if (icon!.gradient != null) 'symbolGradientEnabled': icon!.gradient,
        if (icon!.size != null) 'symbolSize': icon!.size,
      };
    }
    return {'type': 'text', 'text': ''};
  }
}

/// A Cupertino-native picker with segmented control style.
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
    this.shrinkWrap = false,
    this.asList = false,
    required this.items,
  }) : assert(items.length > 0, 'Items list cannot be empty.');

  /// Whether the picker should be displayed as a list (true) or segmented control (false).
  final bool asList;

  /// Accent/tint color used for the picker.
  final Color? color;

  /// Control size for the picker.
  final CNControlSize controlSize;

  /// Whether the picker is interactive.
  final bool enabled;

  /// Picker items to display, in order.
  final List<CNPickerItem> items;

  /// Optional primary label.
  final String? label;

  /// Called when the user selects an option.
  final ValueChanged<int> onValueChanged;

  /// Picker style for the picker.
  final CNPickerStyle pickerStyle;

  /// The index of the selected option.
  final int selectedIndex;

  /// Whether the picker should shrink-wrap its content.
  final bool shrinkWrap;

  /// Optional secondary label/subtitle.
  final String? sublabel;

  @override
  State<CNPicker> createState() => _CNPickerState();
}

class _CNPickerState extends State<CNPicker> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  bool? _lastAsList;
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

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  Color? get _effectiveTint => widget.color ?? CNTheme.of(context).primaryColor;

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativePicker_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _queryIntrinsicSize();
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
      _intrinsicHeight = height > -1 ? height : null;
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
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastControlSize = widget.controlSize;
    _lastPickerStyle = widget.pickerStyle;
    _lastAsList = widget.asList;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final tint = resolveColorToArgb(_effectiveTint, context);

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
    if (_lastAsList != widget.asList) {
      await channel.invokeMethod('setAsList', {'asList': widget.asList});
      _lastAsList = widget.asList;
      _queryIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
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
      'items': widget.items.map((item) => item.toMap(context)).toList(),
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'pickerStyle': widget.pickerStyle.name,
      'asList': widget.asList,
      if (widget.label != null) 'label': widget.label,
      if (widget.sublabel != null) 'sublabel': widget.sublabel,
      'style': encodeStyle(context, tint: _effectiveTint),
    };

    final child = AppKitView(
      viewType: viewType,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: creationParams,
      onPlatformViewCreated: _onPlatformViewCreated,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('Picker constraints: $constraints');
        final bool hasBoundedWidth = constraints.hasBoundedWidth;
        final bool hasBoundedHeight = constraints.hasBoundedHeight;
        debugPrint('Picker hasBoundedWidth=$hasBoundedWidth, hasBoundedHeight=$hasBoundedHeight');

        double? width;
        double? height;

        if (widget.shrinkWrap) {
          if (hasBoundedWidth) {
            final targetWidth = _intrinsicWidth ?? _kDefaultPickerWidth;
            width = targetWidth.clamp(0.0, constraints.maxWidth);
          } else {
            width = _intrinsicWidth ?? _kDefaultPickerWidth;
          }

          if (hasBoundedHeight) {
            final targetHeight = _intrinsicHeight ?? _kDefaultPickerHeight;
            height = targetHeight.clamp(0.0, constraints.maxHeight);
          } else {
            height = _intrinsicHeight ?? _kDefaultPickerHeight;
          }
        } else if (hasBoundedWidth) {
          width = constraints.maxWidth;
          if (_intrinsicHeight != null) {
            height = _intrinsicHeight;
          } else if (hasBoundedHeight) {
            height = constraints.maxHeight;
          } else {
            height = _kDefaultPickerHeight;
          }
        } else {
          width = _intrinsicWidth ?? _kDefaultPickerWidth;
          height = _intrinsicHeight ?? (hasBoundedHeight ? constraints.maxHeight : _kDefaultPickerHeight);
        }

        debugPrint('Picker final size: width=$width, height=$height');

        if (width == double.infinity) {
          width = _intrinsicWidth ?? _kDefaultPickerWidth;
        }
        if (height == double.infinity) {
          height = _intrinsicHeight ?? _kDefaultPickerHeight;
        }

        return SizedBox(height: height, width: width, child: child);
      },
    );
  }
}

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A native macOS SwiftUI label backed by `Label`.
///
/// On platforms other than macOS, this falls back to a plain Flutter text label.
class CNLabel extends StatefulWidget {
  /// Creates a native SwiftUI label.
  const CNLabel({super.key, required this.text, this.icon, this.color, this.font, this.labelStyle = CNLabelStyle.automatic});

  /// Optional color for the label text and icon.
  final Color? color;

  /// Optional font configuration for the label.
  final CNFont? font;

  /// Optional SF Symbol icon to show alongside the label.
  final CNSymbol? icon;

  /// Visual style used by the SwiftUI label.
  final CNLabelStyle labelStyle;

  /// The label text.
  final String text;

  @override
  State<CNLabel> createState() => _CNLabelState();
}

/// Style options for [CNLabel].
enum CNLabelStyle {
  /// Let SwiftUI choose the most appropriate style.
  automatic,

  /// Show both title and icon.
  titleAndIcon,

  /// Show only the title text.
  titleOnly,

  /// Show only the icon.
  iconOnly,
}

class _CNLabelState extends State<CNLabel> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  int? _lastColor;
  Map<String, dynamic>? _lastFontMap;
  int? _lastIconColor;
  bool? _lastIconGradientEnabled;
  String? _lastIconMode;
  String? _lastIconName;
  List<int?>? _lastIconPaletteColors;
  double? _lastIconSize;
  CNLabelStyle? _lastLabelStyle;
  String? _lastText;

  @override
  void didUpdateWidget(covariant CNLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final channel = MethodChannel('CupertinoNativeLabel_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheProps();
    await _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;
    setState(() {
      _intrinsicWidth = width > -1 ? width : null;
      _intrinsicHeight = height > -1 ? height : null;
    });
  }

  void _cacheProps() {
    _lastText = widget.text;
    _lastIconName = widget.icon?.name;
    _lastIconSize = widget.icon?.size;
    _lastIconColor = resolveColorToArgb(widget.icon?.color, context);
    _lastIconMode = widget.icon?.mode?.name;
    _lastIconPaletteColors = widget.icon?.paletteColors?.map((c) => resolveColorToArgb(c, context)).toList();
    _lastIconGradientEnabled = widget.icon?.gradient;
    _lastColor = resolveColorToArgb(widget.color, context);
    _lastFontMap = widget.font?.toMap();
    _lastLabelStyle = widget.labelStyle;
  }

  Future<void> _syncPropsToNativeIfNeeded(CNLabel oldWidget) async {
    final channel = _channel;
    if (channel == null) return;

    final currentIconName = widget.icon?.name;
    final currentIconSize = widget.icon?.size;
    final currentIconColor = resolveColorToArgb(widget.icon?.color, context);
    final currentIconMode = widget.icon?.mode?.name;
    final currentIconPaletteColors = widget.icon?.paletteColors?.map((c) => resolveColorToArgb(c, context)).toList();
    final currentIconGradientEnabled = widget.icon?.gradient;
    final currentColor = resolveColorToArgb(widget.color, context);
    final currentFontMap = widget.font?.toMap();
    final currentLabelStyle = widget.labelStyle;

    if (_lastText != widget.text) {
      _lastText = widget.text;
      await channel.invokeMethod('setText', {'text': widget.text});
      await _requestIntrinsicSize();
    }

    if (_lastIconName != currentIconName ||
        _lastIconSize != currentIconSize ||
        _lastIconColor != currentIconColor ||
        _lastIconMode != currentIconMode ||
        _lastIconPaletteColors != currentIconPaletteColors ||
        _lastIconGradientEnabled != currentIconGradientEnabled) {
      _lastIconName = currentIconName;
      _lastIconSize = currentIconSize;
      _lastIconColor = currentIconColor;
      _lastIconMode = currentIconMode;
      _lastIconPaletteColors = currentIconPaletteColors;
      _lastIconGradientEnabled = currentIconGradientEnabled;
      await channel.invokeMethod('setIcon', {
        'iconName': currentIconName,
        'iconSize': currentIconSize,
        'iconColor': currentIconColor,
        'iconRenderingMode': currentIconMode,
        'iconPaletteColors': currentIconPaletteColors,
        'iconGradientEnabled': currentIconGradientEnabled,
      });
      await _requestIntrinsicSize();
    }

    if (_lastColor != currentColor) {
      _lastColor = currentColor;
      await channel.invokeMethod('setColor', {'color': currentColor});
    }

    if (_lastFontMap != currentFontMap) {
      _lastFontMap = currentFontMap;
      await channel.invokeMethod('setFont', {'font': currentFontMap});
      await _requestIntrinsicSize();
    }

    if (_lastLabelStyle != currentLabelStyle) {
      _lastLabelStyle = currentLabelStyle;
      await channel.invokeMethod('setLabelStyle', {'labelStyle': currentLabelStyle.name});
      await _requestIntrinsicSize();
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
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

  String _labelStyleName(CNLabelStyle style) {
    return style.name;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      final theme = CNTheme.of(context);
      return Text(
        widget.text,
        style: theme.typography.body.copyWith(color: widget.color ?? theme.labelColor, fontSize: widget.font?.size.points),
      );
    }

    final creationParams = <String, dynamic>{
      'text': widget.text,
      if (widget.icon != null) 'iconName': widget.icon!.name,
      if (widget.icon?.size != null) 'iconSize': widget.icon!.size,
      if (widget.icon?.color != null) 'iconColor': resolveColorToArgb(widget.icon!.color, context),
      if (widget.icon?.mode != null) 'iconRenderingMode': widget.icon!.mode!.name,
      if (widget.icon?.paletteColors != null)
        'iconPaletteColors': widget.icon!.paletteColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      if (widget.icon?.gradient != null) 'iconGradientEnabled': widget.icon!.gradient,
      if (widget.color != null) 'color': resolveColorToArgb(widget.color, context),
      if (widget.font != null) 'font': widget.font!.toMap(),
      'labelStyle': _labelStyleName(widget.labelStyle),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? (_intrinsicWidth != null ? _intrinsicWidth!.clamp(0.0, constraints.maxWidth) : constraints.maxWidth)
            : (_intrinsicWidth ?? 100.0);
        final height = constraints.hasBoundedHeight
            ? (_intrinsicHeight != null ? _intrinsicHeight!.clamp(0.0, constraints.maxHeight) : constraints.maxHeight)
            : (_intrinsicHeight ?? 20.0);

        return SizedBox(
          width: width,
          height: height,
          child: AppKitView(
            viewType: 'CupertinoNativeLabel',
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      },
    );
  }
}

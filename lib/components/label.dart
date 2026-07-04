import 'dart:convert';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/style/text_utils.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultLabelWidth = 50.0;
const double _kDefaultLabelHeight = 24.0;

/// A native macOS SwiftUI label backed by `Label`.
///
/// On platforms other than macOS, this falls back to a plain Flutter text label.
class CNLabel extends StatefulWidget {
  /// Creates a native SwiftUI label.
  const CNLabel(
    this.text, {
    super.key,
    this.secondaryText,
    this.icon,
    this.labelStyle = CNLabelStyle.automatic,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.width,
    this.height,
  });

  /// Creates a native SwiftUI label with a single text string.
  factory CNLabel.text(
    String text, {
    CNText? secondaryText,
    CNImage? icon,
    CNLabelStyle labelStyle = CNLabelStyle.automatic,
    double? labelReservedIconWidth,
    double? labelIconToTitleSpacing,
    double? width,
    double? height,
  }) {
    return CNLabel(
      CNText(text),
      secondaryText: secondaryText,
      icon: icon,
      labelStyle: labelStyle,
      labelReservedIconWidth: labelReservedIconWidth,
      labelIconToTitleSpacing: labelIconToTitleSpacing,
      width: width,
      height: height,
    );
  }

  /// Optional fixed height.
  final double? height;

  /// Optional icon shown on the leading side.
  final CNImage? icon;

  /// Optional spacing between icon and title.
  final double? labelIconToTitleSpacing;

  /// Optional reserved width for icon area.
  final double? labelReservedIconWidth;

  /// Visual style applied to the SwiftUI label.
  final CNLabelStyle labelStyle;

  /// Secondary text shown below primary text.
  final CNText? secondaryText;

  /// Primary text, required.
  final CNText text;

  /// Optional fixed width.
  final double? width;

  @override
  State<CNLabel> createState() => _CNLabelState();
}

/// Style options for [CNLabel].
enum CNLabelStyle {
  /// Let SwiftUI choose the most appropriate style.
  automatic,

  /// Show both title and icon.
  titleAndIcon,

  /// Show only title.
  titleOnly,

  /// Show only icon.
  iconOnly,
}

class _CNLabelState extends State<CNLabel> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  int _intrinsicProbeAttempts = 0;
  bool _intrinsicProbeInFlight = false;
  double? _intrinsicWidth;
  String? _lastSerializedPayload;
  double? _layoutHeight;
  double? _layoutWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
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
    _cacheCurrentProps();
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
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
  }

  Map<String, dynamic> _textToMap(CNText textWidget) {
    final theme = CNTheme.of(context);
    final resolvedColor = textWidget.color ?? theme.labelColor;
    final resolvedFont = textWidget.font ?? cnFontFromTextStyle(theme.typography.body);

    return {
      'text': textWidget.text,
      'color': resolveColorToArgb(resolvedColor, context),
      'font': resolvedFont.toMap(),
      'lineLimit': textWidget.lineLimit,
      'lineLimitReservesSpace': textWidget.lineLimitReservesSpace,
      'textScale': textWidget.textScale?.name,
      'truncationMode': textWidget.truncationMode?.name,
    };
  }

  Widget _buildFallbackText(CNText textWidget) {
    final theme = CNTheme.of(context);
    final resolvedColor = textWidget.color ?? theme.labelColor;
    final resolvedFont = textWidget.font ?? cnFontFromTextStyle(theme.typography.body);

    return Text(
      textWidget.text,
      maxLines: textWidget.lineLimit,
      overflow: overflowFromTruncationMode(textWidget.truncationMode),
      style: theme.typography.body.copyWith(
        color: resolvedColor,
        fontSize: resolvedFont.size.points,
        fontWeight: fontWeightFromCNFontWeight(resolvedFont.weight),
      ),
    );
  }

  Map<String, dynamic> _toPayload() {
    return {
      'primaryText': _textToMap(widget.text),
      if (widget.secondaryText != null) 'secondaryText': _textToMap(widget.secondaryText!),
      if (widget.icon != null) 'icon': widget.icon!.toMap(context),
      'labelStyle': widget.labelStyle.name,
      if (widget.labelReservedIconWidth != null) 'labelReservedIconWidth': widget.labelReservedIconWidth,
      if (widget.labelIconToTitleSpacing != null) 'labelIconToTitleSpacing': widget.labelIconToTitleSpacing,
      'width': _layoutWidth,
      'height': _layoutHeight,
    };
  }

  String _serializeCurrentPayload() => jsonEncode(_toPayload());

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await channel.invokeMethod('setLabel', payload);
      _cacheCurrentProps();
      await _requestIntrinsicSize();
    }
  }

  Future<void> _requestIntrinsicSize() async {
    if (_intrinsicProbeInFlight) return;

    final channel = _channel;
    if (channel == null) return;

    _intrinsicProbeInFlight = true;
    _intrinsicProbeAttempts += 1;
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
    } finally {
      _intrinsicProbeInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final shouldProbeWidth = widget.width == null && !hasBoundedWidth && _intrinsicWidth == null;
        final shouldProbeHeight = widget.height == null && !hasBoundedHeight && _intrinsicHeight == null;

        debugPrint(
          '[CNLabel] build() constraints: $constraints, intrinsicWidth: $_intrinsicWidth, intrinsicHeight: $_intrinsicHeight, layoutWidth: $_layoutWidth, layoutHeight: $_layoutHeight',
        );

        if ((shouldProbeWidth || shouldProbeHeight) && !_intrinsicProbeInFlight && _channel != null) {
          _requestIntrinsicSize();
        }

        final canFallbackWidth = _intrinsicProbeAttempts > 0;
        final canFallbackHeight = _intrinsicProbeAttempts > 0;

        final resolvedWidth =
            widget.width ??
            (hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? (canFallbackWidth ? _kDefaultLabelWidth : null));
        final resolvedHeight =
            widget.height ??
            (hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? (canFallbackHeight ? _kDefaultLabelHeight : null));

        if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
          _layoutWidth = resolvedWidth;
          _layoutHeight = resolvedHeight;
          _syncPropsToNativeIfNeeded();
        }

        debugPrint('[CNLabel] build() resolvedWidth: $resolvedWidth, resolvedHeight: $resolvedHeight');

        if (defaultTargetPlatform != TargetPlatform.macOS) {
          final showIcon = widget.icon != null && widget.labelStyle != CNLabelStyle.titleOnly;
          final showTitle = widget.labelStyle != CNLabelStyle.iconOnly;

          return SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: Row(
              children: [
                if (showIcon) SizedBox(width: widget.labelReservedIconWidth, child: widget.icon!),
                if (showIcon && showTitle) SizedBox(width: widget.labelIconToTitleSpacing ?? 8),
                if (showTitle)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFallbackText(widget.text),
                        if (widget.secondaryText != null) _buildFallbackText(widget.secondaryText!),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }

        final platformView = AppKitView(
          viewType: 'CupertinoNativeLabel',
          creationParams: _toPayload(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        if (resolvedWidth == null && resolvedHeight == null) {
          debugPrint('[CNLabel] build() using default width: $_kDefaultLabelWidth, default height: $_kDefaultLabelHeight');
          return SizedBox(width: _kDefaultLabelWidth, height: _kDefaultLabelHeight, child: platformView);
        } else if (resolvedWidth == null) {
          debugPrint('[CNLabel] build() using default width: $_kDefaultLabelWidth');
          return SizedBox(width: _kDefaultLabelWidth, child: platformView);
        } else if (resolvedHeight == null) {
          debugPrint('[CNLabel] build() using default height: $_kDefaultLabelHeight');
          return SizedBox(height: _kDefaultLabelHeight, child: platformView);
        }
        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
      },
    );
  }
}

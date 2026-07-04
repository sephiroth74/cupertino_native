import 'dart:convert';

import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/text.dart';
import 'package:cupertino_native/style/text_utils.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultTextWidth = 120.0;
const double _kDefaultTextHeight = 24.0;

/// A SwiftUI Text-backed native macOS text widget.
class CNText extends StatefulWidget with CNButtonChild {
  /// Creates a new text widget.
  const CNText(
    this.text, {
    super.key,
    this.color,
    this.font,
    this.lineLimit,
    this.lineLimitReservesSpace,
    this.textScale,
    this.truncationMode,
    this.width,
  });

  /// Optional foreground color.
  final Color? color;

  /// Optional font descriptor.
  final CNFont? font;

  /// Maximum number of lines.
  final int? lineLimit;

  /// Whether the text should reserve space for [lineLimit].
  final bool? lineLimitReservesSpace;

  /// Text content.
  final String text;

  /// Optional SwiftUI text scale.
  final CNTextScale? textScale;

  /// Optional SwiftUI truncation mode.
  final CNTextTruncationMode? truncationMode;

  /// Optional fixed width frame.
  final double? width;

  @override
  String get buttonChildType => 'text';

  // ignore: public_member_api_docs, annotate_overrides, library_private_types_in_public_api
  @override
  State<CNText> createState() => _CNTextState();

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return toMap(context, ignoreTheme: ignoreTheme);
  }

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap(BuildContext context, {double? frameWidth, double? frameHeight, bool ignoreTheme = false}) {
    final theme = CNTheme.of(context);
    final resolvedColor = color ?? (ignoreTheme ? null : theme.textTheme.labelColor ?? theme.labelColor);
    final resolvedFont = font ?? (ignoreTheme ? null : theme.textTheme.font ?? cnFontFromTextStyle(theme.typography.body));

    return {
      'text': text,
      'color': resolveColorToArgb(resolvedColor, context),
      'font': resolvedFont?.toMap(),
      'lineLimit': lineLimit,
      'lineLimitReservesSpace': lineLimitReservesSpace,
      'textScale': textScale?.name,
      'truncationMode': truncationMode?.name,
      'width': frameWidth ?? width,
      'height': frameHeight,
    };
  }

  String _toJson(BuildContext context, {double? frameWidth, double? frameHeight}) =>
      jsonEncode(toMap(context, frameWidth: frameWidth, frameHeight: frameHeight));
}

class _CNTextState extends State<CNText> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
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
  void didUpdateWidget(covariant CNText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  String _serializeCurrentPayload() => widget._toJson(context, frameWidth: _layoutWidth, frameHeight: _layoutHeight);

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeText_$id')..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'intrinsicSizeChanged':
        final args = call.arguments as Map?;
        _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
        break;
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

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
      _onIntrinsicSizeChanged((size?['width'] as num?)?.toDouble(), (size?['height'] as num?)?.toDouble());
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = widget.toMap(context, frameWidth: _layoutWidth, frameHeight: _layoutHeight);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await channel.invokeMethod('setText', payload);
      _cacheCurrentProps();
      _requestIntrinsicSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final resolvedColor = widget.color ?? theme.textTheme.labelColor ?? theme.labelColor;
    final resolvedFont = widget.font ?? theme.textTheme.font ?? cnFontFromTextStyle(theme.typography.body);
    final textStyle = theme.typography.body.copyWith(
      color: resolvedColor,
      fontSize: resolvedFont.size.points,
      fontWeight: fontWeightFromCNFontWeight(resolvedFont.weight),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final resolvedWidth = widget.width ?? (hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _kDefaultTextWidth);
        final resolvedHeight = hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? _kDefaultTextHeight;

        if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
          _layoutWidth = resolvedWidth;
          _layoutHeight = resolvedHeight;
          _syncPropsToNativeIfNeeded();
        }

        if (defaultTargetPlatform != TargetPlatform.macOS) {
          return SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: Text(
              widget.text,
              maxLines: widget.lineLimit,
              overflow: overflowFromTruncationMode(widget.truncationMode),
              style: textStyle,
            ),
          );
        }

        final creationParams = widget.toMap(context, frameWidth: resolvedWidth, frameHeight: resolvedHeight);

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: AppKitView(
            viewType: 'CupertinoNativeText',
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      },
    );
  }
}

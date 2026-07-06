import 'dart:convert';

import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/paddable.dart';
import 'package:cupertino_native/components/taggable.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/text.dart';
import 'package:cupertino_native/style/text_utils.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultTextHeight = 24.0;
const double _kDefaultTextWidth = 120.0;

/// A SwiftUI Text-backed native macOS text widget.
class CNText extends StatefulWidget with CNButtonChild, CNMenuChild, CNViewModifiable, CNPaddable, CNTaggable {
  /// Creates a new text widget.
  const CNText(
    this.text, {
    super.key,
    this.font,
    this.lineLimit,
    this.lineLimitReservesSpace,
    this.textScale,
    this.truncationMode,
    this.badge,
    this.modifiers = const CNViewModifiers(),
  }) : assert(badge == null || badge is String || badge is int, 'Badge must be a String or int.');

  /// Optional badge shown next to the menu item when used inside [CNMenu].
  final Object? badge;

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

  @override
  final CNViewModifiers modifiers;

  @override
  String get buttonChildType => 'text';

  // ignore: public_member_api_docs, annotate_overrides, library_private_types_in_public_api
  @override
  State<CNText> createState() => _CNTextState();

  @override
  String get menuChildType => 'text';

  @override
  List<Object?> get props => [
    text,
    badge,
    padding,
    tag,
    font,
    lineLimit,
    lineLimitReservesSpace,
    textScale,
    truncationMode,
    modifiers,
  ];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return toMap(context, ignoreTheme: ignoreTheme);
  }

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap(BuildContext context, {double? frameWidth, double? frameHeight, bool ignoreTheme = false}) {
    final theme = CNTheme.of(context);
    // final resolvedColor = modifiers.foregroundColor ?? (ignoreTheme ? null : theme.textTheme.labelColor ?? theme.labelColor);
    final resolvedFont = font ?? (ignoreTheme ? null : theme.textTheme.font ?? cnFontFromTextStyle(theme.typography.body));

    final payload = <String, dynamic>{
      'text': text,
      'font': resolvedFont?.toMap(),
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'lineLimit': lineLimit,
      'lineLimitReservesSpace': lineLimitReservesSpace,
      'textScale': textScale?.name,
      'truncationMode': truncationMode?.name,
      'height': frameHeight,
    };

    writeModifiers(payload, context);
    return payload;
  }
}

class _CNTextState extends State<CNText> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;

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

  void _cacheCurrentProps() {
    final payload = widget.toMap(context, frameWidth: widget.modifiers.width, frameHeight: widget.modifiers.height);
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _computePayloadPatch(Map<String, dynamic> previous, Map<String, dynamic> next) {
    final patch = <String, dynamic>{};
    final keys = <String>{...previous.keys, ...next.keys};

    for (final key in keys) {
      final hadPrevious = previous.containsKey(key);
      final hasNext = next.containsKey(key);
      final oldValue = hadPrevious ? previous[key] : null;
      final newValue = hasNext ? next[key] : null;

      final changed = jsonEncode(oldValue) != jsonEncode(newValue);
      if (!changed) continue;

      patch[key] = hasNext ? newValue : null;
    }

    return patch;
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    debugPrint('[CNText] Intrinsic size changed: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;
    setState(() {
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
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

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeText_$id')..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
  }

  Future<void> _requestIntrinsicSize() async {
    debugPrint('[CNText] Requesting intrinsic size...');
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

    final payload = widget.toMap(context, frameWidth: widget.modifiers.width, frameHeight: widget.modifiers.height);
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNText][Dart] Sending full update via setText');
        await channel.invokeMethod('setText', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    final patch = _computePayloadPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      debugPrint('[CNText][Dart] No patch to send (payload unchanged)');
      _lastSerializedPayload = serializedPayload;
      return;
    }

    debugPrint('[CNText][Dart] Sending patch via applyPatch: ${jsonEncode(patch)}');
    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final resolvedColor = widget.modifiers.foregroundColor ?? theme.textTheme.labelColor ?? theme.labelColor;
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
        final resolvedWidth =
            widget.modifiers.width ?? (hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _kDefaultTextWidth);
        final resolvedHeight =
            widget.modifiers.height ?? (hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? _kDefaultTextHeight);

        if (defaultTargetPlatform != TargetPlatform.macOS) {
          Widget fallbackText = Text(
            widget.text,
            maxLines: widget.lineLimit,
            overflow: overflowFromTruncationMode(widget.truncationMode),
            style: textStyle,
          );

          if (widget.padding != null) {
            fallbackText = Padding(padding: widget.padding!, child: fallbackText);
          }

          return SizedBox(width: resolvedWidth, height: resolvedHeight, child: fallbackText);
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

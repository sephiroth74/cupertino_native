import 'dart:convert';

import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/paddable.dart';
import 'package:cupertino_native/components/taggable.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/style/text_utils.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultLabelWidth = 50.0;

/// A native macOS SwiftUI label backed by `Label`.
///
/// On platforms other than macOS, this falls back to a plain Flutter text label.
class CNLabel extends StatefulWidget with CNButtonChild, CNMenuChild, CNViewModifiable, CNPaddable, CNTaggable {
  /// Optional badge shown next to the menu item when used inside [CNMenu].
  final Object? badge;

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

  @override
  final CNViewModifiers modifiers;

  /// Creates a native SwiftUI label.
  const CNLabel(
    this.text, {
    super.key,
    this.secondaryText,
    this.icon,
    this.badge,
    this.labelStyle = CNLabelStyle.automatic,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.modifiers = const CNViewModifiers(),
  }) : assert(badge == null || badge is String || badge is int, 'Badge must be a String or int.');

  /// Creates a native SwiftUI label with a single text string.
  factory CNLabel.text(
    String text, {
    CNText? secondaryText,
    CNImage? icon,
    Object? badge,
    CNLabelStyle labelStyle = CNLabelStyle.automatic,
    double? labelReservedIconWidth,
    double? labelIconToTitleSpacing,
    CNViewModifiers? modifiers,
  }) {
    return CNLabel(
      CNText(text),
      secondaryText: secondaryText,
      icon: icon,
      badge: badge,
      labelStyle: labelStyle,
      labelReservedIconWidth: labelReservedIconWidth,
      labelIconToTitleSpacing: labelIconToTitleSpacing,
      modifiers: modifiers ?? const CNViewModifiers(),
    );
  }

  @override
  String get buttonChildType => 'label';

  @override
  String get menuChildType => 'label';

  @override
  List<Object?> get props => [
    text,
    secondaryText,
    icon,
    badge,
    labelStyle,
    labelReservedIconWidth,
    labelIconToTitleSpacing,
    modifiers,
  ];

  @override
  bool get stringify => true;

  @override
  State<CNLabel> createState() => _CNLabelState();

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return toMap(context, ignoreTheme: ignoreTheme);
  }

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap(BuildContext context, {double? frameWidth, double? frameHeight, bool ignoreTheme = false}) {
    final payload = <String, dynamic>{
      'primaryText': text.toMap(context, ignoreTheme: ignoreTheme),
      if (secondaryText != null) 'secondaryText': secondaryText!.toMap(context, ignoreTheme: ignoreTheme),
      if (icon != null) 'icon': icon!.toMap(context, ignoreTheme: ignoreTheme),
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'labelStyle': labelStyle.name,
      if (labelReservedIconWidth != null) 'labelReservedIconWidth': labelReservedIconWidth,
      if (labelIconToTitleSpacing != null) 'labelIconToTitleSpacing': labelIconToTitleSpacing,
    };

    writeModifiers(payload, context);
    return payload;
  }
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
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  double? _layoutHeight;
  double? _layoutWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final defaultHeight = _defaultHeightFromFonts();
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final shouldProbeWidth = widget.width == null && !hasBoundedWidth && _intrinsicWidth == null;
        final shouldProbeHeight = widget.height == null && !hasBoundedHeight && _intrinsicHeight == null;

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
            (hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? (canFallbackHeight ? defaultHeight : null));

        // if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
        //   _layoutWidth = resolvedWidth;
        //   _layoutHeight = resolvedHeight;
        //   _syncPropsToNativeIfNeeded();
        // }

        if (defaultTargetPlatform != TargetPlatform.macOS) {
          final showIcon = widget.icon != null && widget.labelStyle != CNLabelStyle.titleOnly;
          final showTitle = widget.labelStyle != CNLabelStyle.iconOnly;

          return SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
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
          return SizedBox(width: _kDefaultLabelWidth, height: defaultHeight, child: platformView);
        } else if (resolvedWidth == null) {
          return SizedBox(width: _kDefaultLabelWidth, child: platformView);
        } else if (resolvedHeight == null) {
          return SizedBox(height: defaultHeight, child: platformView);
        }
        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
      },
    );
  }

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

  Widget _buildFallbackText(CNText textWidget) {
    final theme = CNTheme.of(context);
    final resolvedColor = textWidget.modifiers.foregroundColor ?? theme.textTheme.labelColor ?? theme.labelColor;
    final resolvedFont = textWidget.font ?? theme.textTheme.font ?? cnFontFromTextStyle(theme.typography.body);

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

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _computeMapPatch(Map<String, dynamic> previous, Map<String, dynamic> next) {
    final patch = <String, dynamic>{};
    final keys = <String>{...previous.keys, ...next.keys};

    for (final key in keys) {
      final hadPrevious = previous.containsKey(key);
      final hasNext = next.containsKey(key);
      final oldValue = hadPrevious ? previous[key] : null;
      final newValue = hasNext ? next[key] : null;

      if (!hasNext) {
        patch[key] = null;
        continue;
      }

      if (!hadPrevious) {
        patch[key] = newValue;
        continue;
      }

      if (key == 'font' && oldValue is Map<String, dynamic> && newValue is Map<String, dynamic>) {
        if (jsonEncode(oldValue) != jsonEncode(newValue)) {
          // Keep font updates atomic: if any sub-field changes, send full font map.
          patch[key] = newValue;
        }
        continue;
      }

      if (oldValue is Map<String, dynamic> && newValue is Map<String, dynamic>) {
        final nested = _computeMapPatch(oldValue, newValue);
        if (nested.isNotEmpty) {
          patch[key] = nested;
        }
        continue;
      }

      if (jsonEncode(oldValue) != jsonEncode(newValue)) {
        patch[key] = newValue;
      }
    }

    return patch;
  }

  double _defaultHeightFromFonts() {
    final theme = CNTheme.of(context);
    final themeTextFont = theme.textTheme.font ?? cnFontFromTextStyle(theme.typography.body);
    final iconTextFont = theme.imageTheme.font ?? cnFontFromTextStyle(theme.typography.body);
    final primaryFont = widget.text.font ?? themeTextFont;
    final secondaryFont = widget.secondaryText?.font ?? themeTextFont;
    final iconFont = widget.icon?.font ?? iconTextFont;
    final primaryPoints = primaryFont.size.points ?? 17.0;
    final secondaryPoints = secondaryFont.size.points ?? 17.0;
    final iconPoints = iconFont.size.points ?? 17.0;
    return primaryPoints > secondaryPoints
        ? (primaryPoints > iconPoints ? primaryPoints : iconPoints)
        : (secondaryPoints > iconPoints ? secondaryPoints : iconPoints);
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    debugPrint('[CNLabel][Dart] Received intrinsic size change: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;
    setState(() {
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  Future<void> _onPlatformViewCreated(int id) async {
    final channel = MethodChannel('CupertinoNativeLabel_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    await _requestIntrinsicSize();
  }

  Future<void> _requestIntrinsicSize() async {
    debugPrint('[CNLabel][Dart] Requesting intrinsic size...');
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

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNLabel][Dart] Sending full update via setData');
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      await _requestIntrinsicSize();
      return;
    }

    final patch = _computeMapPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      debugPrint('[CNLabel][Dart] No patch to send (payload unchanged)');
      _lastSerializedPayload = serializedPayload;
      return;
    }

    debugPrint('[CNLabel][Dart] Sending patch via applyPatch: ${jsonEncode(patch)}');
    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
    await _requestIntrinsicSize();
  }

  Map<String, dynamic> _toPayload() {
    final map = widget.toMap(context, frameWidth: _layoutWidth, frameHeight: _layoutHeight);

    final primaryText = map.remove('primaryText') as Map<String, dynamic>?;
    final secondaryText = map.remove('secondaryText');
    final icon = map.remove('icon');

    map['nodes'] = {'primaryText': primaryText, 'secondaryText': secondaryText, 'icon': icon};

    return map;
  }
}

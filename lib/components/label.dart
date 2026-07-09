import 'dart:convert';

import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/paddable.dart';
import 'package:cupertino_native/components/taggable.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
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

  @override
  String get buttonChildType => 'label';

  @override
  State<CNLabel> createState() => _CNLabelState();

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
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return toMap(context, ignoreTheme: ignoreTheme);
  }

  // ignore: public_member_api_docs
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false, Map<String, dynamic>? layoutConstraintsPayload}) {
    final payload = <String, dynamic>{
      'nodes': {
        'primaryText': text.toMap(context, ignoreTheme: ignoreTheme),
        'secondaryText': secondaryText?.toMap(context, ignoreTheme: ignoreTheme),
        'icon': icon?.toMap(context, ignoreTheme: ignoreTheme),
      },
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'labelStyle': labelStyle.name,
      if (labelReservedIconWidth != null) 'labelReservedIconWidth': labelReservedIconWidth,
      if (labelIconToTitleSpacing != null) 'labelIconToTitleSpacing': labelIconToTitleSpacing,
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: layoutConstraintsPayload,
      explicitConstraints: modifiers.constraints,
    );

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

class _CNLabelState extends State<CNLabel> with CNWidgetDebugIdMixin<CNLabel> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  final CNLayoutConstraintsSyncState _layoutConstraintsSyncState = CNLayoutConstraintsSyncState();

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
    debugPrint('$debugLogPrefix received intrinsic size change: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;

    final normalizedWidth = width > 0 ? width : null;
    final normalizedHeight = height > 0 ? height : null;
    if (normalizedWidth == _intrinsicWidth && normalizedHeight == _intrinsicHeight) {
      return;
    }

    setState(() {
      _intrinsicWidth = normalizedWidth;
      _intrinsicHeight = normalizedHeight;
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
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('$debugLogPrefix sending full update via setData');
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);

      return;
    }

    final patch = _computeMapPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      debugPrint('$debugLogPrefix no patch to send (payload unchanged)');
      _lastSerializedPayload = serializedPayload;
      return;
    }

    debugPrint('$debugLogPrefix sending patch via applyPatch: ${jsonEncode(patch)}');
    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _toPayload() {
    final payload = widget.toMap(context, layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload);
    writeDebugWidgetId(payload);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final shrinkWrap = widget.modifiers.shrinkWrap;
        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: widget.modifiers.constraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final defaultHeight = _defaultHeightFromFonts();
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final resolvedWidth = hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _kDefaultLabelWidth;
        final resolvedHeight = hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? defaultHeight;

        Widget platformView = AppKitView(
          viewType: 'CupertinoNativeLabel',
          creationParams: _toPayload(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        if (!shrinkWrap) {
          platformView = ConstrainedBox(constraints: resolvedConstraints, child: platformView);
          return platformView;
        }

        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
      },
    );
  }
}

import 'dart:convert';

import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/channel/payload_patch.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/paddable.dart';
import 'package:cupertino_native/components/taggable.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/components/widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultWidth = 24.0;
const double _kDefaultHeight = 24.0;

/// Represents an image that can be used in various components, such as menu items or buttons.
/// This class encapsulates the necessary information to render a system symbol on Apple platforms,
/// along with optional configuration for customizing its appearance.
class CNImage extends StatefulWidget with CNButtonChild, CNMenuChild, CNViewModifiable, CNPaddable, CNTaggable {
  /// Creates a CNImage with the given [systemSymbolName].
  const CNImage({
    super.key,
    required this.systemSymbolName,
    this.badge,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.font,
    this.modifiers,
  }) : assert(badge == null || badge is String || badge is int, 'Badge must be a String or int.');

  /// Optional badge shown next to the menu item when used inside [CNMenu].
  final Object? badge;

  /// Optional font used to render the symbol image.
  final CNFont? font;

  /// Optional per-image foreground style colors.
  ///
  /// When [symbolRenderingMode] is [CNSymbolRenderingMode.palette], up to three
  /// colors are used as the palette.
  final List<Color>? foregroundStyleColors;

  /// Optional color rendering mode for SF Symbols.
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;

  /// Optional rendering mode for SF Symbols.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// The name of the system symbol to render, which corresponds to an SF Symbol on Apple platforms.
  final String systemSymbolName;

  @override
  final CNViewModifiers? modifiers;

  @override
  String get buttonChildType => 'image';

  @override
  State<CNImage> createState() => _CNImageState();

  @override
  String get menuChildType => 'image';

  @override
  List<Object?> get props => [
    systemSymbolName,
    badge,
    symbolRenderingMode,
    symbolColorRenderingMode,
    foregroundStyleColors,
    modifiers,
    font,
  ];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) => toMap(context, ignoreTheme: ignoreTheme);

  /// Serializes this image to JSON for communication with the native platform.
  String toJson(BuildContext context, {bool ignoreTheme = false}) {
    return jsonEncode(toMap(context, ignoreTheme: ignoreTheme));
  }

  /// Serializes this image to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false, Map<String, dynamic>? layoutConstraintsPayload}) {
    final imageTheme = ignoreTheme ? null : CNTheme.of(context).imageTheme;
    final resolvedRenderingMode = symbolRenderingMode ?? imageTheme?.symbolRenderingMode;
    final resolvedColorRenderingMode = symbolColorRenderingMode ?? imageTheme?.symbolColorRenderingMode;
    final resolvedForegroundStyleColors = foregroundStyleColors ?? imageTheme?.foregroundStyleColors;
    final resolvedFont = font ?? imageTheme?.font;

    final payload = <String, dynamic>{
      'systemSymbolName': systemSymbolName,
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'symbolRenderingMode': resolvedRenderingMode?.name,
      'symbolColorRenderingMode': resolvedColorRenderingMode?.name,
      'foregroundStyleColors': resolvedForegroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'font': resolvedFont?.toMap(),
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: layoutConstraintsPayload,
      explicitConstraints: modifiers?.constraints,
    );

    writeModifiers(payload, context);
    return payload;
  }
}

class _CNImageState extends State<CNImage> with CNWidgetDebugIdMixin<CNImage> {
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
  void didUpdateWidget(covariant CNImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _cacheCurrentProps() {
    final payload = widget.toMap(context, layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload);
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'intrinsicSizeChanged':
        final args = call.arguments as Map?;
        final width = (args?['width'] as num?)?.toDouble();
        final height = (args?['height'] as num?)?.toDouble();

        if (!mounted || width == null || height == null) {
          break;
        }

        final normalizedWidth = width > 0 ? width : null;
        final normalizedHeight = height > 0 ? height : null;
        if (normalizedWidth == _intrinsicWidth && normalizedHeight == _intrinsicHeight) {
          break;
        }

        setState(() {
          _intrinsicWidth = normalizedWidth;
          _intrinsicHeight = normalizedHeight;
        });
        break;
      default:
        break;
    }

    return null;
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeImage_$id')..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = widget.toMap(context, layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload);
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    final patch = computeJsonSafePatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

    Map<String, dynamic> _toPayload() {
    final payload = widget.toMap(context, layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveShrinkWrap = widget.modifiers?.shrinkWrap ?? false;
        final explicitConstraints = widget.modifiers?.constraints;
        final hasBoundedParentSize = constraints.hasBoundedWidth || constraints.hasBoundedHeight;
        final hasBoundedModifierSize =
            (explicitConstraints?.hasBoundedWidth ?? false) || (explicitConstraints?.hasBoundedHeight ?? false);

        assert(
          effectiveShrinkWrap || hasBoundedModifierSize || hasBoundedParentSize,
          'CNButton requires at least one bounded axis when shrinkWrap is false. '
          'Provide bounded constraints in CNViewModifiers.constraints or place CNButton in a parent with bounded size.',
        );

        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: explicitConstraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final intrinsicOrDefaultWidth = _intrinsicWidth ?? _kDefaultWidth;
        final intrinsicOrDefaultHeight = _intrinsicHeight ?? _kDefaultHeight;

        final resolvedWidth = effectiveShrinkWrap
            ? (hasBoundedWidth ? intrinsicOrDefaultWidth.clamp(0.0, constraints.maxWidth).toDouble() : intrinsicOrDefaultWidth)
            : (resolvedConstraints.hasBoundedWidth ? resolvedConstraints.maxWidth : intrinsicOrDefaultWidth);
        final resolvedHeight = effectiveShrinkWrap
            ? (hasBoundedHeight ? intrinsicOrDefaultHeight.clamp(0.0, constraints.maxHeight).toDouble() : intrinsicOrDefaultHeight)
            : (resolvedConstraints.hasBoundedHeight ? resolvedConstraints.maxHeight : intrinsicOrDefaultHeight);

        final creationParams = _toPayload();

        Widget nativeView = AppKitView(
          viewType: 'CupertinoNativeImage',
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        if (!effectiveShrinkWrap) {
          // Platform views expand to biggest constraints; force finite fallback
          // sizes on unbounded axes to avoid Infinity during Wrap/Column layout.
          nativeView = SizedBox(
            width: resolvedConstraints.hasBoundedWidth ? null : resolvedWidth,
            height: resolvedConstraints.hasBoundedHeight ? null : resolvedHeight,
            child: nativeView,
          );
          nativeView = ConstrainedBox(constraints: resolvedConstraints, child: nativeView);
          return nativeView;
        }

        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: nativeView);
      },
    );
  }
}

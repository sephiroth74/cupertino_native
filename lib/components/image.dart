import 'dart:convert';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/paddable.dart';
import 'package:cupertino_native/components/taggable.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
    this.viewModifiers,
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
  final CNViewModifiers? viewModifiers;

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
    viewModifiers,
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
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false}) {
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

    writeViewModifiers(payload, context);
    return payload;
  }
}

class _CNImageState extends State<CNImage> {
  MethodChannel? _channel;
  String? _lastSerializedPayload;

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
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    return null;
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeImage_$id')..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  String _serializeCurrentPayload() => jsonEncode(widget.toMap(context));

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = widget.toMap(context);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await channel.invokeMethod('setImage', payload);
      _cacheCurrentProps();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      Widget fallback = const Icon(CupertinoIcons.question_circle);
      if (widget.padding != null) {
        fallback = Padding(padding: widget.padding!, child: fallback);
      }
      return fallback;
    }

    final creationParams = widget.toMap(context);

    return AppKitView(
      viewType: 'CupertinoNativeImage',
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: creationParams,
      onPlatformViewCreated: _onPlatformViewCreated,
    );
  }
}

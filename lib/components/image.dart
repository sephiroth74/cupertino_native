import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents an image that can be used in various components, such as menu items or buttons.
/// This class encapsulates the necessary information to render a system symbol on Apple platforms,
/// along with optional configuration for customizing its appearance.
class CNImage extends StatefulWidget implements CNChannelSerializable {
  /// Creates a CNImage with the given [systemSymbolName].
  const CNImage({
    super.key,
    required this.systemSymbolName,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.tint,
    this.font,
  });

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

  /// Optional tint color applied after symbol configuration.
  final Color? tint;

  @override
  State<CNImage> createState() => _CNImageState();

  @override
  Map<String, dynamic> toChannelMap(BuildContext context) => toMap(context);

  /// Serializes this image to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'systemSymbolName': systemSymbolName,
      'symbolRenderingMode': symbolRenderingMode?.name,
      'symbolColorRenderingMode': symbolColorRenderingMode?.name,
      'foregroundStyleColors': foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'tint': resolveColorToArgb(tint, context),
      'font': font?.toMap(),
    };
  }

  /// Serializes this image to JSON for communication with the native platform.
  String toJson(BuildContext context) {
    return jsonEncode(toMap(context));
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

  String _serializeCurrentPayload() => jsonEncode(widget.toMap(context));

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeImage_$id')..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    return null;
  }

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

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
      return const Icon(CupertinoIcons.question_circle);
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

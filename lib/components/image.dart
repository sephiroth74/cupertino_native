import 'dart:convert';

import 'package:cupertino_native/channel/params.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
/// Represents an image that can be used in various components, such as menu items or buttons.
/// This class encapsulates the necessary information to render a system symbol on Apple platforms,
/// along with optional configuration for customizing its appearance.
class CNImage extends StatefulWidget {
  /// The name of the system symbol to render, which corresponds to an SF Symbol on Apple platforms.
  final String systemSymbolName;

  /// An optional symbol configuration that can be used to customize the appearance of the menu item.
  final CNSymbolConfiguration symbolConfiguration;

  /// Creates a CNImage with the given [systemSymbolName] and an optional [symbolConfiguration].
  const CNImage({
    super.key,
    required this.systemSymbolName,
    this.symbolConfiguration = const CNSymbolConfiguration(type: CNSymbolConfigurationType.defaultConfiguration),
  });

  /// Serializes this image to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context) {
    return {'systemSymbolName': systemSymbolName, 'symbolConfiguration': symbolConfiguration.toMap(context)};
  }

  /// Serializes this image to JSON for communication with the native platform.
  String toJson(BuildContext context) {
    return jsonEncode(toMap(context));
  }

  @override
  State<CNImage> createState() => _CNImageState();
}

class _CNImageState extends State<CNImage> {
  MethodChannel? _channel;
  String? _lastSystemSymbolName;
  CNSymbolConfiguration? _lastSymbolConfiguration;

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

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('CupertinoNativeImage_$id')
      ..setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    return null;
  }

  void _cacheCurrentProps() {
    _lastSystemSymbolName = widget.systemSymbolName;
    _lastSymbolConfiguration = widget.symbolConfiguration;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastSystemSymbolName != widget.systemSymbolName ||
        _lastSymbolConfiguration != widget.symbolConfiguration) {
      await channel.invokeMethod('setImage', widget.toMap(context));
      _cacheCurrentProps();
    }
  }
}

/// Symbol rendering modes for menu item icons.
enum CNSymbolConfigurationType {
  /// Use the platform default symbol rendering.
  defaultConfiguration,

  /// Use hierarchical rendering with a single tint.
  hierarchical,

  /// Use monochrome rendering with a single tint.
  monochrome,

  /// Use palette rendering with multiple colors.
  palette,

  /// Use SF Symbols multicolor rendering.
  multicolor,
}

/// Configuration for symbol rendering on a [CNMenuItem].
class CNSymbolConfiguration extends Equatable {
  /// The selected symbol rendering mode.
  final CNSymbolConfigurationType type;

  /// Optional color for hierarchical rendering.
  final Color? hierarchicalColor;

  /// Optional colors for palette rendering.
  final List<Color>? paletteColors;

  /// Optional color for monochrome rendering.
  final Color? monochromeColor;

  /// Creates a symbol configuration with the specified properties. The [type] determines which properties are relevant for rendering.
  const CNSymbolConfiguration({required this.type, this.hierarchicalColor, this.paletteColors, this.monochromeColor});

  /// Private constructor for internal use by factory methods.
  const CNSymbolConfiguration._({required this.type, this.hierarchicalColor, this.paletteColors, this.monochromeColor});

  /// Creates a default symbol configuration.
  factory CNSymbolConfiguration.defaultConfiguration() => CNSymbolConfiguration._(type: CNSymbolConfigurationType.defaultConfiguration);

  /// Creates a hierarchical symbol configuration.
  factory CNSymbolConfiguration.hierarchical(Color? color) {
    return CNSymbolConfiguration._(type: CNSymbolConfigurationType.hierarchical, hierarchicalColor: color);
  }

  /// Creates a monochrome symbol configuration.
  factory CNSymbolConfiguration.monochrome(Color? color) {
    return CNSymbolConfiguration._(type: CNSymbolConfigurationType.monochrome, monochromeColor: color);
  }

  /// Creates a palette symbol configuration.
  factory CNSymbolConfiguration.palette(List<Color>? colors) {
    return CNSymbolConfiguration._(type: CNSymbolConfigurationType.palette, paletteColors: colors);
  }

  /// Creates a multicolor symbol configuration.
  factory CNSymbolConfiguration.multicolor() => CNSymbolConfiguration._(type: CNSymbolConfigurationType.multicolor);

  /// Serializes the symbol configuration to JSON for native consumption.
  Map<String, dynamic> toMap(BuildContext context) {
    switch (type) {
      case CNSymbolConfigurationType.defaultConfiguration:
        return {'type': 'default'};
      case CNSymbolConfigurationType.hierarchical:
        return {'type': 'hierarchical', 'color': resolveColorToArgb(hierarchicalColor, context)};
      case CNSymbolConfigurationType.monochrome:
        return {'type': 'monochrome', 'color': resolveColorToArgb(monochromeColor, context)};
      case CNSymbolConfigurationType.palette:
        return {'type': 'palette', 'colors': paletteColors?.map((c) => resolveColorToArgb(c, context)).toList()};
      case CNSymbolConfigurationType.multicolor:
        return {'type': 'multicolor'};
    }
  }

  /// Serializes the symbol configuration to JSON for native consumption.
  String toJson(BuildContext context) {
    return jsonEncode(toMap(context));
  }

  @override
  List<Object?> get props => [type, hierarchicalColor, monochromeColor, paletteColors];
}

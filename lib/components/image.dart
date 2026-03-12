import 'package:cupertino_native/channel/params.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Represents an image that can be used in various components, such as menu items or buttons.
/// This class encapsulates the necessary information to render a system symbol on Apple platforms,
/// along with optional configuration for customizing its appearance.
class CNImage with EquatableMixin {
  /// The name of the system symbol to render, which corresponds to an SF Symbol on Apple platforms.
  final String systemSymbolName;

  /// An optional symbol configuration that can be used to customize the appearance of the menu item.
  final CNSymbolConfiguration symbolConfiguration;

  /// Creates a CNImage with the given [systemSymbolName] and an optional [symbolConfiguration].
  const CNImage({
    required this.systemSymbolName,
    this.symbolConfiguration = const CNSymbolConfiguration(
      type: CNSymbolConfigurationType.defaultConfiguration,
    ),
  });

  @override
  List<Object?> get props => [systemSymbolName, symbolConfiguration];

  /// Serializes this image to JSON for communication with the native platform.
  String toJson(BuildContext context) {
    return '''
    {
      "systemSymbolName": "$systemSymbolName",
      "symbolConfiguration": ${symbolConfiguration.toJson(context)}
    }
    ''';
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
  const CNSymbolConfiguration({
    required this.type,
    this.hierarchicalColor,
    this.paletteColors,
    this.monochromeColor,
  });

  /// Private constructor for internal use by factory methods.
  const CNSymbolConfiguration._({
    required this.type,
    this.hierarchicalColor,
    this.paletteColors,
    this.monochromeColor,
  });

  /// Creates a default symbol configuration.
  factory CNSymbolConfiguration.defaultConfiguration() =>
      CNSymbolConfiguration._(
        type: CNSymbolConfigurationType.defaultConfiguration,
      );

  /// Creates a hierarchical symbol configuration.
  factory CNSymbolConfiguration.hierarchical(Color? color) {
    return CNSymbolConfiguration._(
      type: CNSymbolConfigurationType.hierarchical,
      hierarchicalColor: color,
    );
  }

  /// Creates a monochrome symbol configuration.
  factory CNSymbolConfiguration.monochrome(Color? color) {
    return CNSymbolConfiguration._(
      type: CNSymbolConfigurationType.monochrome,
      monochromeColor: color,
    );
  }

  /// Creates a palette symbol configuration.
  factory CNSymbolConfiguration.palette(List<Color>? colors) {
    return CNSymbolConfiguration._(
      type: CNSymbolConfigurationType.palette,
      paletteColors: colors,
    );
  }

  /// Creates a multicolor symbol configuration.
  factory CNSymbolConfiguration.multicolor() =>
      CNSymbolConfiguration._(type: CNSymbolConfigurationType.multicolor);

  /// Serializes the symbol configuration to JSON for native consumption.
  String toJson(BuildContext context) {
    switch (type) {
      case CNSymbolConfigurationType.defaultConfiguration:
        return '{"type": "default"}';
      case CNSymbolConfigurationType.hierarchical:
        return '{"type": "hierarchical", "color": ${resolveColorToArgb(hierarchicalColor, context)}}';
      case CNSymbolConfigurationType.monochrome:
        return '{"type": "monochrome", "color": ${resolveColorToArgb(monochromeColor, context)}}';
      case CNSymbolConfigurationType.palette:
        return '{"type": "palette", "colors": ${paletteColors != null ? paletteColors!.map((c) => resolveColorToArgb(c, context)).toList() : 'null'}}';
      case CNSymbolConfigurationType.multicolor:
        return '{"type": "multicolor"}';
    }
  }

  @override
  List<Object?> get props => [
    type,
    hierarchicalColor,
    monochromeColor,
    paletteColors,
  ];
}

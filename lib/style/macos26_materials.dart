import 'package:flutter/cupertino.dart';

/// Glass material with backdrop blur and opacity
/// Designed for Liquid Glass aesthetic in macOS 26
class CNGlassMaterial {
  /// Creates a glass material with specified blur radius, base color, and opacity.
  const CNGlassMaterial({required this.blurRadius, required this.baseColor, required this.opacity});

  /// List of all glass materials, ordered from thinnest to thickest
  static const List<CNGlassMaterial> all = [ultraThin, thin, medium, thick, ultraThick];

  /// Medium material: 15px blur, 60% opacity
  static const CNGlassMaterial medium = CNGlassMaterial(
    blurRadius: 15,
    baseColor: Color(0xFFF6F6F6), // #F6F6F6
    opacity: 0.60,
  );

  /// Thick material: 15px blur, 72% opacity
  static const CNGlassMaterial thick = CNGlassMaterial(
    blurRadius: 15,
    baseColor: Color(0xFFF6F6F6), // #F6F6F6
    opacity: 0.72,
  );

  /// Thin material: 15px blur, 48% opacity
  static const CNGlassMaterial thin = CNGlassMaterial(
    blurRadius: 15,
    baseColor: Color(0xFFF6F6F6), // #F6F6F6
    opacity: 0.48,
  );

  /// Ultra Thick material: 15px blur, 84% opacity
  static const CNGlassMaterial ultraThick = CNGlassMaterial(
    blurRadius: 15,
    baseColor: Color(0xFFF6F6F6), // #F6F6F6
    opacity: 0.84,
  );

  /// Ultra Thin material: 15px blur, 36% opacity
  static const CNGlassMaterial ultraThin = CNGlassMaterial(
    blurRadius: 15,
    baseColor: Color(0xFFF6F6F6), // #F6F6F6
    opacity: 0.36,
  );

  /// Base color (typically near-white)
  final Color baseColor;

  /// Blur radius in pixels
  final double blurRadius;

  /// Alpha opacity value (0-1)
  final double opacity;
}

/// Liquid Glass effect component with depth and tinting
/// Supports multiple sizes and light/dark modes
class CNLiquidGlassEffect {
  /// Creates a glass effect with the specified properties.
  const CNLiquidGlassEffect({
    required this.size,
    required this.shadowBlur,
    required this.shadowOpacity,
    required this.tintColor,
    required this.glassOpacity,
  });

  /// Glass overlay opacity
  final double glassOpacity;

  /// Shadow blur radius
  final double shadowBlur;

  /// Shadow opacity (0-1)
  final double shadowOpacity;

  /// Component size category
  final CNLiquidGlassSize size;

  /// Tint color applied to glass effect
  final CupertinoDynamicColor tintColor;

  /// Large Liquid Glass - Light mode
  /// Shadow: 8px blur, 12% opacity
  /// Tint: near-white with color-dodge blend
  static CNLiquidGlassEffect largeLightMode({required bool isPrimary}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.large,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFFAFAFA), // #FAFAFA light
        darkColor: Color(0xFFFAFAFA),
      ),
      glassOpacity: 0.80,
    );
  }

  /// Large Liquid Glass - Dark mode
  /// Shadow: 8px blur, 12% opacity
  /// Tint: with color-burn blend and increased opacity
  static CNLiquidGlassEffect largeDarkMode({required bool isPrimary}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.large,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFCCCCCC), // #CCCCCC
        darkColor: Color(0xFFCCCCCC),
      ),
      glassOpacity: 0.85,
    );
  }

  /// Medium Liquid Glass - Light mode
  /// Shadow: 8px blur, 12% opacity
  /// Tint: 67% opacity
  static CNLiquidGlassEffect mediumLightMode({required bool isPrimary}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.medium,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF5F5F5), // #F5F5F5
        darkColor: Color(0xFFF5F5F5),
      ),
      glassOpacity: 0.67,
    );
  }

  /// Medium Liquid Glass - Dark mode
  /// Shadow: 8px blur, 12% opacity
  /// Tint: 67% opacity
  static CNLiquidGlassEffect mediumDarkMode({required bool isPrimary}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.medium,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFCCCCCC), // #CCCCCC
        darkColor: Color(0xFFCCCCCC),
      ),
      glassOpacity: 0.67,
    );
  }

  /// Small Liquid Glass - Light mode with optional primary state
  /// Rounded to circle (1000px radius)
  /// Shadow: 8px blur, 12% opacity
  static CNLiquidGlassEffect smallLightMode({bool isPrimary = false}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.small,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFF0091FF), // #0091FF (blue accent)
        darkColor: Color(0xFF0091FF),
      ),
      glassOpacity: 0.5,
    );
  }

  /// Small Liquid Glass - Dark mode with optional primary state
  /// Rounded to circle (1000px radius)
  /// Shadow: 8px blur, 12% opacity
  static CNLiquidGlassEffect smallDarkMode({bool isPrimary = false}) {
    return CNLiquidGlassEffect(
      size: CNLiquidGlassSize.small,
      shadowBlur: 8,
      shadowOpacity: 0.12,
      tintColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0xFF0091FF), // #0091FF (blue accent)
        darkColor: Color(0xFF0091FF),
      ),
      glassOpacity: 0.5,
    );
  }
}

/// Size category for Liquid Glass effects
enum CNLiquidGlassSize {
  /// Large: 160px components
  large,

  /// Medium: 160px components
  medium,

  /// Small: 48px components
  small,
}

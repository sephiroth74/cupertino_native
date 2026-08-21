import 'package:flutter/painting.dart';

/// Extension methods for the [Color] class.
extension ColorExtension on Color {
  /// Returns a new color with the opacity multiplied by [factor].
  Color multiplyOpacity(double factor) {
    assert(a >= 0.0);
    if (factor == 1.0) {
      return this;
    } else if (factor == 0.0) {
      return withAlpha(0);
    }
    final newOpacity = (a * factor).clamp(0, 1.0);
    final alpha = (newOpacity * 255).round();
    return withAlpha(alpha);
  }

  /// Returns a new color with the luminance multiplied by [factor].
  Color multiplyLuminance(double factor) {
    final hslColor = HSLColor.fromColor(this);
    return (hslColor.withLightness(
      (hslColor.lightness * factor).clamp(0.0, 1.0),
    )).toColor();
  }

  /// Returns a new color with the luminance set to [luminance].
  Color withLuminance(double luminance) {
    final hslColor = HSLColor.fromColor(this);
    return (hslColor.withLightness(luminance)).toColor();
  }

  /// Computes the lightness of the color.
  double computeLightness() {
    final hslColor = HSLColor.fromColor(this);
    return hslColor.lightness;
  }

  /// Merges this color with [other] based on the alpha value of [other].
  Color merge(Color other) {
    final amount = other.a;
    final newR = (other.r * amount + r * (1 - amount));
    final newG = (other.g * amount + g * (1 - amount));
    final newB = (other.b * amount + b * (1 - amount));
    return withValues(alpha: a, red: newR, green: newG, blue: newB);
  }

  // ignore: deprecated_member_use
  /// Returns a new color with the specified [alpha], [red], [green], and [blue] values.
  String toHexString() {
    final alphaInt = (a * 255).round();
    final redInt = (r * 255).round();
    final greenInt = (g * 255).round();
    final blueInt = (b * 255).round();
    return '#${alphaInt.toRadixString(16).padLeft(2, '0')}'
        '${redInt.toRadixString(16).padLeft(2, '0')}'
        '${greenInt.toRadixString(16).padLeft(2, '0')}'
        '${blueInt.toRadixString(16).padLeft(2, '0')}';
  }
}

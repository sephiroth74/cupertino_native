import 'package:flutter/cupertino.dart';

import '../theme/cn_theme.dart';

/// Extension methods for context-aware resolution of [Color] and [CupertinoDynamicColor] against the nearest [CNTheme].
extension CNColor on Color {
  /// Resolves [this] against [context] when it is a [CupertinoDynamicColor]; otherwise returns it unchanged.
  Color resolveFromContext(BuildContext context) =>
      this is CupertinoDynamicColor
      ? (this as CupertinoDynamicColor).resolveWithContext(context)
      : this;

  Color get darkColor => this is CupertinoDynamicColor
      ? (this as CupertinoDynamicColor).darkColor
      : this;

  Color get color => this is CupertinoDynamicColor
      ? (this as CupertinoDynamicColor).color
      : this;
}

/// Context-aware resolution for [CupertinoDynamicColor], mirroring AppKit's
/// `resolveFromContext` semantics but sourcing the brightness from [CNTheme]
/// instead of an AppKit theme.
///
/// This is the `cupertino_native` counterpart of appkit_ui_elements'
/// `AppKitDynamicColor on CupertinoDynamicColor` extension: call-sites keep
/// writing `color.resolveFromContext(context)` and the method resolves the
/// correct variant using the nearest [CNTheme] (falling back to the platform
/// brightness from [MediaQuery] when no theme is in scope), the ambient
/// [CupertinoUserInterfaceLevel] and the high-contrast accessibility flag.
extension CNDynamicColor on CupertinoDynamicColor {
  /// Whether this color changes with platform brightness (light vs. dark).
  bool get isPlatformBrightnessDependent {
    return color != darkColor ||
        elevatedColor != darkElevatedColor ||
        highContrastColor != darkHighContrastColor ||
        highContrastElevatedColor != darkHighContrastElevatedColor;
  }

  /// Whether this color changes when high-contrast accessibility is enabled.
  bool get isHighContrastDependent {
    return color != highContrastColor ||
        darkColor != darkHighContrastColor ||
        elevatedColor != highContrastElevatedColor ||
        darkElevatedColor != darkHighContrastElevatedColor;
  }

  /// Whether this color changes with the interface elevation level.
  bool get isInterfaceElevationDependent {
    return color != elevatedColor ||
        darkColor != darkElevatedColor ||
        highContrastColor != highContrastElevatedColor ||
        darkHighContrastColor != darkHighContrastElevatedColor;
  }

  /// Resolves the color for the given [brightness] only (light/dark).
  Color resolveFromBrightness(Brightness brightness) =>
      resolveWithBrightness(brightness);

  /// Resolves the color for the given [brightness] only (light/dark).
  Color resolveWithBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return isDark ? darkColor : color;
  }

  /// Resolves the color against [context], reading the brightness from the
  /// nearest [CNTheme].
  Color resolveFromContext(BuildContext context) => resolveWithContext(context);

  /// Resolves the color against [context] taking brightness (from [CNTheme]),
  /// interface elevation and high-contrast into account.
  Color resolveWithContext(BuildContext context) {
    final Brightness brightness = isPlatformBrightnessDependent
        ? CNTheme.maybeBrightnessOf(context) ?? Brightness.light
        : Brightness.light;

    final CupertinoUserInterfaceLevelData level = isInterfaceElevationDependent
        ? CupertinoUserInterfaceLevel.maybeOf(context) ??
              CupertinoUserInterfaceLevelData.base
        : CupertinoUserInterfaceLevelData.base;

    final bool highContrast =
        isHighContrastDependent &&
        (MediaQuery.maybeHighContrastOf(context) ?? false);

    final Color resolved = switch ((brightness, level, highContrast)) {
      (Brightness.light, CupertinoUserInterfaceLevelData.base, false) => color,
      (Brightness.light, CupertinoUserInterfaceLevelData.base, true) =>
        highContrastColor,
      (Brightness.light, CupertinoUserInterfaceLevelData.elevated, false) =>
        elevatedColor,
      (Brightness.light, CupertinoUserInterfaceLevelData.elevated, true) =>
        highContrastElevatedColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.base, false) =>
        darkColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.base, true) =>
        darkHighContrastColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.elevated, false) =>
        darkElevatedColor,
      (Brightness.dark, CupertinoUserInterfaceLevelData.elevated, true) =>
        darkHighContrastElevatedColor,
    };

    Element? debugContext;
    assert(() {
      debugContext = context as Element;
      return true;
    }());
    return CNResolvedDynamicColor._(
      resolved,
      darkColor,
      highContrastColor,
      darkHighContrastColor,
      elevatedColor,
      darkElevatedColor,
      highContrastElevatedColor,
      darkHighContrastElevatedColor,
      debugContext,
    );
  }

  /// Resolves [resolvable] against [context] when it is a
  /// [CupertinoDynamicColor]; otherwise returns it unchanged.
  static Color resolve(BuildContext context, Color resolvable) {
    if (resolvable is! CupertinoDynamicColor) {
      return resolvable;
    }
    return resolvable.resolveWithContext(context);
  }
}

/// A [CupertinoDynamicColor] whose primary [color] has already been resolved
/// for a specific context, while retaining the other variants.
class CNResolvedDynamicColor extends CupertinoDynamicColor {
  const CNResolvedDynamicColor._(
    Color color,
    Color darkColor,
    Color highContrastColor,
    Color darkHighContrastColor,
    Color elevatedColor,
    Color darkElevatedColor,
    Color highContrastElevatedColor,
    Color darkHighContrastElevatedColor,
    // ignore: unused_element_parameter
    Element? debugResolveContext,
  ) : super(
        color: color,
        darkColor: darkColor,
        highContrastColor: highContrastColor,
        darkHighContrastColor: darkHighContrastColor,
        elevatedColor: elevatedColor,
        darkElevatedColor: darkElevatedColor,
        highContrastElevatedColor: highContrastElevatedColor,
        darkHighContrastElevatedColor: darkHighContrastElevatedColor,
      );
}

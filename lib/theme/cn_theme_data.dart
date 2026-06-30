import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../style/cn_typography.dart';
import '../style/macos26_colors.dart';
import '../style/macos26_materials.dart';

/// Widget-specific visual overrides for [CNToggle].
class CNToggleThemeData extends Equatable {
  /// Creates toggle theme overrides.
  const CNToggleThemeData({this.tint});

  /// Toggle tint override.
  final Color? tint;

  @override
  List<Object?> get props => [tint];

  /// Returns a copy with selected values replaced.
  CNToggleThemeData copyWith({Color? tint}) {
    return CNToggleThemeData(tint: tint ?? this.tint);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNToggleThemeData merge(CNToggleThemeData? other) {
    if (other == null) return this;
    return copyWith(tint: other.tint);
  }

  /// Linearly interpolates between two toggle themes.
  static CNToggleThemeData lerp(CNToggleThemeData a, CNToggleThemeData b, double t) {
    return CNToggleThemeData(tint: Color.lerp(a.tint, b.tint, t));
  }
}

/// Defines the semantic color tokens used by [CNTheme].
class CNThemeData extends Equatable {
  /// Creates a theme configuration with semantic defaults for the given brightness.
  factory CNThemeData({
    Brightness brightness = Brightness.light,
    Color? primaryColor,
    Color? secondaryColor,
    Color? destructiveColor,
    Color? canvasColor,
    Color? groupedBackgroundColor,
    Color? labelColor,
    Color? secondaryLabelColor,
    Color? separatorColor,
    Color? fillPrimaryColor,
    Color? fillSecondaryColor,
    Color? fillTertiaryColor,
    CNTypography? typography,
    CNGlassMaterial? materialUltraThin,
    CNGlassMaterial? materialThin,
    CNGlassMaterial? materialMedium,
    CNGlassMaterial? materialThick,
    CNGlassMaterial? materialUltraThick,
    CNToggleThemeData? toggleTheme,
  }) {
    final isDark = brightness == Brightness.dark;

    final resolvedLabelColor = labelColor ?? (isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color);
    final resolvedPrimaryColor = primaryColor ?? (isDark ? MacOS26Colors.blue.darkColor : MacOS26Colors.blue.color);
    final resolvedToggleTheme = (toggleTheme ?? const CNToggleThemeData()).copyWith(
      tint: toggleTheme?.tint ?? resolvedPrimaryColor,
    );

    return CNThemeData.raw(
      brightness: brightness,
      primaryColor: resolvedPrimaryColor,
      secondaryColor: secondaryColor ?? (isDark ? MacOS26Colors.indigo.darkColor : MacOS26Colors.indigo.color),
      destructiveColor: destructiveColor ?? (isDark ? MacOS26Colors.red.darkColor : MacOS26Colors.red.color),
      canvasColor: canvasColor ?? (isDark ? CupertinoColors.systemBackground.darkColor : CupertinoColors.systemBackground.color),
      groupedBackgroundColor:
          groupedBackgroundColor ??
          (isDark ? CupertinoColors.systemGroupedBackground.darkColor : CupertinoColors.systemGroupedBackground.color),
      labelColor: resolvedLabelColor,
      secondaryLabelColor:
          secondaryLabelColor ?? (isDark ? CupertinoColors.secondaryLabel.darkColor : CupertinoColors.secondaryLabel.color),
      separatorColor: separatorColor ?? (isDark ? CupertinoColors.separator.darkColor : CupertinoColors.separator.color),
      fillPrimaryColor: fillPrimaryColor ?? (isDark ? MacOS26Colors.fillPrimary.darkColor : MacOS26Colors.fillPrimary.color),
      fillSecondaryColor:
          fillSecondaryColor ?? (isDark ? MacOS26Colors.fillSecondary.darkColor : MacOS26Colors.fillSecondary.color),
      fillTertiaryColor: fillTertiaryColor ?? (isDark ? MacOS26Colors.fillTertiary.darkColor : MacOS26Colors.fillTertiary.color),
      typography:
          typography ?? (isDark ? CNTypography.lightOpaque() : CNTypography.darkOpaque()).copyWith(color: resolvedLabelColor),
      materialUltraThin: materialUltraThin ?? CNGlassMaterial.ultraThin,
      materialThin: materialThin ?? CNGlassMaterial.thin,
      materialMedium: materialMedium ?? CNGlassMaterial.medium,
      materialThick: materialThick ?? CNGlassMaterial.thick,
      materialUltraThick: materialUltraThick ?? CNGlassMaterial.ultraThick,
      toggleTheme: resolvedToggleTheme,
    );
  }

  /// A default dark theme.
  factory CNThemeData.dark() => CNThemeData(brightness: Brightness.dark);

  /// The default fallback theme used when no [CNTheme] is in scope.
  factory CNThemeData.fallback({Brightness brightness = Brightness.light}) => CNThemeData(brightness: brightness);

  /// A default light theme.
  factory CNThemeData.light() => CNThemeData(brightness: Brightness.light);

  /// Creates a theme from exact values.
  const CNThemeData.raw({
    required this.brightness,
    required this.primaryColor,
    required this.secondaryColor,
    required this.destructiveColor,
    required this.canvasColor,
    required this.groupedBackgroundColor,
    required this.labelColor,
    required this.secondaryLabelColor,
    required this.separatorColor,
    required this.fillPrimaryColor,
    required this.fillSecondaryColor,
    required this.fillTertiaryColor,
    required this.typography,
    required this.materialUltraThin,
    required this.materialThin,
    required this.materialMedium,
    required this.materialThick,
    required this.materialUltraThick,
    required this.toggleTheme,
  });

  /// Overall brightness for descendant widgets.
  final Brightness brightness;

  /// Default surface background color.
  final Color canvasColor;

  /// Destructive action color.
  final Color destructiveColor;

  /// Primary translucent fill color.
  final Color fillPrimaryColor;

  /// Secondary translucent fill color.
  final Color fillSecondaryColor;

  /// Tertiary translucent fill color.
  final Color fillTertiaryColor;

  /// Grouped surface background color.
  final Color groupedBackgroundColor;

  /// Primary text color.
  final Color labelColor;

  /// Medium glass material preset.
  final CNGlassMaterial materialMedium;

  /// Thick glass material preset.
  final CNGlassMaterial materialThick;

  /// Thin glass material preset.
  final CNGlassMaterial materialThin;

  /// Highest density glass material preset.
  final CNGlassMaterial materialUltraThick;

  /// Lowest density glass material preset.
  final CNGlassMaterial materialUltraThin;

  /// Primary interactive color.
  final Color primaryColor;

  /// Secondary interactive color.
  final Color secondaryColor;

  /// Secondary text color.
  final Color secondaryLabelColor;

  /// Separator and stroke color.
  final Color separatorColor;

  /// HIG-aligned text styles.
  final CNTypography typography;

  /// Widget-specific toggle theme overrides.
  final CNToggleThemeData toggleTheme;

  /// Alias of [primaryColor] for accent-driven controls.
  Color get accentColor => primaryColor;

  @override
  List<Object?> get props => [
    brightness,
    primaryColor,
    secondaryColor,
    destructiveColor,
    canvasColor,
    groupedBackgroundColor,
    labelColor,
    secondaryLabelColor,
    separatorColor,
    fillPrimaryColor,
    fillSecondaryColor,
    fillTertiaryColor,
    typography,
    materialUltraThin,
    materialThin,
    materialMedium,
    materialThick,
    materialUltraThick,
    toggleTheme,
  ];

  /// Returns true when [brightness] is dark.
  bool get isDark => brightness == Brightness.dark;

  /// Returns a copy with selected values replaced.
  CNThemeData copyWith({
    Brightness? brightness,
    Color? primaryColor,
    Color? secondaryColor,
    Color? destructiveColor,
    Color? canvasColor,
    Color? groupedBackgroundColor,
    Color? labelColor,
    Color? secondaryLabelColor,
    Color? separatorColor,
    Color? fillPrimaryColor,
    Color? fillSecondaryColor,
    Color? fillTertiaryColor,
    CNTypography? typography,
    CNGlassMaterial? materialUltraThin,
    CNGlassMaterial? materialThin,
    CNGlassMaterial? materialMedium,
    CNGlassMaterial? materialThick,
    CNGlassMaterial? materialUltraThick,
    CNToggleThemeData? toggleTheme,
  }) {
    return CNThemeData.raw(
      brightness: brightness ?? this.brightness,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      canvasColor: canvasColor ?? this.canvasColor,
      groupedBackgroundColor: groupedBackgroundColor ?? this.groupedBackgroundColor,
      labelColor: labelColor ?? this.labelColor,
      secondaryLabelColor: secondaryLabelColor ?? this.secondaryLabelColor,
      separatorColor: separatorColor ?? this.separatorColor,
      fillPrimaryColor: fillPrimaryColor ?? this.fillPrimaryColor,
      fillSecondaryColor: fillSecondaryColor ?? this.fillSecondaryColor,
      fillTertiaryColor: fillTertiaryColor ?? this.fillTertiaryColor,
      typography: this.typography.merge(typography),
      materialUltraThin: materialUltraThin ?? this.materialUltraThin,
      materialThin: materialThin ?? this.materialThin,
      materialMedium: materialMedium ?? this.materialMedium,
      materialThick: materialThick ?? this.materialThick,
      materialUltraThick: materialUltraThick ?? this.materialUltraThick,
      toggleTheme: this.toggleTheme.merge(toggleTheme),
    );
  }

  /// Returns a new theme where non-null fields from [other] override this theme.
  CNThemeData merge(CNThemeData? other) {
    if (other == null) return this;
    return copyWith(
      brightness: other.brightness,
      primaryColor: other.primaryColor,
      secondaryColor: other.secondaryColor,
      destructiveColor: other.destructiveColor,
      canvasColor: other.canvasColor,
      groupedBackgroundColor: other.groupedBackgroundColor,
      labelColor: other.labelColor,
      secondaryLabelColor: other.secondaryLabelColor,
      separatorColor: other.separatorColor,
      fillPrimaryColor: other.fillPrimaryColor,
      fillSecondaryColor: other.fillSecondaryColor,
      fillTertiaryColor: other.fillTertiaryColor,
      typography: other.typography,
      materialUltraThin: other.materialUltraThin,
      materialThin: other.materialThin,
      materialMedium: other.materialMedium,
      materialThick: other.materialThick,
      materialUltraThick: other.materialUltraThick,
      toggleTheme: other.toggleTheme,
    );
  }

  /// Linearly interpolates between two theme objects.
  static CNThemeData lerp(CNThemeData a, CNThemeData b, double t) {
    return CNThemeData.raw(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      primaryColor: Color.lerp(a.primaryColor, b.primaryColor, t)!,
      secondaryColor: Color.lerp(a.secondaryColor, b.secondaryColor, t)!,
      destructiveColor: Color.lerp(a.destructiveColor, b.destructiveColor, t)!,
      canvasColor: Color.lerp(a.canvasColor, b.canvasColor, t)!,
      groupedBackgroundColor: Color.lerp(a.groupedBackgroundColor, b.groupedBackgroundColor, t)!,
      labelColor: Color.lerp(a.labelColor, b.labelColor, t)!,
      secondaryLabelColor: Color.lerp(a.secondaryLabelColor, b.secondaryLabelColor, t)!,
      separatorColor: Color.lerp(a.separatorColor, b.separatorColor, t)!,
      fillPrimaryColor: Color.lerp(a.fillPrimaryColor, b.fillPrimaryColor, t)!,
      fillSecondaryColor: Color.lerp(a.fillSecondaryColor, b.fillSecondaryColor, t)!,
      fillTertiaryColor: Color.lerp(a.fillTertiaryColor, b.fillTertiaryColor, t)!,
      typography: CNTypography.lerp(a.typography, b.typography, t),
      materialUltraThin: t < 0.5 ? a.materialUltraThin : b.materialUltraThin,
      materialThin: t < 0.5 ? a.materialThin : b.materialThin,
      materialMedium: t < 0.5 ? a.materialMedium : b.materialMedium,
      materialThick: t < 0.5 ? a.materialThick : b.materialThick,
      materialUltraThick: t < 0.5 ? a.materialUltraThick : b.materialUltraThick,
      toggleTheme: CNToggleThemeData.lerp(a.toggleTheme, b.toggleTheme, t),
    );
  }
}

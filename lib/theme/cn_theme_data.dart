import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../style/font.dart';
import '../style/cn_typography.dart';
import '../style/macos26_colors.dart';
import '../style/macos26_materials.dart';
import '../style/sf_symbol.dart';
import '../style/text_utils.dart';

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

/// Widget-specific visual overrides for [CNImage].
class CNImageThemeData extends Equatable {
  /// Creates image theme overrides.
  const CNImageThemeData({
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.tint,
    this.font,
  });

  /// Default symbol font.
  final CNFont? font;

  /// Default per-symbol foreground colors.
  final List<Color>? foregroundStyleColors;

  /// Default color rendering mode.
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;

  /// Default rendering mode.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// Default tint color.
  final Color? tint;

  @override
  List<Object?> get props => [symbolRenderingMode, symbolColorRenderingMode, foregroundStyleColors, tint, font];

  /// Returns a copy with selected values replaced.
  CNImageThemeData copyWith({
    CNSymbolRenderingMode? symbolRenderingMode,
    CNSymbolColorRenderingMode? symbolColorRenderingMode,
    List<Color>? foregroundStyleColors,
    Color? tint,
    CNFont? font,
  }) {
    return CNImageThemeData(
      symbolRenderingMode: symbolRenderingMode ?? this.symbolRenderingMode,
      symbolColorRenderingMode: symbolColorRenderingMode ?? this.symbolColorRenderingMode,
      foregroundStyleColors: foregroundStyleColors ?? this.foregroundStyleColors,
      tint: tint ?? this.tint,
      font: font ?? this.font,
    );
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNImageThemeData merge(CNImageThemeData? other) {
    if (other == null) return this;
    return copyWith(
      symbolRenderingMode: other.symbolRenderingMode,
      symbolColorRenderingMode: other.symbolColorRenderingMode,
      foregroundStyleColors: other.foregroundStyleColors,
      tint: other.tint,
      font: other.font,
    );
  }

  /// Linearly interpolates between two image themes.
  static CNImageThemeData lerp(CNImageThemeData a, CNImageThemeData b, double t) {
    return CNImageThemeData(
      symbolRenderingMode: t < 0.5 ? a.symbolRenderingMode : b.symbolRenderingMode,
      symbolColorRenderingMode: t < 0.5 ? a.symbolColorRenderingMode : b.symbolColorRenderingMode,
      foregroundStyleColors: t < 0.5 ? a.foregroundStyleColors : b.foregroundStyleColors,
      tint: Color.lerp(a.tint, b.tint, t),
      font: t < 0.5 ? a.font : b.font,
    );
  }
}

/// Widget-specific visual overrides for [CNText].
class CNTextThemeData extends Equatable {
  /// Creates text theme overrides.
  const CNTextThemeData({this.font, this.labelColor});

  /// Default text font.
  final CNFont? font;

  /// Default text foreground color.
  final Color? labelColor;

  @override
  List<Object?> get props => [font, labelColor];

  /// Returns a copy with selected values replaced.
  CNTextThemeData copyWith({CNFont? font, Color? labelColor}) {
    return CNTextThemeData(font: font ?? this.font, labelColor: labelColor ?? this.labelColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNTextThemeData merge(CNTextThemeData? other) {
    if (other == null) return this;
    return copyWith(font: other.font, labelColor: other.labelColor);
  }

  /// Linearly interpolates between two text themes.
  static CNTextThemeData lerp(CNTextThemeData a, CNTextThemeData b, double t) {
    return CNTextThemeData(font: t < 0.5 ? a.font : b.font, labelColor: Color.lerp(a.labelColor, b.labelColor, t));
  }
}

/// Widget-specific visual overrides for [CNSlider].
class CNSliderThemeData extends Equatable {
  /// Creates slider theme overrides.
  const CNSliderThemeData({this.tintColor});

  /// Default tint color for slider track and thumb.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNSliderThemeData copyWith({Color? tintColor}) {
    return CNSliderThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNSliderThemeData merge(CNSliderThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two slider themes.
  static CNSliderThemeData lerp(CNSliderThemeData a, CNSliderThemeData b, double t) {
    return CNSliderThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
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
    CNImageThemeData? imageTheme,
    CNTextThemeData? textTheme,
    CNSliderThemeData? sliderTheme,
  }) {
    final isDark = brightness == Brightness.dark;

    final resolvedLabelColor = labelColor ?? (isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color);
    final resolvedPrimaryColor = primaryColor ?? (isDark ? MacOS26Colors.blue.darkColor : MacOS26Colors.blue.color);
    final resolvedTypography =
        typography ?? (isDark ? CNTypography.lightOpaque() : CNTypography.darkOpaque()).copyWith(color: resolvedLabelColor);
    final resolvedTextTheme = (textTheme ?? const CNTextThemeData()).copyWith(
      font: textTheme?.font ?? cnFontFromTextStyle(resolvedTypography.body),
      labelColor: textTheme?.labelColor ?? resolvedLabelColor,
    );
    final resolvedToggleTheme = (toggleTheme ?? const CNToggleThemeData()).copyWith(
      tint: toggleTheme?.tint ?? resolvedPrimaryColor,
    );
    final resolvedSliderTheme = (sliderTheme ?? const CNSliderThemeData()).copyWith(
      tintColor: sliderTheme?.tintColor ?? resolvedPrimaryColor,
    );

    return CNThemeData.raw(
      brightness: brightness,
      primaryColor: resolvedPrimaryColor,
      secondaryColor: secondaryColor ?? (isDark ? MacOS26Colors.indigo.darkColor : MacOS26Colors.indigo.color),
      destructiveColor: destructiveColor ?? (isDark ? MacOS26Colors.red.darkColor : MacOS26Colors.red.color),
      canvasColor:
          canvasColor ??
          (isDark ? CupertinoColors.secondarySystemBackground.darkColor : CupertinoColors.secondarySystemBackground.color),
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
      typography: resolvedTypography,
      materialUltraThin: materialUltraThin ?? CNGlassMaterial.ultraThin,
      materialThin: materialThin ?? CNGlassMaterial.thin,
      materialMedium: materialMedium ?? CNGlassMaterial.medium,
      materialThick: materialThick ?? CNGlassMaterial.thick,
      materialUltraThick: materialUltraThick ?? CNGlassMaterial.ultraThick,
      toggleTheme: resolvedToggleTheme,
      imageTheme: imageTheme ?? const CNImageThemeData(),
      textTheme: resolvedTextTheme,
      sliderTheme: resolvedSliderTheme,
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
    required this.imageTheme,
    required this.textTheme,
    required this.sliderTheme,
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

  /// Widget-specific image theme overrides.
  final CNImageThemeData imageTheme;

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

  /// Widget-specific slider theme overrides.
  final CNSliderThemeData sliderTheme;

  /// Widget-specific text theme overrides.
  final CNTextThemeData textTheme;

  /// Widget-specific toggle theme overrides.
  final CNToggleThemeData toggleTheme;

  /// HIG-aligned text styles.
  final CNTypography typography;

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
    imageTheme,
    textTheme,
    sliderTheme,
  ];

  /// Alias of [primaryColor] for accent-driven controls.
  Color get accentColor => primaryColor;

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
    CNImageThemeData? imageTheme,
    CNTextThemeData? textTheme,
    CNSliderThemeData? sliderTheme,
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
      imageTheme: this.imageTheme.merge(imageTheme),
      textTheme: this.textTheme.merge(textTheme),
      sliderTheme: this.sliderTheme.merge(sliderTheme),
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
      imageTheme: other.imageTheme,
      textTheme: other.textTheme,
      sliderTheme: other.sliderTheme,
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
      imageTheme: CNImageThemeData.lerp(a.imageTheme, b.imageTheme, t),
      textTheme: CNTextThemeData.lerp(a.textTheme, b.textTheme, t),
      sliderTheme: CNSliderThemeData.lerp(a.sliderTheme, b.sliderTheme, t),
    );
  }
}

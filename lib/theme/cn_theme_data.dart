import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/theme/cn_button_theme_data.dart';
import 'package:cupertino_native/theme/cn_image_theme_data.dart';
import 'package:cupertino_native/theme/cn_progress_theme_data.dart';
import 'package:cupertino_native/theme/cn_scrollbar_theme.dart';
import 'package:cupertino_native/theme/cn_slider_theme_data.dart';
import 'package:cupertino_native/theme/cn_text_theme_data.dart';
import 'package:cupertino_native/theme/cn_toggle_theme_data.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../style/text_utils.dart';

/// Defines the semantic color tokens used by [CNTheme].
class CNThemeData extends Equatable {
  /// Creates a theme configuration with semantic defaults for the given brightness.
  factory CNThemeData({
    Brightness brightness = Brightness.light,
    Color? accentColor,
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
    Color? fillQuaternaryColor,
    Color? fillQuinaryColor,
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
    CNProgressThemeData? progressTheme,
    CNScrollbarThemeData? scrollbarTheme,
    CNButtonThemeData? buttonTheme,
    required bool isMainWindow,
  }) {
    final isDark = brightness == Brightness.dark;
    final Color labelColor;
    final Color thumbColor;

    if (isDark) {
      labelColor = CupertinoColors.label.darkColor;
      accentColor ??= CNColors.blue.darkColor;
      secondaryColor ??= CNColors.indigo.darkColor;
      destructiveColor ??= CNColors.red.darkColor;
      canvasColor ??= CNColors.canvasColor.darkColor;
      groupedBackgroundColor ??= CNColors.groupedBackgroundColor.darkColor;
      secondaryLabelColor ??= CNColors.secondaryLabel.darkColor;
      separatorColor ??= CNColors.separator.darkColor;
      fillPrimaryColor ??= CNColors.fillPrimary.darkColor;
      fillSecondaryColor ??= CNColors.fillSecondary.darkColor;
      fillTertiaryColor ??= CNColors.fillTertiary.darkColor;
      fillQuaternaryColor ??= CNColors.fillQuaternary.darkColor;
      fillQuinaryColor ??= CNColors.fillQuinary.darkColor;
      thumbColor = CNColors.scrollbarColor.darkColor.withAlpha(101);
      typography ??= CNTypography.lightOpaque().copyWith(color: labelColor);
    } else {
      labelColor = CupertinoColors.label.color;
      accentColor ??= CNColors.blue.color;
      secondaryColor ??= CNColors.indigo.color;
      destructiveColor ??= CNColors.red.color;
      canvasColor ??= CNColors.canvasColor.color;
      groupedBackgroundColor ??= CNColors.groupedBackgroundColor.color;
      secondaryLabelColor ??= CNColors.secondaryLabel.color;
      separatorColor ??= CNColors.separator.color;
      fillPrimaryColor ??= CNColors.fillPrimary.color;
      fillSecondaryColor ??= CNColors.fillSecondary.color;
      fillTertiaryColor ??= CNColors.fillTertiary.color;
      fillQuaternaryColor ??= CNColors.fillQuaternary.color;
      fillQuinaryColor ??= CNColors.fillQuinary.color;
      thumbColor = CNColors.scrollbarColor.color.withAlpha(101);
      typography ??= CNTypography.darkOpaque().copyWith(color: labelColor);
    }
    textTheme ??= CNTextThemeData(font: cnFontFromTextStyle(typography.body), labelColor: labelColor);
    buttonTheme ??= CNButtonThemeData(tintColor: accentColor);
    toggleTheme ??= CNToggleThemeData(tint: accentColor);
    sliderTheme ??= CNSliderThemeData(tintColor: accentColor);
    progressTheme ??= CNProgressThemeData(tintColor: accentColor);
    scrollbarTheme ??= CNScrollbarThemeData(thumbColor: thumbColor, thumbColorWhileHovering: thumbColor.withAlpha(255));
    imageTheme ??= const CNImageThemeData();

    return CNThemeData.raw(
      brightness: brightness,
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      destructiveColor: destructiveColor,
      canvasColor: canvasColor,
      groupedBackgroundColor: groupedBackgroundColor,
      labelColor: labelColor,
      secondaryLabelColor: secondaryLabelColor,
      separatorColor: separatorColor,
      fillPrimaryColor: fillPrimaryColor,
      fillSecondaryColor: fillSecondaryColor,
      fillTertiaryColor: fillTertiaryColor,
      fillQuaternaryColor: fillQuaternaryColor,
      fillQuinaryColor: fillQuinaryColor,
      typography: typography,
      materialUltraThin: materialUltraThin ?? CNGlassMaterial.ultraThin,
      materialThin: materialThin ?? CNGlassMaterial.thin,
      materialMedium: materialMedium ?? CNGlassMaterial.medium,
      materialThick: materialThick ?? CNGlassMaterial.thick,
      materialUltraThick: materialUltraThick ?? CNGlassMaterial.ultraThick,
      toggleTheme: toggleTheme,
      imageTheme: imageTheme,
      textTheme: textTheme,
      sliderTheme: sliderTheme,
      progressTheme: progressTheme,
      scrollbarTheme: scrollbarTheme,
      buttonTheme: buttonTheme,
      isMainWindow: isMainWindow,
    );
  }

  /// A default dark theme.
  factory CNThemeData.dark({required Color? accentColor, required bool isMainWindow}) =>
      CNThemeData(brightness: Brightness.dark, accentColor: accentColor, isMainWindow: isMainWindow);

  /// The default fallback theme used when no [CNTheme] is in scope.
  factory CNThemeData.fallback({Brightness brightness = Brightness.light, required bool isMainWindow}) =>
      CNThemeData(brightness: brightness, isMainWindow: isMainWindow);

  /// A default light theme.
  factory CNThemeData.light({required Color? accentColor, required bool isMainWindow}) =>
      CNThemeData(brightness: Brightness.light, accentColor: accentColor, isMainWindow: isMainWindow);

  /// Creates a theme from exact values.
  const CNThemeData.raw({
    required this.brightness,
    required this.accentColor,
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
    required this.progressTheme,
    required this.scrollbarTheme,
    required this.buttonTheme,
    required this.isMainWindow,
    required this.fillQuaternaryColor,
    required this.fillQuinaryColor,
  });

  /// Primary interactive color.
  final Color accentColor;

  /// Overall brightness for descendant widgets.
  final Brightness brightness;

  /// Widget-specific button theme overrides.
  final CNButtonThemeData buttonTheme;

  /// Default surface background color.
  final Color canvasColor;

  /// Destructive action color.
  final Color destructiveColor;

  /// Primary translucent fill color.
  final Color fillPrimaryColor;

  /// Quaternary fill color.
  final Color fillQuaternaryColor;

  /// Quinary fill color.
  final Color fillQuinaryColor;

  /// Secondary translucent fill color.
  final Color fillSecondaryColor;

  /// Tertiary translucent fill color.
  final Color fillTertiaryColor;

  /// Grouped surface background color.
  final Color groupedBackgroundColor;

  /// Widget-specific image theme overrides.
  final CNImageThemeData imageTheme;

  /// Whether this theme is for the main window.
  final bool isMainWindow;

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

  /// Widget-specific progress view theme overrides.
  final CNProgressThemeData progressTheme;

  /// Widget-specific scrollbar theme overrides.
  final CNScrollbarThemeData scrollbarTheme;

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
    accentColor,
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
    fillQuaternaryColor,
    fillQuinaryColor,
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
    progressTheme,
    buttonTheme,
    isMainWindow,
    isDark,
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
    Color? fillQuaternaryColor,
    Color? fillQuinaryColor,
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
    CNProgressThemeData? progressTheme,
    CNScrollbarThemeData? scrollbarTheme,
    CNButtonThemeData? buttonTheme,
    bool? isMainWindow,
  }) {
    return CNThemeData.raw(
      brightness: brightness ?? this.brightness,
      accentColor: primaryColor ?? accentColor,
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
      fillQuaternaryColor: fillQuaternaryColor ?? this.fillQuaternaryColor,
      fillQuinaryColor: fillQuinaryColor ?? this.fillQuinaryColor,
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
      progressTheme: this.progressTheme.merge(progressTheme),
      scrollbarTheme: this.scrollbarTheme.merge(scrollbarTheme),
      buttonTheme: this.buttonTheme.merge(buttonTheme),
      isMainWindow: isMainWindow ?? this.isMainWindow,
    );
  }

  /// Returns a new theme where non-null fields from [other] override this theme.
  CNThemeData merge(CNThemeData? other) {
    if (other == null) return this;
    return copyWith(
      brightness: other.brightness,
      primaryColor: other.accentColor,
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
      progressTheme: other.progressTheme,
      scrollbarTheme: other.scrollbarTheme,
      buttonTheme: other.buttonTheme,
      isMainWindow: other.isMainWindow,
    );
  }

  /// Linearly interpolates between two theme objects.
  static CNThemeData lerp(CNThemeData a, CNThemeData b, double t) {
    return CNThemeData.raw(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      accentColor: Color.lerp(a.accentColor, b.accentColor, t)!,
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
      fillQuaternaryColor: Color.lerp(a.fillQuaternaryColor, b.fillQuaternaryColor, t)!,
      fillQuinaryColor: Color.lerp(a.fillQuinaryColor, b.fillQuinaryColor, t)!,
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
      progressTheme: CNProgressThemeData.lerp(a.progressTheme, b.progressTheme, t),
      scrollbarTheme: CNScrollbarThemeData.lerp(a.scrollbarTheme, b.scrollbarTheme, t),
      buttonTheme: CNButtonThemeData.lerp(a.buttonTheme, b.buttonTheme, t),
      isMainWindow: t < 0.5 ? a.isMainWindow : b.isMainWindow,
    );
  }
}


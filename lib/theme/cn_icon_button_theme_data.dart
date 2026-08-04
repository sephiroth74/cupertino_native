import 'dart:ui' show lerpDouble;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// The overall shape of a [CNIconButton]'s background / hit target.
enum CNIconButtonShape {
  /// A rounded rectangle. The corner radius comes from
  /// [CNIconButtonThemeData.borderRadius] (falling back to `size / 8`).
  roundedRectangle,

  /// A perfect circle.
  circle,

  /// A capsule / pill (fully rounded on the short axis).
  capsule,
}

/// Applies [CNIconButtonThemeData] to descendant [CNIconButton] widgets.
class CNIconButtonTheme extends InheritedTheme {
  /// Creates an icon button theme scope.
  const CNIconButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The icon button theme override for descendants.
  final CNIconButtonThemeData data;

  @override
  bool updateShouldNotify(CNIconButtonTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNIconButtonTheme(data: data, child: child);

  /// Returns the nearest [CNIconButtonThemeData], falling back to [CNTheme].
  static CNIconButtonThemeData of(BuildContext context) {
    final CNIconButtonTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNIconButtonTheme>();
    return theme?.data ?? CNTheme.of(context).iconButtonTheme;
  }
}

/// Widget-specific visual overrides for [CNIconButton].
///
/// Every field is nullable: when a value is null the [CNIconButton] resolves a
/// sensible default from the ambient [CNTheme] (accent color, fills, label
/// color, …). This lets an app theme just a subset of the appearance while
/// keeping the rest in sync with the platform look.
class CNIconButtonThemeData extends Equatable {
  /// Creates icon button theme overrides.
  const CNIconButtonThemeData({
    this.foregroundColor,
    this.hoveredForegroundColor,
    this.selectedForegroundColor,
    this.pressedForegroundColor,
    this.disabledForegroundColor,
    this.backgroundColor,
    this.hoveredBackgroundColor,
    this.selectedBackgroundColor,
    this.pressedBackgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.borderRadius,
    this.iconSizeRatio,
    this.padding,
    this.animationDuration,
  });

  /// Animation duration for hover / press / selection transitions.
  final Duration? animationDuration;

  /// Background fill in the default (idle) state.
  final Color? backgroundColor;

  /// Border (stroke) color drawn around the button in every state.
  final Color? borderColor;

  /// Corner radius used when [shape] is [CNIconButtonShape.roundedRectangle].
  final double? borderRadius;

  /// Border (stroke) width. Defaults to `0` (no border) when null.
  final double? borderWidth;

  /// Background fill while the button is disabled.
  final Color? disabledBackgroundColor;

  /// Icon color while the button is disabled.
  final Color? disabledForegroundColor;

  /// Icon color in the default (idle) state.
  final Color? foregroundColor;

  /// Background fill while the pointer is hovering.
  final Color? hoveredBackgroundColor;

  /// Icon color while the pointer is hovering.
  final Color? hoveredForegroundColor;

  /// Icon size expressed as a fraction of the button [CNIconButton.size].
  /// Defaults to `0.5` when null.
  final double? iconSizeRatio;

  /// Extra padding applied inside the button around the icon.
  final EdgeInsetsGeometry? padding;

  /// Background fill while the button is pressed.
  final Color? pressedBackgroundColor;

  /// Icon color while the button is pressed.
  final Color? pressedForegroundColor;

  /// Background fill while the button is selected.
  final Color? selectedBackgroundColor;

  /// Icon color while the button is selected.
  final Color? selectedForegroundColor;

  /// The overall background / hit-target shape.
  final CNIconButtonShape? shape;

  @override
  List<Object?> get props => [
    foregroundColor,
    hoveredForegroundColor,
    selectedForegroundColor,
    pressedForegroundColor,
    disabledForegroundColor,
    backgroundColor,
    hoveredBackgroundColor,
    selectedBackgroundColor,
    pressedBackgroundColor,
    disabledBackgroundColor,
    borderColor,
    borderWidth,
    shape,
    borderRadius,
    iconSizeRatio,
    padding,
    animationDuration,
  ];

  /// The toolbar-specific overrides applied to a [CNIconButton] rendered inside
  /// a [CNToolbar] via `CNToolbarButton`.
  ///
  /// Toolbar buttons are borderless with a transparent idle background, a subtle
  /// hover/pressed fill and a smaller icon than the standalone default — matching
  /// AppKit's accessory-bar (toolbar) buttons. Only structural fields and the
  /// subtle state fills are set here; the idle foreground color is left null so
  /// it tracks the ambient [CNTheme] label color.
  ///
  /// This is layered *under* any ambient [CNIconButtonTheme] and an optional
  /// per-item override, so an app can still restyle toolbar buttons app-wide or
  /// individually.
  static CNIconButtonThemeData toolbarDefaults(CNThemeData theme) {
    final Color? accent = theme.accentColor;
    return CNIconButtonThemeData(
      shape: CNIconButtonShape.roundedRectangle,
      iconSizeRatio: 0.5,
      padding: EdgeInsets.zero,
      hoveredBackgroundColor: theme.fillQuaternaryColor,
      pressedBackgroundColor: theme.fillTertiaryColor,
      selectedBackgroundColor:
          accent?.withValues(alpha: 0.15) ?? theme.fillSecondaryColor,
      selectedForegroundColor: accent,
      animationDuration: const Duration(milliseconds: 120),
    );
  }

  /// Returns a copy with selected values replaced.
  CNIconButtonThemeData copyWith({
    Color? foregroundColor,
    Color? hoveredForegroundColor,
    Color? selectedForegroundColor,
    Color? pressedForegroundColor,
    Color? disabledForegroundColor,
    Color? backgroundColor,
    Color? hoveredBackgroundColor,
    Color? selectedBackgroundColor,
    Color? pressedBackgroundColor,
    Color? disabledBackgroundColor,
    Color? borderColor,
    double? borderWidth,
    CNIconButtonShape? shape,
    double? borderRadius,
    double? iconSizeRatio,
    EdgeInsetsGeometry? padding,
    Duration? animationDuration,
  }) {
    return CNIconButtonThemeData(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      hoveredForegroundColor:
          hoveredForegroundColor ?? this.hoveredForegroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      pressedForegroundColor:
          pressedForegroundColor ?? this.pressedForegroundColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hoveredBackgroundColor:
          hoveredBackgroundColor ?? this.hoveredBackgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? this.pressedBackgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSizeRatio: iconSizeRatio ?? this.iconSizeRatio,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNIconButtonThemeData merge(CNIconButtonThemeData? other) {
    if (other == null) return this;
    return copyWith(
      foregroundColor: other.foregroundColor,
      hoveredForegroundColor: other.hoveredForegroundColor,
      selectedForegroundColor: other.selectedForegroundColor,
      pressedForegroundColor: other.pressedForegroundColor,
      disabledForegroundColor: other.disabledForegroundColor,
      backgroundColor: other.backgroundColor,
      hoveredBackgroundColor: other.hoveredBackgroundColor,
      selectedBackgroundColor: other.selectedBackgroundColor,
      pressedBackgroundColor: other.pressedBackgroundColor,
      disabledBackgroundColor: other.disabledBackgroundColor,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      shape: other.shape,
      borderRadius: other.borderRadius,
      iconSizeRatio: other.iconSizeRatio,
      padding: other.padding,
      animationDuration: other.animationDuration,
    );
  }

  /// Linearly interpolates between two icon button themes.
  static CNIconButtonThemeData lerp(
    CNIconButtonThemeData a,
    CNIconButtonThemeData b,
    double t,
  ) {
    return CNIconButtonThemeData(
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      hoveredForegroundColor: Color.lerp(
        a.hoveredForegroundColor,
        b.hoveredForegroundColor,
        t,
      ),
      selectedForegroundColor: Color.lerp(
        a.selectedForegroundColor,
        b.selectedForegroundColor,
        t,
      ),
      pressedForegroundColor: Color.lerp(
        a.pressedForegroundColor,
        b.pressedForegroundColor,
        t,
      ),
      disabledForegroundColor: Color.lerp(
        a.disabledForegroundColor,
        b.disabledForegroundColor,
        t,
      ),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      hoveredBackgroundColor: Color.lerp(
        a.hoveredBackgroundColor,
        b.hoveredBackgroundColor,
        t,
      ),
      selectedBackgroundColor: Color.lerp(
        a.selectedBackgroundColor,
        b.selectedBackgroundColor,
        t,
      ),
      pressedBackgroundColor: Color.lerp(
        a.pressedBackgroundColor,
        b.pressedBackgroundColor,
        t,
      ),
      disabledBackgroundColor: Color.lerp(
        a.disabledBackgroundColor,
        b.disabledBackgroundColor,
        t,
      ),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t),
      shape: t < 0.5 ? a.shape : b.shape,
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t),
      iconSizeRatio: lerpDouble(a.iconSizeRatio, b.iconSizeRatio, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
    );
  }
}

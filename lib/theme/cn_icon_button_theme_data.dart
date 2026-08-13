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
///
/// [foregroundColor] and [backgroundColor] are [WidgetStateProperty] objects
/// keyed on [WidgetState.disabled], [WidgetState.pressed],
/// [WidgetState.hovered] and [WidgetState.selected]. Because they resolve to a
/// nullable [Color], a property may cover a single state and leave the rest to
/// the layer below it — see [CNStateColor] and [CNIconButton.foregroundColor].
class CNIconButtonThemeData extends Equatable {
  /// Creates icon button theme overrides.
  const CNIconButtonThemeData({
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.borderRadius,
    this.iconSizeRatio,
    this.padding,
    this.animationDuration,
    this.font,
  });

  /// Animation duration for hover / press / selection transitions.
  final Duration? animationDuration;

  /// Per-state background fill. See [CNIconButton.backgroundColor].
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Border (stroke) color drawn around the button in every state.
  final Color? borderColor;

  /// Corner radius used when [shape] is [CNIconButtonShape.roundedRectangle].
  final double? borderRadius;

  /// Border (stroke) width. Defaults to `0` (no border) when null.
  final double? borderWidth;

  /// Font used to draw the glyph. When it carries an explicit point size that
  /// size wins over [iconSizeRatio]; see [CNIconButton.font].
  final CNFont? font;

  /// Per-state icon color. See [CNIconButton.foregroundColor].
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Icon size expressed as a fraction of the button [CNIconButton.size].
  /// Defaults to `0.5` when null.
  final double? iconSizeRatio;

  /// Extra padding applied inside the button around the icon.
  final EdgeInsetsGeometry? padding;

  /// The overall background / hit-target shape.
  final CNIconButtonShape? shape;

  @override
  List<Object?> get props => [
    foregroundColor,
    backgroundColor,
    borderColor,
    borderWidth,
    shape,
    borderRadius,
    iconSizeRatio,
    padding,
    animationDuration,
    font,
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
      // Only the state fills are set: the idle background stays unresolved so a
      // toolbar button is transparent unless an app theme fills it in, and the
      // idle foreground tracks the ambient CNTheme label color.
      backgroundColor: WidgetStateProperty<Color?>.fromMap({
        WidgetState.pressed: theme.fillTertiaryColor,
        WidgetState.hovered: theme.fillQuaternaryColor,
        WidgetState.selected:
            accent?.withValues(alpha: 0.15) ?? theme.fillSecondaryColor,
      }),
      foregroundColor: WidgetStateProperty<Color?>.fromMap({
        WidgetState.selected: accent,
      }),
      animationDuration: const Duration(milliseconds: 120),
    );
  }

  /// Returns a copy with selected values replaced.
  CNIconButtonThemeData copyWith({
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    CNIconButtonShape? shape,
    double? borderRadius,
    double? iconSizeRatio,
    EdgeInsetsGeometry? padding,
    Duration? animationDuration,
    CNFont? font,
  }) {
    return CNIconButtonThemeData(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shape: shape ?? this.shape,
      borderRadius: borderRadius ?? this.borderRadius,
      iconSizeRatio: iconSizeRatio ?? this.iconSizeRatio,
      padding: padding ?? this.padding,
      animationDuration: animationDuration ?? this.animationDuration,
      font: font ?? this.font,
    );
  }

  /// Returns a new object where non-null values from [other] override this one.
  ///
  /// The color properties are layered rather than replaced: [other] wins for
  /// every state it resolves and this object still applies to the others, so
  /// merging a theme that only styles the idle background on top of one that
  /// styles the hovered fill keeps both (see [CNStateColor.layer]).
  CNIconButtonThemeData merge(CNIconButtonThemeData? other) {
    if (other == null) return this;
    return copyWith(
      foregroundColor: CNStateColor.layer(
        other.foregroundColor,
        foregroundColor,
      ),
      backgroundColor: CNStateColor.layer(
        other.backgroundColor,
        backgroundColor,
      ),
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      shape: other.shape,
      borderRadius: other.borderRadius,
      iconSizeRatio: other.iconSizeRatio,
      padding: other.padding,
      animationDuration: other.animationDuration,
      font: other.font,
    );
  }

  /// Linearly interpolates between two icon button themes.
  static CNIconButtonThemeData lerp(
    CNIconButtonThemeData a,
    CNIconButtonThemeData b,
    double t,
  ) {
    return CNIconButtonThemeData(
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a.foregroundColor,
        b.foregroundColor,
        t,
        Color.lerp,
      ),
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a.backgroundColor,
        b.backgroundColor,
        t,
        Color.lerp,
      ),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderWidth: lerpDouble(a.borderWidth, b.borderWidth, t),
      shape: t < 0.5 ? a.shape : b.shape,
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t),
      iconSizeRatio: lerpDouble(a.iconSizeRatio, b.iconSizeRatio, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      animationDuration: t < 0.5 ? a.animationDuration : b.animationDuration,
      // Fonts have no meaningful interpolation: snap at the midpoint.
      font: t < 0.5 ? a.font : b.font,
    );
  }
}

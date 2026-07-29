import 'dart:ui';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Defines the theme for [CNScrollbar] widgets.
class CNScrollbarTheme extends InheritedWidget {
  /// Creates a [CNScrollbarTheme] that controls the visual properties of descendant [CNScrollbar] widgets.
  const CNScrollbarTheme({super.key, required this.data, required super.child});

  // ignore: public_member_api_docs
  final CNScrollbarThemeData data;

  @override
  bool updateShouldNotify(CNScrollbarTheme oldWidget) => data != oldWidget.data;

  // ignore: public_member_api_docs
  static CNScrollbarThemeData of(BuildContext context) {
    final CNScrollbarTheme? scrollbarTheme = context.dependOnInheritedWidgetOfExactType<CNScrollbarTheme>();
    return scrollbarTheme?.data ?? CNTheme.of(context).scrollbarTheme;
  }
}

/// Defines the visual properties of [CNScrollbar] widgets.
class CNScrollbarThemeData with Diagnosticable {
  /// Creates a [CNScrollbarThemeData] that describes the visual properties of [CNScrollbar] widgets.
  const CNScrollbarThemeData({
    this.thickness = 9.0,
    this.thicknessWhileHovering = 9.0,
    this.thumbVisibility = false,
    this.radius = const Radius.circular(25),
    this.thumbColor,
    this.thumbColorWhileHovering
  });

  /// The radius of the scrollbar thumb.
  final Radius? radius;

  /// The thickness of the scrollbar track and thumb.
  final double? thickness;

  /// The thickness of the scrollbar track and thumb while hovering.
  final double? thicknessWhileHovering;

  /// The color of the scrollbar thumb.
  final Color? thumbColor;

  /// The color of the scrollbar thumb while hovering.
  final Color? thumbColorWhileHovering;

  /// Whether the scrollbar thumb is always visible.
  final bool? thumbVisibility;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CNScrollbarThemeData &&
        other.thickness == thickness &&
        other.thicknessWhileHovering == thicknessWhileHovering &&
        other.thumbColorWhileHovering == thumbColorWhileHovering &&
        other.thumbVisibility == thumbVisibility &&
        other.radius == radius &&
        other.thumbColor == thumbColor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double?>('thickness', thickness, defaultValue: null));
    properties.add(DiagnosticsProperty<double?>('thicknessWhileHovering', thicknessWhileHovering, defaultValue: null));
    properties.add(DiagnosticsProperty<bool>('thumbVisibility', thumbVisibility, defaultValue: null));
    properties.add(DiagnosticsProperty<Radius>('radius', radius, defaultValue: null));
    properties.add(ColorProperty('thumbColorWhileHovering', thumbColorWhileHovering, defaultValue: null));
    properties.add(ColorProperty('thumbColor', thumbColor, defaultValue: null));
  }

  @override
  int get hashCode {
    return Object.hash(thickness, thicknessWhileHovering, thumbVisibility, radius, thumbColorWhileHovering, thumbColor);
  }

  /// Creates a copy of this [CNScrollbarThemeData] but with the given fields replaced with the new values.
  CNScrollbarThemeData copyWith({
    double? thickness,
    double? thicknessWhileHovering,
    bool? showTrackOnHover,
    Color? thumbColorWhileHovering,
    bool? thumbVisibility,
    Radius? radius,
    Color? thumbColor,
  }) {
    return CNScrollbarThemeData(
      thickness: thickness ?? this.thickness,
      thicknessWhileHovering: thicknessWhileHovering ?? this.thicknessWhileHovering,
      thumbVisibility: thumbVisibility ?? this.thumbVisibility,
      radius: radius ?? this.radius,
      thumbColorWhileHovering: thumbColorWhileHovering ?? this.thumbColorWhileHovering,
      thumbColor: thumbColor ?? this.thumbColor,
    );
  }

  // ignore: public_member_api_docs
  static CNScrollbarThemeData lerp(CNScrollbarThemeData? a, CNScrollbarThemeData? b, double t) {
    return CNScrollbarThemeData(
      thickness: lerpDouble(a?.thickness, b?.thickness, t),
      thicknessWhileHovering: lerpDouble(a?.thicknessWhileHovering, b?.thicknessWhileHovering, t),
      thumbVisibility: t < 0.5 ? a?.thumbVisibility : b?.thumbVisibility,
      radius: Radius.lerp(a?.radius, b?.radius, t),
      thumbColorWhileHovering: Color.lerp(a?.thumbColorWhileHovering, b?.thumbColorWhileHovering, t),
      thumbColor: Color.lerp(a?.thumbColor, b?.thumbColor, t),
    );
  }

  /// Merges this [CNScrollbarThemeData] with another.
  CNScrollbarThemeData merge(CNScrollbarThemeData? other) {
    if (other == null) return this;
    return copyWith(
      thickness: other.thickness,
      thumbVisibility: other.thumbVisibility,
      radius: other.radius,
      thumbColorWhileHovering: other.thumbColorWhileHovering,
      thumbColor: other.thumbColor,
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNToggleThemeData] to descendant [CNToggle] widgets.
class CNToggleTheme extends InheritedTheme {
  /// Creates a toggle theme scope.
  const CNToggleTheme({super.key, required this.data, required super.child});

  /// The toggle theme override for descendants.
  final CNToggleThemeData data;

  @override
  bool updateShouldNotify(CNToggleTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNToggleTheme(data: data, child: child);

  /// Returns the nearest [CNToggleThemeData], falling back to [CNTheme].
  static CNToggleThemeData of(BuildContext context) {
    final CNToggleTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNToggleTheme>();
    return theme?.data ?? CNTheme.of(context).toggleTheme;
  }
}

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
  static CNToggleThemeData lerp(
    CNToggleThemeData a,
    CNToggleThemeData b,
    double t,
  ) {
    return CNToggleThemeData(tint: Color.lerp(a.tint, b.tint, t));
  }
}

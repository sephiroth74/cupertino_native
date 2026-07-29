import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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

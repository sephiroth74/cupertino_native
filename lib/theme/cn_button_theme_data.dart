import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Widget-specific visual overrides for [CNButton].
class CNButtonThemeData extends Equatable {
  /// Creates button theme overrides.
  const CNButtonThemeData({this.tintColor});

  /// Default tint (accent) color for the button.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNButtonThemeData copyWith({Color? tintColor}) {
    return CNButtonThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNButtonThemeData merge(CNButtonThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two button themes.
  static CNButtonThemeData lerp(CNButtonThemeData a, CNButtonThemeData b, double t) {
    return CNButtonThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Widget-specific visual overrides for [CNProgressView].
class CNProgressThemeData extends Equatable {
  /// Creates progress view theme overrides.
  const CNProgressThemeData({this.tintColor});

  /// Default tint color for progress view.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNProgressThemeData copyWith({Color? tintColor}) {
    return CNProgressThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNProgressThemeData merge(CNProgressThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two progress view themes.
  static CNProgressThemeData lerp(CNProgressThemeData a, CNProgressThemeData b, double t) {
    return CNProgressThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

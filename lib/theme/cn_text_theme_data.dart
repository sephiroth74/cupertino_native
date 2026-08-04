import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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
    return CNTextThemeData(
      font: font ?? this.font,
      labelColor: labelColor ?? this.labelColor,
    );
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNTextThemeData merge(CNTextThemeData? other) {
    if (other == null) return this;
    return copyWith(font: other.font, labelColor: other.labelColor);
  }

  /// Linearly interpolates between two text themes.
  static CNTextThemeData lerp(CNTextThemeData a, CNTextThemeData b, double t) {
    return CNTextThemeData(
      font: t < 0.5 ? a.font : b.font,
      labelColor: Color.lerp(a.labelColor, b.labelColor, t),
    );
  }
}

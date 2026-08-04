import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Widget-specific visual overrides for [CNImage].
class CNImageThemeData extends Equatable {
  /// Creates image theme overrides.
  const CNImageThemeData({
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.tint,
    this.font,
  });

  /// Default symbol font.
  final CNFont? font;

  /// Default per-symbol foreground colors.
  final List<Color>? foregroundStyleColors;

  /// Default color rendering mode.
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;

  /// Default rendering mode.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// Default tint color.
  final Color? tint;

  @override
  List<Object?> get props => [
    symbolRenderingMode,
    symbolColorRenderingMode,
    foregroundStyleColors,
    tint,
    font,
  ];

  /// Returns a copy with selected values replaced.
  CNImageThemeData copyWith({
    CNSymbolRenderingMode? symbolRenderingMode,
    CNSymbolColorRenderingMode? symbolColorRenderingMode,
    List<Color>? foregroundStyleColors,
    Color? tint,
    CNFont? font,
  }) {
    return CNImageThemeData(
      symbolRenderingMode: symbolRenderingMode ?? this.symbolRenderingMode,
      symbolColorRenderingMode:
          symbolColorRenderingMode ?? this.symbolColorRenderingMode,
      foregroundStyleColors:
          foregroundStyleColors ?? this.foregroundStyleColors,
      tint: tint ?? this.tint,
      font: font ?? this.font,
    );
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNImageThemeData merge(CNImageThemeData? other) {
    if (other == null) return this;
    return copyWith(
      symbolRenderingMode: other.symbolRenderingMode,
      symbolColorRenderingMode: other.symbolColorRenderingMode,
      foregroundStyleColors: other.foregroundStyleColors,
      tint: other.tint,
      font: other.font,
    );
  }

  /// Linearly interpolates between two image themes.
  static CNImageThemeData lerp(
    CNImageThemeData a,
    CNImageThemeData b,
    double t,
  ) {
    return CNImageThemeData(
      symbolRenderingMode: t < 0.5
          ? a.symbolRenderingMode
          : b.symbolRenderingMode,
      symbolColorRenderingMode: t < 0.5
          ? a.symbolColorRenderingMode
          : b.symbolColorRenderingMode,
      foregroundStyleColors: t < 0.5
          ? a.foregroundStyleColors
          : b.foregroundStyleColors,
      tint: Color.lerp(a.tint, b.tint, t),
      font: t < 0.5 ? a.font : b.font,
    );
  }
}

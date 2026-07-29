import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNGaugeThemeData] to descendant [CNGauge] widgets.
class CNGaugeTheme extends InheritedTheme {
  /// Creates a gauge theme scope.
  const CNGaugeTheme({super.key, required this.data, required super.child});

  /// The gauge theme override for descendants.
  final CNGaugeThemeData data;

  @override
  bool updateShouldNotify(CNGaugeTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => CNGaugeTheme(data: data, child: child);

  /// Returns the nearest [CNGaugeThemeData], falling back to [CNTheme].
  static CNGaugeThemeData of(BuildContext context) {
    final CNGaugeTheme? theme = context.dependOnInheritedWidgetOfExactType<CNGaugeTheme>();
    return theme?.data ?? CNTheme.of(context).gaugeTheme;
  }
}

/// Widget-specific visual overrides for [CNGauge].
class CNGaugeThemeData extends Equatable {
  /// Creates gauge theme overrides.
  const CNGaugeThemeData({this.tintColor});

  /// Default tint (accent) color for the gauge.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNGaugeThemeData copyWith({Color? tintColor}) {
    return CNGaugeThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNGaugeThemeData merge(CNGaugeThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two gauge themes.
  static CNGaugeThemeData lerp(CNGaugeThemeData a, CNGaugeThemeData b, double t) {
    return CNGaugeThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

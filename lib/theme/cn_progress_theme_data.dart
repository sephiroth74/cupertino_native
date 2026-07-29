import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNProgressThemeData] to descendant [CNProgressView] widgets.
class CNProgressTheme extends InheritedTheme {
  /// Creates a progress view theme scope.
  const CNProgressTheme({super.key, required this.data, required super.child});

  /// The progress view theme override for descendants.
  final CNProgressThemeData data;

  /// Returns the nearest [CNProgressThemeData], falling back to [CNTheme].
  static CNProgressThemeData of(BuildContext context) {
    final CNProgressTheme? theme = context.dependOnInheritedWidgetOfExactType<CNProgressTheme>();
    return theme?.data ?? CNTheme.of(context).progressTheme;
  }

  @override
  bool updateShouldNotify(CNProgressTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => CNProgressTheme(data: data, child: child);
}

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

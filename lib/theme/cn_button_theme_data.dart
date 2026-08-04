import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNButtonThemeData] to descendant [CNButton] widgets.
class CNButtonTheme extends InheritedTheme {
  /// Creates a button theme scope.
  const CNButtonTheme({super.key, required this.data, required super.child});

  /// The button theme override for descendants.
  final CNButtonThemeData data;

  @override
  bool updateShouldNotify(CNButtonTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNButtonTheme(data: data, child: child);

  /// Returns the nearest [CNButtonThemeData], falling back to [CNTheme].
  static CNButtonThemeData of(BuildContext context) {
    final CNButtonTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNButtonTheme>();
    return theme?.data ?? CNTheme.of(context).buttonTheme;
  }
}

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
  static CNButtonThemeData lerp(
    CNButtonThemeData a,
    CNButtonThemeData b,
    double t,
  ) {
    return CNButtonThemeData(
      tintColor: Color.lerp(a.tintColor, b.tintColor, t),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNDatePickerThemeData] to descendant [CNDatePicker] widgets.
class CNDatePickerTheme extends InheritedTheme {
  /// Creates a date picker theme scope.
  const CNDatePickerTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The date picker theme override for descendants.
  final CNDatePickerThemeData data;

  @override
  bool updateShouldNotify(CNDatePickerTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNDatePickerTheme(data: data, child: child);

  /// Returns the nearest [CNDatePickerThemeData], falling back to [CNTheme].
  static CNDatePickerThemeData of(BuildContext context) {
    final CNDatePickerTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNDatePickerTheme>();
    return theme?.data ?? CNTheme.of(context).datePickerTheme;
  }
}

/// Widget-specific visual overrides for [CNDatePicker].
class CNDatePickerThemeData extends Equatable {
  /// Creates date picker theme overrides.
  const CNDatePickerThemeData({this.tintColor});

  /// Default tint (accent) color for the date picker.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNDatePickerThemeData copyWith({Color? tintColor}) {
    return CNDatePickerThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNDatePickerThemeData merge(CNDatePickerThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two date picker themes.
  static CNDatePickerThemeData lerp(
    CNDatePickerThemeData a,
    CNDatePickerThemeData b,
    double t,
  ) {
    return CNDatePickerThemeData(
      tintColor: Color.lerp(a.tintColor, b.tintColor, t),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNPickerThemeData] to descendant [CNPicker] widgets.
class CNPickerTheme extends InheritedTheme {
  /// Creates a picker theme scope.
  const CNPickerTheme({super.key, required this.data, required super.child});

  /// The picker theme override for descendants.
  final CNPickerThemeData data;

  /// Returns the nearest [CNPickerThemeData], falling back to [CNTheme].
  static CNPickerThemeData of(BuildContext context) {
    final CNPickerTheme? theme = context.dependOnInheritedWidgetOfExactType<CNPickerTheme>();
    return theme?.data ?? CNTheme.of(context).pickerTheme;
  }

  @override
  bool updateShouldNotify(CNPickerTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => CNPickerTheme(data: data, child: child);
}

/// Widget-specific visual overrides for [CNPicker].
class CNPickerThemeData extends Equatable {
  /// Creates picker theme overrides.
  const CNPickerThemeData({this.tintColor});

  /// Default tint (accent) color for the picker.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNPickerThemeData copyWith({Color? tintColor}) {
    return CNPickerThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNPickerThemeData merge(CNPickerThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two picker themes.
  static CNPickerThemeData lerp(CNPickerThemeData a, CNPickerThemeData b, double t) {
    return CNPickerThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

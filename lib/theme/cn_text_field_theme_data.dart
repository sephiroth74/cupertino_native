import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNTextFieldThemeData] to descendant [CNTextField] widgets.
class CNTextFieldTheme extends InheritedTheme {
  /// Creates a text field theme scope.
  const CNTextFieldTheme({super.key, required this.data, required super.child});

  /// The text field theme override for descendants.
  final CNTextFieldThemeData data;

  /// Returns the nearest [CNTextFieldThemeData], falling back to [CNTheme].
  static CNTextFieldThemeData of(BuildContext context) {
    final CNTextFieldTheme? theme = context.dependOnInheritedWidgetOfExactType<CNTextFieldTheme>();
    return theme?.data ?? CNTheme.of(context).textFieldTheme;
  }

  @override
  bool updateShouldNotify(CNTextFieldTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => CNTextFieldTheme(data: data, child: child);
}

/// Widget-specific visual overrides for [CNTextField].
class CNTextFieldThemeData extends Equatable {
  /// Creates text field theme overrides.
  const CNTextFieldThemeData({this.tintColor});

  /// Default tint (accent) color for the text field.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNTextFieldThemeData copyWith({Color? tintColor}) {
    return CNTextFieldThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNTextFieldThemeData merge(CNTextFieldThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two text field themes.
  static CNTextFieldThemeData lerp(CNTextFieldThemeData a, CNTextFieldThemeData b, double t) {
    return CNTextFieldThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

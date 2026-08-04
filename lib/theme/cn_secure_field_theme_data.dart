import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNSecureFieldThemeData] to descendant [CNSecureField] widgets.
class CNSecureFieldTheme extends InheritedTheme {
  /// Creates a secure field theme scope.
  const CNSecureFieldTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The secure field theme override for descendants.
  final CNSecureFieldThemeData data;

  @override
  bool updateShouldNotify(CNSecureFieldTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNSecureFieldTheme(data: data, child: child);

  /// Returns the nearest [CNSecureFieldThemeData], falling back to [CNTheme].
  static CNSecureFieldThemeData of(BuildContext context) {
    final CNSecureFieldTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNSecureFieldTheme>();
    return theme?.data ?? CNTheme.of(context).secureFieldTheme;
  }
}

/// Widget-specific visual overrides for [CNSecureField].
class CNSecureFieldThemeData extends Equatable {
  /// Creates secure field theme overrides.
  const CNSecureFieldThemeData({this.tintColor});

  /// Default tint (accent) color for the secure field.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNSecureFieldThemeData copyWith({Color? tintColor}) {
    return CNSecureFieldThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNSecureFieldThemeData merge(CNSecureFieldThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two secure field themes.
  static CNSecureFieldThemeData lerp(
    CNSecureFieldThemeData a,
    CNSecureFieldThemeData b,
    double t,
  ) {
    return CNSecureFieldThemeData(
      tintColor: Color.lerp(a.tintColor, b.tintColor, t),
    );
  }
}

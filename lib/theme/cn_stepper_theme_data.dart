import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNStepperThemeData] to descendant [CNStepper] widgets.
class CNStepperTheme extends InheritedTheme {
  /// Creates a stepper theme scope.
  const CNStepperTheme({super.key, required this.data, required super.child});

  /// The stepper theme override for descendants.
  final CNStepperThemeData data;

  @override
  bool updateShouldNotify(CNStepperTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) => CNStepperTheme(data: data, child: child);

  /// Returns the nearest [CNStepperThemeData], falling back to [CNTheme].
  static CNStepperThemeData of(BuildContext context) {
    final CNStepperTheme? theme = context.dependOnInheritedWidgetOfExactType<CNStepperTheme>();
    return theme?.data ?? CNTheme.of(context).stepperTheme;
  }
}

/// Widget-specific visual overrides for [CNStepper].
class CNStepperThemeData extends Equatable {
  /// Creates stepper theme overrides.
  const CNStepperThemeData({this.tintColor});

  /// Default tint (accent) color for the stepper.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNStepperThemeData copyWith({Color? tintColor}) {
    return CNStepperThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNStepperThemeData merge(CNStepperThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two stepper themes.
  static CNStepperThemeData lerp(CNStepperThemeData a, CNStepperThemeData b, double t) {
    return CNStepperThemeData(tintColor: Color.lerp(a.tintColor, b.tintColor, t));
  }
}

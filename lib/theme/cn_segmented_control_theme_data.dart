import 'package:cupertino_native/cupertino_native.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Applies [CNSegmentedControlThemeData] to descendant [CNSegmentedControl] widgets.
class CNSegmentedControlTheme extends InheritedTheme {
  /// Creates a segmented control theme scope.
  const CNSegmentedControlTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The segmented control theme override for descendants.
  final CNSegmentedControlThemeData data;

  @override
  bool updateShouldNotify(CNSegmentedControlTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      CNSegmentedControlTheme(data: data, child: child);

  /// Returns the nearest [CNSegmentedControlThemeData], falling back to [CNTheme].
  static CNSegmentedControlThemeData of(BuildContext context) {
    final CNSegmentedControlTheme? theme = context
        .dependOnInheritedWidgetOfExactType<CNSegmentedControlTheme>();
    return theme?.data ?? CNTheme.of(context).segmentedControlTheme;
  }
}

/// Widget-specific visual overrides for [CNSegmentedControl].
class CNSegmentedControlThemeData extends Equatable {
  /// Creates segmented control theme overrides.
  const CNSegmentedControlThemeData({this.tintColor});

  /// Default tint (accent) color for the selected segment.
  final Color? tintColor;

  @override
  List<Object?> get props => [tintColor];

  /// Returns a copy with selected values replaced.
  CNSegmentedControlThemeData copyWith({Color? tintColor}) {
    return CNSegmentedControlThemeData(tintColor: tintColor ?? this.tintColor);
  }

  /// Returns a new object where non-null values from [other] override this one.
  CNSegmentedControlThemeData merge(CNSegmentedControlThemeData? other) {
    if (other == null) return this;
    return copyWith(tintColor: other.tintColor);
  }

  /// Linearly interpolates between two segmented control themes.
  static CNSegmentedControlThemeData lerp(
    CNSegmentedControlThemeData a,
    CNSegmentedControlThemeData b,
    double t,
  ) {
    return CNSegmentedControlThemeData(
      tintColor: Color.lerp(a.tintColor, b.tintColor, t),
    );
  }
}

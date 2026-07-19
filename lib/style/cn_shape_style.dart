// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:flutter/widgets.dart';

/// A unit point representing a position in a gradient coordinate space.
class CNUnitPoint {
  const CNUnitPoint(this.x, this.y);

  static const CNUnitPoint bottom = CNUnitPoint(0.5, 1.0);
  static const CNUnitPoint bottomLeading = CNUnitPoint(0.0, 1.0);
  static const CNUnitPoint bottomTrailing = CNUnitPoint(1.0, 1.0);
  static const CNUnitPoint center = CNUnitPoint(0.5, 0.5);
  static const CNUnitPoint leading = CNUnitPoint(0.0, 0.5);
  static const CNUnitPoint top = CNUnitPoint(0.5, 0.0);
  static const CNUnitPoint topLeading = CNUnitPoint(0.0, 0.0);
  static const CNUnitPoint topTrailing = CNUnitPoint(1.0, 0.0);
  static const CNUnitPoint trailing = CNUnitPoint(1.0, 0.5);

  final double x;
  final double y;

  Map<String, dynamic> toMap() => {'x': x, 'y': y};
}

/// A color stop in a gradient.
class CNGradientStop {
  const CNGradientStop(this.color, this.location);

  final Color color;
  final double location;
}

/// Represents a SwiftUI ShapeStyle that can be used as a tint.
sealed class CNShapeStyle {
  const CNShapeStyle();

  /// Simple gradient defined by color stops (SwiftUI `Gradient`).
  /// Used with `.tint(gradient)`.
  const factory CNShapeStyle.gradient(List<CNGradientStop> stops) =
      CNShapeStyleGradient;

  /// A linear gradient with start and end points.
  const factory CNShapeStyle.linearGradient(
    List<CNGradientStop> stops, {
    required CNUnitPoint startPoint,
    required CNUnitPoint endPoint,
  }) = CNShapeStyleLinearGradient;

  /// An angular (conic) gradient.
  const factory CNShapeStyle.angularGradient(
    List<CNGradientStop> stops, {
    CNUnitPoint center,
    double startAngle,
    double endAngle,
  }) = CNShapeStyleAngularGradient;

  /// A radial gradient.
  const factory CNShapeStyle.radialGradient(
    List<CNGradientStop> stops, {
    CNUnitPoint center,
    double startRadius,
    double endRadius,
  }) = CNShapeStyleRadialGradient;

  /// An elliptical gradient.
  const factory CNShapeStyle.ellipticalGradient(
    List<CNGradientStop> stops, {
    CNUnitPoint center,
  }) = CNShapeStyleEllipticalGradient;

  Map<String, dynamic> toMap(BuildContext context);
}

class CNShapeStyleGradient extends CNShapeStyle {
  const CNShapeStyleGradient(this.stops);

  final List<CNGradientStop> stops;

  @override
  Map<String, dynamic> toMap(BuildContext context) => {
    'type': 'gradient',
    'stops': _encodeStops(stops, context),
  };
}

class CNShapeStyleLinearGradient extends CNShapeStyle {
  const CNShapeStyleLinearGradient(
    this.stops, {
    required this.startPoint,
    required this.endPoint,
  });

  final CNUnitPoint endPoint;
  final CNUnitPoint startPoint;
  final List<CNGradientStop> stops;

  @override
  Map<String, dynamic> toMap(BuildContext context) => {
    'type': 'linearGradient',
    'stops': _encodeStops(stops, context),
    'startPoint': startPoint.toMap(),
    'endPoint': endPoint.toMap(),
  };
}

class CNShapeStyleAngularGradient extends CNShapeStyle {
  const CNShapeStyleAngularGradient(
    this.stops, {
    this.center = CNUnitPoint.center,
    this.startAngle = 0.0,
    this.endAngle = 360.0,
  });

  final CNUnitPoint center;
  final double endAngle;
  final double startAngle;
  final List<CNGradientStop> stops;

  @override
  Map<String, dynamic> toMap(BuildContext context) => {
    'type': 'angularGradient',
    'stops': _encodeStops(stops, context),
    'center': center.toMap(),
    'startAngle': startAngle,
    'endAngle': endAngle,
  };
}

class CNShapeStyleRadialGradient extends CNShapeStyle {
  const CNShapeStyleRadialGradient(
    this.stops, {
    this.center = CNUnitPoint.center,
    this.startRadius = 0.0,
    this.endRadius = 100.0,
  });

  final CNUnitPoint center;
  final double endRadius;
  final double startRadius;
  final List<CNGradientStop> stops;

  @override
  Map<String, dynamic> toMap(BuildContext context) => {
    'type': 'radialGradient',
    'stops': _encodeStops(stops, context),
    'center': center.toMap(),
    'startRadius': startRadius,
    'endRadius': endRadius,
  };
}

class CNShapeStyleEllipticalGradient extends CNShapeStyle {
  const CNShapeStyleEllipticalGradient(
    this.stops, {
    this.center = CNUnitPoint.center,
  });

  final CNUnitPoint center;
  final List<CNGradientStop> stops;

  @override
  Map<String, dynamic> toMap(BuildContext context) => {
    'type': 'ellipticalGradient',
    'stops': _encodeStops(stops, context),
    'center': center.toMap(),
  };
}

List<Map<String, dynamic>> _encodeStops(
  List<CNGradientStop> stops,
  BuildContext context,
) => stops
    .map(
      (s) => {
        'color': resolveColorToArgb(s.color, context),
        'location': s.location,
      },
    )
    .toList();

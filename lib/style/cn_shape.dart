// ignore_for_file: public_member_api_docs

/// How the corners of a rounded shape are drawn.
///
/// Mirrors SwiftUI `RoundedCornerStyle`.
enum CNRoundedCornerStyle {
  /// Quarter-circle corners.
  circular,

  /// Smooth, continuous ("squircle") corners.
  continuous,
}

/// A resolvable SwiftUI `Shape`.
///
/// Serialized to a `{ 'type': ... }` map and reconstructed natively by
/// `CNShapeBuilder`. Used as the geometry of a [CNOverlay].
///
/// All shapes are `InsettableShape`s, so any of them may be [inset] before
/// painting (SwiftUI `InsettableShape.inset(by:)`).
sealed class CNShape {
  const CNShape({this.inset});

  /// Amount to inset the shape before painting, in points
  /// (SwiftUI `InsettableShape.inset(by:)`).
  ///
  /// Positive values shrink the shape inward; negative values expand it
  /// outward beyond the host's bounds — useful to draw a stroke that sits
  /// just outside the control, e.g. `inset: -1.0` around a rounded text
  /// field border.
  final double? inset;

  /// Serializes this shape to a payload map (shape geometry + shared [inset]).
  Map<String, dynamic> toMap() => {
    ...shapeMap(),
    if (inset != null) 'inset': inset,
  };

  /// Serializes the shape-specific geometry (type + parameters).
  ///
  /// Subclasses implement this instead of [toMap]; the base class merges in
  /// the shared [inset] field.
  Map<String, dynamic> shapeMap();
}

/// A rectangle aligned to the widget's bounds (SwiftUI `Rectangle`).
class CNRectangle extends CNShape {
  const CNRectangle({super.inset});

  @override
  Map<String, dynamic> shapeMap() => const {'type': 'rectangle'};
}

/// A rectangle with rounded corners (SwiftUI `RoundedRectangle`).
///
/// Provide either a uniform [cornerRadius], or independent [cornerWidth] /
/// [cornerHeight] (SwiftUI `cornerSize:`). When both are given the corner size
/// takes precedence.
class CNRoundedRectangle extends CNShape {
  const CNRoundedRectangle({
    this.cornerRadius = 8.0,
    this.cornerWidth,
    this.cornerHeight,
    this.style = CNRoundedCornerStyle.circular,
    super.inset,
  });

  final double? cornerHeight;
  final double cornerRadius;
  final double? cornerWidth;
  final CNRoundedCornerStyle style;

  @override
  Map<String, dynamic> shapeMap() => {
    'type': 'roundedRectangle',
    'cornerRadius': cornerRadius,
    if (cornerWidth != null) 'cornerWidth': cornerWidth,
    if (cornerHeight != null) 'cornerHeight': cornerHeight,
    'style': style.name,
  };
}

/// A circle inscribed in the widget's bounds (SwiftUI `Circle`).
class CNCircle extends CNShape {
  const CNCircle({super.inset});

  @override
  Map<String, dynamic> shapeMap() => const {'type': 'circle'};
}

/// An ellipse inscribed in the widget's bounds (SwiftUI `Ellipse`).
class CNEllipse extends CNShape {
  const CNEllipse({super.inset});

  @override
  Map<String, dynamic> shapeMap() => const {'type': 'ellipse'};
}

/// A capsule (fully rounded rectangle, SwiftUI `Capsule`).
class CNCapsule extends CNShape {
  const CNCapsule({this.style = CNRoundedCornerStyle.circular, super.inset});

  final CNRoundedCornerStyle style;

  @override
  Map<String, dynamic> shapeMap() => {'type': 'capsule', 'style': style.name};
}

/// A rounded rectangle with independently sized corners
/// (SwiftUI `UnevenRoundedRectangle`, macOS 13+).
///
/// On macOS 12 and earlier this renders as a plain rectangle.
class CNUnevenRoundedRectangle extends CNShape {
  const CNUnevenRoundedRectangle({
    this.topLeading = 0.0,
    this.bottomLeading = 0.0,
    this.bottomTrailing = 0.0,
    this.topTrailing = 0.0,
    this.style = CNRoundedCornerStyle.circular,
    super.inset,
  });

  final double bottomLeading;
  final double bottomTrailing;
  final CNRoundedCornerStyle style;
  final double topLeading;
  final double topTrailing;

  @override
  Map<String, dynamic> shapeMap() => {
    'type': 'unevenRoundedRectangle',
    'topLeading': topLeading,
    'bottomLeading': bottomLeading,
    'bottomTrailing': bottomTrailing,
    'topTrailing': topTrailing,
    'style': style.name,
  };
}

/// The line cap style for a stroked shape (SwiftUI/CoreGraphics `CGLineCap`).
enum CNLineCap { butt, round, square }

/// The line join style for a stroked shape (SwiftUI/CoreGraphics `CGLineJoin`).
enum CNLineJoin { miter, round, bevel }

/// Describes how a shape outline is stroked (SwiftUI `StrokeStyle`).
class CNStrokeStyle {
  const CNStrokeStyle({
    this.lineWidth = 1.0,
    this.lineCap,
    this.lineJoin,
    this.miterLimit,
    this.dash,
    this.dashPhase,
  });

  /// The dash pattern (lengths of painted/unpainted segments).
  final List<double>? dash;

  /// The offset at which to start the dash pattern.
  final double? dashPhase;

  /// How the ends of an open subpath are drawn.
  final CNLineCap? lineCap;

  /// How joints between connected segments are drawn.
  final CNLineJoin? lineJoin;

  /// The width of the stroke.
  final double lineWidth;

  /// The limit at which a miter join is converted to a bevel join.
  final double? miterLimit;

  Map<String, dynamic> toMap() => {
    'lineWidth': lineWidth,
    if (lineCap != null) 'lineCap': lineCap!.name,
    if (lineJoin != null) 'lineJoin': lineJoin!.name,
    if (miterLimit != null) 'miterLimit': miterLimit,
    if (dash != null) 'dash': dash,
    if (dashPhase != null) 'dashPhase': dashPhase,
  };
}

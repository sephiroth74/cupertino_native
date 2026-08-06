// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/cn_overlay.dart';
import 'package:cupertino_native/style/cn_shape.dart';
import 'package:cupertino_native/style/cn_shape_style.dart';
import 'package:flutter/widgets.dart';

/// A layer drawn *behind* a CN widget via SwiftUI `.background(...)`.
///
/// The counterpart of [CNOverlay] (which draws *in front*). A background is
/// either a plain fill of the whole view ([CNBackground.color]) or a painted
/// [CNShape] positioned within the bounds ([CNBackground.shape] /
/// [CNBackground.stroke] / [CNBackground.strokeBorder]). Its paint can be a
/// solid [Color] or a [CNShapeStyle] gradient — the same value types accepted
/// by `tint`.
///
/// Example — a translucent rounded fill behind a picker
/// (`.background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))`):
///
/// ```dart
/// CNPicker(
///   background: CNBackground.shape(
///     const CNRoundedRectangle(cornerRadius: 8),
///     color: CNColors.blue.withAlpha(51),
///   ),
///   selection: value,
///   children: const [...],
/// )
/// ```
class CNBackground {
  const CNBackground._({
    required this.mode,
    this.shape,
    this.alignment = CNOverlayAlignment.center,
    this.color,
    this.shapeStyle,
    this.strokeStyle,
  }) : assert(
         color == null || shapeStyle == null,
         'Provide either color or shapeStyle, not both.',
       );

  /// Fills the whole background with a solid color or gradient
  /// (SwiftUI `.background(_ style: ShapeStyle)`).
  ///
  /// [paint] must be a [Color] or a [CNShapeStyle].
  factory CNBackground.color(Object paint) {
    assert(
      paint is Color || paint is CNShapeStyle,
      'paint must be a Color or a CNShapeStyle',
    );
    return CNBackground._(
      mode: CNBackgroundPaintMode.fill,
      color: paint is Color ? paint : null,
      shapeStyle: paint is CNShapeStyle ? paint : null,
    );
  }

  /// Fills [shape] as the background (SwiftUI `Shape.fill`).
  ///
  /// Pass [color] or [shapeStyle] for the paint (defaults to the widget's tint
  /// / accent color when both are null).
  factory CNBackground.shape(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
  }) => CNBackground._(
    shape: shape,
    mode: CNBackgroundPaintMode.fill,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
  );

  /// Strokes [shape]'s outline as the background, centered on its path
  /// (SwiftUI `Shape.stroke`).
  ///
  /// Half of [lineWidth] falls outside the shape. Use
  /// [CNBackground.strokeBorder] to keep the whole stroke inside the bounds.
  factory CNBackground.stroke(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
    double lineWidth = 1.0,
    CNStrokeStyle? strokeStyle,
  }) => CNBackground._(
    shape: shape,
    mode: CNBackgroundPaintMode.stroke,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
    strokeStyle: strokeStyle ?? CNStrokeStyle(lineWidth: lineWidth),
  );

  /// Strokes [shape]'s border inset so the stroke stays inside the bounds
  /// (SwiftUI `InsettableShape.strokeBorder`).
  factory CNBackground.strokeBorder(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
    double lineWidth = 1.0,
    CNStrokeStyle? strokeStyle,
  }) => CNBackground._(
    shape: shape,
    mode: CNBackgroundPaintMode.strokeBorder,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
    strokeStyle: strokeStyle ?? CNStrokeStyle(lineWidth: lineWidth),
  );

  /// Where the background shape sits within the host bounds.
  final CNOverlayAlignment alignment;

  /// Solid paint color. Mutually exclusive with [shapeStyle].
  final Color? color;

  /// How the background is painted.
  final CNBackgroundPaintMode mode;

  /// The background geometry. When null the paint fills the whole view.
  final CNShape? shape;

  /// Gradient paint. Mutually exclusive with [color].
  final CNShapeStyle? shapeStyle;

  /// Stroke parameters (only used for stroke / strokeBorder modes).
  final CNStrokeStyle? strokeStyle;

  /// Serializes this background to a payload map for the native side.
  Map<String, dynamic> toMap(BuildContext context) {
    final map = <String, dynamic>{
      'mode': mode.name,
      'alignment': alignment.name,
    };
    if (shape != null) {
      map['shape'] = shape!.toMap();
    }
    if (shapeStyle != null) {
      map['style'] = shapeStyle!.toMap(context);
    } else if (color != null) {
      map['color'] = resolveColorToArgb(color, context);
    }
    if (strokeStyle != null) {
      map['strokeStyle'] = strokeStyle!.toMap();
    }
    return map;
  }
}

/// How a [CNBackground]'s shape is painted.
enum CNBackgroundPaintMode { stroke, strokeBorder, fill }

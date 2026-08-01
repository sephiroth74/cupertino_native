// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/cn_shape.dart';
import 'package:cupertino_native/style/cn_shape_style.dart';
import 'package:flutter/widgets.dart';

/// Where an overlay is positioned within the host view's bounds.
///
/// Mirrors the `alignment:` parameter of SwiftUI `.overlay(alignment:content:)`.
enum CNOverlayAlignment {
  center,
  leading,
  trailing,
  top,
  bottom,
  topLeading,
  topTrailing,
  bottomLeading,
  bottomTrailing,
}

/// A layer drawn on top of a CN widget via SwiftUI `.overlay(alignment:content:)`.
///
/// The overlay content is a [CNShape] painted either as an outline
/// ([CNOverlay.stroke] / [CNOverlay.strokeBorder]) or filled
/// ([CNOverlay.fill]). Its paint can be a solid [Color] or a
/// [CNShapeStyle] gradient — the same value types accepted by `tint`.
///
/// Example — the SwiftUI idiom
/// `.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))`:
///
/// ```dart
/// CNButton(
///   overlay: CNOverlay.stroke(
///     const CNRoundedRectangle(cornerRadius: 8),
///     color: CNColors.blue,
///     lineWidth: 1,
///   ),
///   children: const [CNChildText('Bordered')],
/// )
/// ```
class CNOverlay {
  const CNOverlay._({
    required this.shape,
    required this.mode,
    this.alignment = CNOverlayAlignment.center,
    this.color,
    this.shapeStyle,
    this.strokeStyle,
  }) : assert(
         color == null || shapeStyle == null,
         'Provide either color or shapeStyle, not both.',
       );

  /// Fills the [shape] (SwiftUI `Shape.fill`).
  factory CNOverlay.fill(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
  }) => CNOverlay._(
    shape: shape,
    mode: CNOverlayPaintMode.fill,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
  );

  /// Strokes the [shape]'s outline, centered on its path (SwiftUI `Shape.stroke`).
  ///
  /// Half of [lineWidth] falls outside the shape. Use [CNOverlay.strokeBorder]
  /// to keep the whole stroke inside the bounds. Pass [color] or [shapeStyle]
  /// for the paint (defaults to the widget's tint / accent color when both are
  /// null), and either [lineWidth] or a full [strokeStyle].
  factory CNOverlay.stroke(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
    double lineWidth = 1.0,
    CNStrokeStyle? strokeStyle,
  }) => CNOverlay._(
    shape: shape,
    mode: CNOverlayPaintMode.stroke,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
    strokeStyle: strokeStyle ?? CNStrokeStyle(lineWidth: lineWidth),
  );

  /// Strokes the [shape]'s border inset so the stroke stays inside the bounds
  /// (SwiftUI `InsettableShape.strokeBorder`).
  factory CNOverlay.strokeBorder(
    CNShape shape, {
    CNOverlayAlignment alignment = CNOverlayAlignment.center,
    Color? color,
    CNShapeStyle? shapeStyle,
    double lineWidth = 1.0,
    CNStrokeStyle? strokeStyle,
  }) => CNOverlay._(
    shape: shape,
    mode: CNOverlayPaintMode.strokeBorder,
    alignment: alignment,
    color: color,
    shapeStyle: shapeStyle,
    strokeStyle: strokeStyle ?? CNStrokeStyle(lineWidth: lineWidth),
  );

  /// Where the overlay sits within the host bounds.
  final CNOverlayAlignment alignment;

  /// Solid paint color. Mutually exclusive with [shapeStyle].
  final Color? color;

  /// How the shape is painted.
  final CNOverlayPaintMode mode;

  /// The overlay geometry.
  final CNShape shape;

  /// Gradient paint. Mutually exclusive with [color].
  final CNShapeStyle? shapeStyle;

  /// Stroke parameters (only used for stroke / strokeBorder modes).
  final CNStrokeStyle? strokeStyle;

  /// Serializes this overlay to a payload map for the native side.
  Map<String, dynamic> toMap(BuildContext context) {
    final map = <String, dynamic>{
      'shape': shape.toMap(),
      'mode': mode.name,
      'alignment': alignment.name,
    };
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

/// How a [CNOverlay]'s shape is painted.
enum CNOverlayPaintMode { stroke, strokeBorder, fill }

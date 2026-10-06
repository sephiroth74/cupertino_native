import SwiftUI

/// Reconstructs SwiftUI `Shape`s and their painted overlays from channel payloads.
///
/// Backs the shared `.overlay(alignment:content:)` support: a shape dictionary
/// (`{ "type": "roundedRectangle", ... }`) is turned into a concrete
/// `InsettableShape`, then stroked / stroke-bordered / filled with a paint that
/// is either a solid color, a gradient shape style, or (by default) the host's
/// tint.
enum CNShapeBuilder {
    /// Builds the painted overlay view from an overlay payload dictionary.
    ///
    /// Returns `nil` when the dictionary carries no shape.
    static func makeOverlay(_ dict: [String: Any]) -> AnyView? {
        guard let shapeDict = dict["shape"] as? [String: Any] else { return nil }
        let mode = dict["mode"] as? String ?? "stroke"
        let paint = resolvePaint(dict)
        let strokeStyle = decodeStrokeStyle(dict["strokeStyle"] as? [String: Any])
        return paintShape(shapeDict, mode: mode, paint: paint, strokeStyle: strokeStyle)
    }

    /// Builds the painted background view from a background payload dictionary.
    ///
    /// Unlike an overlay, the background may omit a shape: with no `shape` the
    /// paint fills the whole view (SwiftUI `.background(_ style:)`). With a
    /// shape it is painted (fill / stroke / strokeBorder) like an overlay.
    static func makeBackground(_ dict: [String: Any]) -> AnyView? {
        let paint = resolvePaint(dict)
        guard let shapeDict = dict["shape"] as? [String: Any] else {
            // No shape: fill the entire background with the resolved paint.
            return AnyView(Rectangle().fill(paint))
        }
        let mode = dict["mode"] as? String ?? "fill"
        let strokeStyle = decodeStrokeStyle(dict["strokeStyle"] as? [String: Any])
        return paintShape(shapeDict, mode: mode, paint: paint, strokeStyle: strokeStyle)
    }

    // MARK: - Paint resolution

    /// Resolves the fill/stroke paint: an explicit color, a gradient shape
    /// style, or the environment tint when neither is provided.
    private static func resolvePaint(_ dict: [String: Any]) -> AnyShapeStyle {
        if let colorInt = CNChannelDeserialization.decodeInt(dict["color"]) {
            return AnyShapeStyle(ColorUtils.swiftUIColorFromARGB(colorInt))
        }
        if let styleDict = dict["style"] as? [String: Any],
           let style = CNViewModifierApplicator.decodeShapeStyle(styleDict)
        {
            return style
        }
        return AnyShapeStyle(.tint)
    }

    private static func decodeStrokeStyle(_ dict: [String: Any]?) -> StrokeStyle {
        guard let dict else { return StrokeStyle(lineWidth: 1) }

        let lineWidth = CNChannelDeserialization.decodeCGFloat(dict["lineWidth"]) ?? 1
        var style = StrokeStyle(lineWidth: lineWidth)

        switch dict["lineCap"] as? String {
        case "round": style.lineCap = .round
        case "square": style.lineCap = .square
        case "butt": style.lineCap = .butt
        default: break
        }

        switch dict["lineJoin"] as? String {
        case "round": style.lineJoin = .round
        case "bevel": style.lineJoin = .bevel
        case "miter": style.lineJoin = .miter
        default: break
        }

        if let miterLimit = CNChannelDeserialization.decodeCGFloat(dict["miterLimit"]) {
            style.miterLimit = miterLimit
        }

        if let dash = decodeDoubles(dict["dash"]) {
            style.dash = dash.map { CGFloat($0) }
        }

        if let dashPhase = CNChannelDeserialization.decodeCGFloat(dict["dashPhase"]) {
            style.dashPhase = dashPhase
        }

        return style
    }

    private static func decodeDoubles(_ raw: Any?) -> [Double]? {
        if let doubles = raw as? [Double] {
            return doubles
        } else if let numbers = raw as? [NSNumber] {
            return numbers.map(\.doubleValue)
        }
        return nil
    }

    // MARK: - Shape dispatch

    /// Builds the bare (unpainted) shape described by a shape dictionary, with
    /// its `inset` applied — e.g. the shape of a glass effect.
    ///
    /// Returns `nil` for an unknown shape type.
    static func makeShape(_ shapeDict: [String: Any]) -> AnyShape? {
        guard let shape = makeInsettableShape(shapeDict) else { return nil }
        return eraseShape(shape, inset: decodeInset(shapeDict))
    }

    private static func eraseShape(_ shape: some InsettableShape, inset: CGFloat) -> AnyShape {
        AnyShape(shape.inset(by: inset))
    }

    private static func paintShape(
        _ shapeDict: [String: Any],
        mode: String,
        paint: AnyShapeStyle,
        strokeStyle: StrokeStyle,
    ) -> AnyView? {
        guard let shape = makeInsettableShape(shapeDict) else { return nil }
        return render(shape, inset: decodeInset(shapeDict), mode: mode, paint: paint, strokeStyle: strokeStyle)
    }

    private static func decodeInset(_ shapeDict: [String: Any]) -> CGFloat {
        CNChannelDeserialization.decodeCGFloat(shapeDict["inset"]) ?? 0
    }

    private static func makeInsettableShape(_ shapeDict: [String: Any]) -> (any InsettableShape)? {
        switch shapeDict["type"] as? String ?? "" {
        case "rectangle":
            return Rectangle()

        case "roundedRectangle":
            let style = cornerStyle(shapeDict["style"] as? String)
            if let width = CNChannelDeserialization.decodeCGFloat(shapeDict["cornerWidth"]),
               let height = CNChannelDeserialization.decodeCGFloat(shapeDict["cornerHeight"])
            {
                return RoundedRectangle(cornerSize: CGSize(width: width, height: height), style: style)
            }
            let radius = CNChannelDeserialization.decodeCGFloat(shapeDict["cornerRadius"]) ?? 8
            return RoundedRectangle(cornerRadius: radius, style: style)

        case "circle":
            return Circle()

        case "ellipse":
            return Ellipse()

        case "capsule":
            return Capsule(style: cornerStyle(shapeDict["style"] as? String))

        case "unevenRoundedRectangle":
            return UnevenRoundedRectangle(
                topLeadingRadius: CNChannelDeserialization.decodeCGFloat(shapeDict["topLeading"]) ?? 0,
                bottomLeadingRadius: CNChannelDeserialization.decodeCGFloat(shapeDict["bottomLeading"]) ?? 0,
                bottomTrailingRadius: CNChannelDeserialization.decodeCGFloat(shapeDict["bottomTrailing"]) ?? 0,
                topTrailingRadius: CNChannelDeserialization.decodeCGFloat(shapeDict["topTrailing"]) ?? 0,
                style: cornerStyle(shapeDict["style"] as? String),
            )

        default:
            return nil
        }
    }

    /// Paints an insettable shape according to `mode`, after applying `inset`.
    ///
    /// `inset` shifts the shape's edge inward (positive) or outward (negative)
    /// via `InsettableShape.inset(by:)`; insetting by `0` is a no-op.
    /// `strokeBorder` insets the outline so it stays inside the bounds; `stroke`
    /// centers it on the path; `fill` fills the interior.
    private static func render(
        _ shape: some InsettableShape,
        inset: CGFloat,
        mode: String,
        paint: AnyShapeStyle,
        strokeStyle: StrokeStyle,
    ) -> AnyView {
        let shape = shape.inset(by: inset)
        switch mode {
        case "fill":
            return AnyView(shape.fill(paint))
        case "strokeBorder":
            return AnyView(shape.strokeBorder(paint, style: strokeStyle))
        default:
            return AnyView(shape.stroke(paint, style: strokeStyle))
        }
    }

    private static func cornerStyle(_ value: String?) -> RoundedCornerStyle {
        value == "continuous" ? .continuous : .circular
    }
}

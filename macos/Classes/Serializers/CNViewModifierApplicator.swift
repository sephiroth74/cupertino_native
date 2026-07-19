import SwiftUI

/// Shared SwiftUI view modifier applicators for CN widgets.
/// These are the common modifiers that most widgets will need.
enum CNViewModifierApplicator {
    static func applyPaddings(_ paddings: CNPaddingsPayload?, to view: AnyView) -> AnyView {
        guard let paddings else {
            return view
        }
        return AnyView(
            view.padding(
                EdgeInsets(
                    top: paddings.top,
                    leading: paddings.leading,
                    bottom: paddings.bottom,
                    trailing: paddings.trailing,
                ),
            ),
        )
    }

    static func applyConstraints(constraints: CNBoxConstraintsPayload?, shrink: Bool, to view: AnyView) -> AnyView {
        guard let constraints else {
            return view
        }

        let minWidth = constraints.minWidth
        let idealWidth = constraints.tightWidth
        let maxWidth = constraints.maxWidth
        let minHeight = constraints.minHeight
        let idealHeight = constraints.tightHeight
        let maxHeight = constraints.maxHeight

        if shrink {
            // In shrink mode, width constraint is handled via AutoLayout on the hosting view.
            // SwiftUI .frame(maxWidth:) doesn't propagate to fittingSize correctly.
            return AnyView(
                view.frame(
                    minWidth: minWidth,
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                ),
            )
        }

        return AnyView(
            view.frame(
                minWidth: minWidth,
                idealWidth: idealWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                idealHeight: idealHeight,
                maxHeight: maxHeight,
            ),
        )
    }

    static func applyFont(_ fontDict: [String: Any]?, to view: AnyView) -> AnyView {
        guard let fontDict else {
            return view
        }
        if let font = FontUtils.swiftUIFontFromDictionary(fontDict) {
            return AnyView(view.font(font))
        }
        return view
    }

    static func applyForegroundColor(_ foregroundColor: Int?, to view: AnyView) -> AnyView {
        guard let foregroundColor else {
            return view
        }
        return AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
    }

    static func applyTint(_ tint: Any?, to view: AnyView) -> AnyView {
        guard let tint else {
            return view
        }

        if let colorInt = tint as? Int {
            return AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(colorInt)))
        }

        if let shapeStyleDict = tint as? [String: Any],
           let shapeStyle = decodeShapeStyle(shapeStyleDict)
        {
            return AnyView(view.tint(shapeStyle))
        }

        return view
    }

    static func decodeShapeStyle(_ dict: [String: Any]) -> AnyShapeStyle? {
        guard let type = dict["type"] as? String,
              let stopsArr = dict["stops"] as? [[String: Any]]
        else { return nil }

        let stops = stopsArr.compactMap { stopDict -> Gradient.Stop? in
            guard let colorInt = stopDict["color"] as? Int,
                  let location = stopDict["location"] as? Double
            else { return nil }
            return Gradient.Stop(
                color: ColorUtils.swiftUIColorFromARGB(colorInt),
                location: CGFloat(location),
            )
        }

        guard !stops.isEmpty else { return nil }
        let gradient = Gradient(stops: stops)

        switch type {
        case "gradient":
            return AnyShapeStyle(gradient)

        case "linearGradient":
            let startPoint = decodeUnitPoint(dict["startPoint"] as? [String: Any]) ?? .leading
            let endPoint = decodeUnitPoint(dict["endPoint"] as? [String: Any]) ?? .trailing
            return AnyShapeStyle(
                LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint),
            )

        case "angularGradient":
            let center = decodeUnitPoint(dict["center"] as? [String: Any]) ?? .center
            let startAngle = Angle.degrees(dict["startAngle"] as? Double ?? 0)
            let endAngle = Angle.degrees(dict["endAngle"] as? Double ?? 360)
            return AnyShapeStyle(
                AngularGradient(gradient: gradient, center: center, startAngle: startAngle, endAngle: endAngle),
            )

        case "radialGradient":
            let center = decodeUnitPoint(dict["center"] as? [String: Any]) ?? .center
            let startRadius = CGFloat(dict["startRadius"] as? Double ?? 0)
            let endRadius = CGFloat(dict["endRadius"] as? Double ?? 100)
            return AnyShapeStyle(
                RadialGradient(gradient: gradient, center: center, startRadius: startRadius, endRadius: endRadius),
            )

        case "ellipticalGradient":
            let center = decodeUnitPoint(dict["center"] as? [String: Any]) ?? .center
            return AnyShapeStyle(
                EllipticalGradient(gradient: gradient, center: center),
            )

        default:
            return nil
        }
    }

    private static func decodeUnitPoint(_ dict: [String: Any]?) -> UnitPoint? {
        guard let dict,
              let x = dict["x"] as? Double,
              let y = dict["y"] as? Double
        else { return nil }
        return UnitPoint(x: x, y: y)
    }

    static func applyControlSize(_ size: String?, to view: AnyView) -> AnyView {
        switch size {
        case "mini":
            AnyView(view.controlSize(.mini))
        case "small":
            AnyView(view.controlSize(.small))
        case "regular":
            AnyView(view.controlSize(.regular))
        case "large":
            AnyView(view.controlSize(.large))
        case "extraLarge":
            if #available(macOS 14.0, *) {
                AnyView(view.controlSize(.extraLarge))
            } else {
                AnyView(view.controlSize(.large))
            }
        default:
            view
        }
    }

    static func applyEnabled(_ enabled: Bool?, to view: AnyView) -> AnyView {
        guard let enabled else {
            return view
        }
        return AnyView(view.disabled(!enabled))
    }

    static func applyLabelStyle(_ style: String?, to view: AnyView) -> AnyView {
        guard let style else {
            return view
        }
        switch style {
        case "titleOnly":
            return AnyView(view.labelStyle(.titleOnly))
        case "iconOnly":
            return AnyView(view.labelStyle(.iconOnly))
        case "titleAndIcon":
            return AnyView(view.labelStyle(.titleAndIcon))
        default:
            return view
        }
    }

    static func applyBadge(_ badge: Any?, to view: AnyView) -> AnyView {
        guard let badge else {
            return view
        }

        if #available(macOS 14.0, *) {
            if let badgeString = badge as? String {
                return AnyView(view.badge(badgeString))
            } else if let badgeInt = badge as? Int {
                return AnyView(view.badge(badgeInt))
            } else {
                return view
            }
        } else {
            return view
        }
    }

    static func applyButtonStyle(_ style: String?, to view: AnyView) -> AnyView {
        switch style {
        case "plain":
            AnyView(view.buttonStyle(PlainButtonStyle()))
        case "borderless":
            AnyView(view.buttonStyle(BorderlessButtonStyle()))
        case "link":
            AnyView(view.buttonStyle(LinkButtonStyle()))
        case "bordered":
            AnyView(view.buttonStyle(BorderedButtonStyle()))
        case "borderedProminent":
            AnyView(view.buttonStyle(BorderedProminentButtonStyle()))
        case "accessoryBar":
            if #available(macOS 14.0, *) {
                AnyView(view.buttonStyle(AccessoryBarButtonStyle()))
            } else {
                view
            }
        case "accessoryBarAction":
            if #available(macOS 14.0, *) {
                AnyView(view.buttonStyle(AccessoryBarActionButtonStyle()))
            } else {
                view
            }
        case "glass":
            if #available(macOS 26.0, *) {
                AnyView(view.buttonStyle(GlassButtonStyle()))
            } else {
                AnyView(view.buttonStyle(BorderedButtonStyle()))
            }
        case "prominentGlass", "glassProminent":
            if #available(macOS 26.0, *) {
                AnyView(view.buttonStyle(GlassProminentButtonStyle()))
            } else {
                AnyView(view.buttonStyle(BorderedProminentButtonStyle()))
            }
        default:
            view
        }
    }
}

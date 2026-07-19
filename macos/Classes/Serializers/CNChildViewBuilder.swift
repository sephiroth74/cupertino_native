import SwiftUI

enum CNChildViewBuilder {
    /// Builds a single child view from a dictionary payload.
    static func buildChild(_ dict: [String: Any]) -> AnyView {
        let type = dict["type"] as? String ?? ""
        var view = switch type {
        case "text":
            AnyView(buildText(dict))
        case "image":
            AnyView(buildImage(dict))
        case "vstack":
            AnyView(buildVStack(dict))
        case "hstack":
            AnyView(buildHStack(dict))
        case "group":
            AnyView(buildGroup(dict))
        case "label":
            AnyView(buildLabel(dict))
        case "divider":
            AnyView(Divider())
        case "progressView":
            AnyView(buildProgressView(dict))
        default:
            AnyView(EmptyView())
        }

        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        view = CNViewModifierApplicator.applyTint(dict["tint"], to: view)

        if let constraints = CNBoxConstraintsPayload.fromChannel(dict["constraints"] as? [String: Any]) {
            view = CNViewModifierApplicator.applyConstraints(constraints: constraints, shrink: false, to: view)
        }

        if let paddings = CNPaddingsPayload.fromChannel(dict["paddings"] as? [String: Any]) {
            view = CNViewModifierApplicator.applyPaddings(paddings, to: view)
        }

        if let enabled = dict["enabled"] as? Bool {
            view = AnyView(view.disabled(!enabled))
        }

        return view
    }

    /// Builds multiple children into a single AnyView (using Group + ForEach pattern).
    static func buildChildren(_ list: [[String: Any]]) -> AnyView {
        AnyView(
            ForEach(Array(list.enumerated()), id: \.offset) { _, child in
                buildChild(child)
            },
        )
    }

    // MARK: - Leaf builders

    private static func buildText(_ dict: [String: Any]) -> some View {
        let text = dict["text"] as? String ?? ""
        var view = AnyView(Text(text))
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        if let lineLimit = dict["lineLimit"] as? Int {
            let reservesSpace = dict["lineLimitReservesSpace"] as? Bool ?? false
            view = AnyView(view.lineLimit(lineLimit, reservesSpace: reservesSpace))
        }
        if #available(macOS 14.0, *) {
            if let textScale = dict["textScale"] as? String {
                switch textScale {
                case "defaultScale":
                    view = AnyView(view.textScale(.default))
                case "secondary":
                    view = AnyView(view.textScale(.secondary))
                default:
                    break
                }
            }
        }
        if let truncationMode = dict["truncationMode"] as? String {
            switch truncationMode {
            case "head":
                view = AnyView(view.truncationMode(.head))
            case "middle":
                view = AnyView(view.truncationMode(.middle))
            case "tail":
                view = AnyView(view.truncationMode(.tail))
            default:
                break
            }
        }
        return view
    }

    private static func buildImage(_ dict: [String: Any]) -> some View {
        let name = dict["systemSymbolName"] as? String ?? "questionmark"
        var view = AnyView(Image(systemName: name))
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        if let renderingMode = dict["symbolRenderingMode"] as? String {
            view = applySymbolRenderingMode(renderingMode, colors: dict["foregroundStyleColors"], to: view)
        }
        if #available(macOS 15.0, *) {
            if let colorRenderingMode = dict["symbolColorRenderingMode"] as? String {
                switch colorRenderingMode {
                case "flat":
                    view = AnyView(view.symbolColorRenderingMode(.flat))
                case "gradient":
                    view = AnyView(view.symbolColorRenderingMode(.gradient))
                default:
                    break
                }
            }
        }
        return view
    }

    private static func buildProgressView(_ dict: [String: Any]) -> some View {
        let total = CNChannelDeserialization.decodeDouble(dict["total"]) ?? 1.0
        let clampedTotal = max(total, 0.000001)

        var view: AnyView
        if let rawValue = CNChannelDeserialization.decodeDouble(dict["value"]) {
            let clamped = min(max(rawValue, 0.0), clampedTotal)
            view = AnyView(ProgressView(value: clamped, total: clampedTotal))
        } else {
            view = AnyView(ProgressView())
        }

        let style = dict["style"] as? String
        switch style {
        case "circular":
            view = AnyView(view.progressViewStyle(.circular))
        default:
            view = AnyView(view.progressViewStyle(.linear))
        }

        view = CNViewModifierApplicator.applyControlSize(dict["controlSize"] as? String, to: view)

        return view
    }

    private static func buildLabel(_ dict: [String: Any]) -> some View {
        let title = dict["title"] as? String ?? ""
        let systemImage = dict["systemImage"] as? String

        var view: AnyView
        if let systemImage, !systemImage.isEmpty {
            var labelView = AnyView(Label(title, systemImage: systemImage))

            if let renderingMode = dict["symbolRenderingMode"] as? String {
                labelView = applySymbolRenderingMode(renderingMode, colors: dict["foregroundStyleColors"], to: labelView)
            }

            if #available(macOS 15.0, *) {
                if let colorRenderingMode = dict["symbolColorRenderingMode"] as? String {
                    switch colorRenderingMode {
                    case "flat":
                        labelView = AnyView(labelView.symbolColorRenderingMode(.flat))
                    case "gradient":
                        labelView = AnyView(labelView.symbolColorRenderingMode(.gradient))
                    default:
                        break
                    }
                }
            }

            view = labelView
        } else {
            view = AnyView(Text(title))
        }

        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)

        if let labelStyleStr = dict["labelStyle"] as? String {
            switch labelStyleStr {
            case "titleOnly":
                view = AnyView(view.labelStyle(.titleOnly))
            case "iconOnly":
                view = AnyView(view.labelStyle(.iconOnly))
            case "titleAndIcon":
                view = AnyView(view.labelStyle(.titleAndIcon))
            default:
                break
            }
        }

        if #available(macOS 26.0, *) {
            if let reservedIconWidth = CNChannelDeserialization.decodeDouble(dict["labelReservedIconWidth"]) {
                view = AnyView(view.labelReservedIconWidth(reservedIconWidth))
            }
            if let iconToTitleSpacing = CNChannelDeserialization.decodeDouble(dict["labelIconToTitleSpacing"]) {
                view = AnyView(view.labelIconToTitleSpacing(iconToTitleSpacing))
            }
        }

        return view
    }

    @available(macOS 12.0, *)
    private static func applySymbolRenderingMode(_ mode: String, colors: Any?, to view: AnyView) -> AnyView {
        let palette: [Int] = if let rawColors = colors as? [NSNumber] {
            rawColors.map(\.intValue)
        } else if let rawColors = colors as? [Int] {
            rawColors
        } else {
            []
        }

        switch mode {
        case "hierarchical":
            if let first = palette.first {
                return AnyView(
                    view.symbolRenderingMode(.hierarchical)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.hierarchical))
        case "monochrome":
            if let first = palette.first {
                return AnyView(
                    view.symbolRenderingMode(.monochrome)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.monochrome))
        case "palette":
            let colors = palette.map(ColorUtils.swiftUIColorFromARGB)
            guard !colors.isEmpty else {
                return AnyView(view.symbolRenderingMode(.palette))
            }
            if colors.count == 1 {
                return AnyView(view.symbolRenderingMode(.palette).foregroundStyle(colors[0]))
            }
            if colors.count == 2 {
                return AnyView(view.symbolRenderingMode(.palette).foregroundStyle(colors[0], colors[1]))
            }
            return AnyView(view.symbolRenderingMode(.palette).foregroundStyle(colors[0], colors[1], colors[2]))
        case "multicolor":
            if let first = palette.first {
                return AnyView(
                    view.symbolRenderingMode(.multicolor)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.multicolor))
        default:
            return view
        }
    }

    // MARK: - Container builders

    private static func buildVStack(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        let alignment = resolveHorizontalAlignment(dict["alignment"] as? String)
        let spacing = dict["spacing"] as? CGFloat

        return AnyView(
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    private static func buildHStack(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        let alignment = resolveVerticalAlignment(dict["alignment"] as? String)
        let spacing = dict["spacing"] as? CGFloat

        return AnyView(
            HStack(alignment: alignment, spacing: spacing) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    private static func buildGroup(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        return AnyView(
            Group {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    // MARK: - Alignment helpers

    private static func resolveHorizontalAlignment(_ value: String?) -> HorizontalAlignment {
        switch value {
        case "leading": .leading
        case "trailing": .trailing
        default: .center
        }
    }

    private static func resolveVerticalAlignment(_ value: String?) -> VerticalAlignment {
        switch value {
        case "top": .top
        case "bottom": .bottom
        default: .center
        }
    }
}

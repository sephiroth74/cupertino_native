import SwiftUI

enum CNLabel2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNLabel2Payload>,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundLabel2View(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundLabel2View: View {
        @ObservedObject var model: CNViewModel<CNLabel2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view: AnyView

            let titleView = buildTitleView(payload.title)
            let iconView = buildImageView(payload.image)

            if let iconView {
                view = AnyView(
                    Label {
                        titleView
                    } icon: {
                        iconView
                    },
                )
            } else {
                view = AnyView(
                    Label {
                        titleView
                    } icon: {
                        EmptyView()
                    },
                )
            }

            view = applyLabelStyle(payload.labelStyle, to: view)

            if #available(macOS 26.0, *) {
                if let reservedIconWidth = payload.labelReservedIconWidth {
                    view = AnyView(view.labelReservedIconWidth(reservedIconWidth))
                }
                if let iconToTitleSpacing = payload.labelIconToTitleSpacing {
                    view = AnyView(view.labelIconToTitleSpacing(iconToTitleSpacing))
                }
            }

            // Apply label-level shared modifiers
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        onSizeChanged(size)
                    },
                )
            }

            return view
        }

        // MARK: - Title builder

        private func buildTitleView(_ titleDict: [String: Any]?) -> AnyView {
            guard let dict = titleDict else {
                return AnyView(Text(""))
            }

            let text = dict["text"] as? String ?? ""
            var view = AnyView(Text(text))

            view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
            view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)

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

        // MARK: - Image builder

        private func buildImageView(_ imageDict: [String: Any]?) -> AnyView? {
            guard let dict = imageDict else { return nil }
            guard let symbolName = dict["systemSymbolName"] as? String, !symbolName.isEmpty else { return nil }

            var view = AnyView(Image(systemName: symbolName))

            view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
            view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)

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

        @available(macOS 12.0, *)
        private func applySymbolRenderingMode(_ mode: String, colors: Any?, to view: AnyView) -> AnyView {
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

        // MARK: - Label style

        private func applyLabelStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "titleOnly":
                AnyView(view.labelStyle(.titleOnly))
            case "iconOnly":
                AnyView(view.labelStyle(.iconOnly))
            case "titleAndIcon":
                AnyView(view.labelStyle(.titleAndIcon))
            default:
                view
            }
        }
    }
}

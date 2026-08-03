import SwiftUI

enum CNImage2Deserializer {
    static func makeRootView(model: CNViewModel<CNImage2Payload>, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundImage2View(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundImage2View: View {
        @ObservedObject var model: CNViewModel<CNImage2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            var view = AnyView(Image(systemName: payload.systemSymbolName))

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

            // Apply image-specific modifiers
            view = Self.applyColorRenderingMode(to: view, payload: payload)
            view = Self.applyRenderingMode(to: view, payload: payload)

            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

            // Constraints last (outermost)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyHelp(payload.help, to: view)
            view = CNViewModifierApplicator.applyOverlay(payload.overlay, to: view)

            // Debug log rectangle
            view = CNViewModifierApplicator.applyDebugLogRectangle(payload.debugLog, to: view)

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        onSizeChanged(size)
                    },
                )
            }

            return AnyView(view.id(payload.viewDebugId))
        }

        @available(macOS 15.0, *)
        private static func applyColorRenderingMode(to view: AnyView, payload: CNImage2Payload) -> AnyView {
            switch payload.symbolColorRenderingMode {
            case "flat":
                AnyView(view.symbolColorRenderingMode(.flat))
            case "gradient":
                AnyView(view.symbolColorRenderingMode(.gradient))
            default:
                view
            }
        }

        @available(macOS 12.0, *)
        private static func applyRenderingMode(to view: AnyView, payload: CNImage2Payload) -> AnyView {
            switch payload.symbolRenderingMode {
            case "hierarchical":
                if let first = payload.foregroundStyleColors.first {
                    return AnyView(
                        view
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                    )
                }
                return AnyView(view.symbolRenderingMode(.hierarchical))
            case "monochrome":
                if let first = payload.foregroundStyleColors.first {
                    return AnyView(
                        view
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                    )
                }
                return AnyView(view.symbolRenderingMode(.monochrome))
            case "palette":
                let palette = payload.foregroundStyleColors.map(ColorUtils.swiftUIColorFromARGB)
                guard !palette.isEmpty else {
                    return AnyView(view.symbolRenderingMode(.palette))
                }
                if palette.count == 1 {
                    return AnyView(
                        view
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(palette[0]),
                    )
                }
                if palette.count == 2 {
                    return AnyView(
                        view
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(palette[0], palette[1]),
                    )
                }
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0], palette[1], palette[2]),
                )
            case "multicolor":
                if let first = payload.foregroundStyleColors.first {
                    return AnyView(
                        view
                            .symbolRenderingMode(.multicolor)
                            .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                    )
                }
                return AnyView(view.symbolRenderingMode(.multicolor))
            default:
                return view
            }
        }
    }
}

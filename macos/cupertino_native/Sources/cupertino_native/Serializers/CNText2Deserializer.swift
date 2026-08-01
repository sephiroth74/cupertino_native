import SwiftUI

enum CNText2Deserializer {
    static func makeRootView(model: CNViewModel<CNText2Payload>, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundText2View(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundText2View: View {
        @ObservedObject var model: CNViewModel<CNText2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            var view = AnyView(Text(payload.text))

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

            // Apply text-specific modifiers
            view = Self.applyLineLimit(to: view, payload: payload)

            if #available(macOS 14.0, *) {
                view = Self.applyTextScale(to: view, payload: payload)
            }

            view = Self.applyTruncationMode(to: view, payload: payload)

            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

            // Constraints last (outermost)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyHelp(payload.help, to: view)
            view = CNViewModifierApplicator.applyOverlay(payload.overlay, to: view)

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

        private static func applyLineLimit(to view: AnyView, payload: CNText2Payload) -> AnyView {
            guard let lineLimit = payload.lineLimit else {
                return view
            }
            return AnyView(view.lineLimit(lineLimit, reservesSpace: payload.lineLimitReservesSpace ?? false))
        }

        @available(macOS 14.0, *)
        private static func applyTextScale(to view: AnyView, payload: CNText2Payload) -> AnyView {
            switch payload.textScale {
            case "defaultScale":
                AnyView(view.textScale(.default))
            case "secondary":
                AnyView(view.textScale(.secondary))
            default:
                view
            }
        }

        private static func applyTruncationMode(to view: AnyView, payload: CNText2Payload) -> AnyView {
            switch payload.truncationMode {
            case "head":
                AnyView(view.truncationMode(.head))
            case "middle":
                AnyView(view.truncationMode(.middle))
            case "tail":
                AnyView(view.truncationMode(.tail))
            default:
                view
            }
        }
    }
}

import SwiftUI

enum CNProgressView2Deserializer {
    static func makeRootView(model: CNViewModel<CNProgressView2Payload>, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundProgressView2(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundProgressView2: View {
        @ObservedObject var model: CNViewModel<CNProgressView2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            let total = max(payload.total ?? 1.0, 0.000001)

            var view: AnyView = {
                if let rawValue = payload.value {
                    let clamped = Swift.min(Swift.max(rawValue, 0.0), total)
                    return AnyView(ProgressView(value: clamped, total: total))
                }
                return AnyView(ProgressView())
            }()

            // Apply style
            view = Self.applyStyle(to: view, payload: payload)

            // Apply control size
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

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

            let viewId = "\(payload.viewDebugId)_\(payload.style ?? "linear")_\(payload.value == nil ? "ind" : "det")_\(payload.controlSize ?? "regular")"
            return AnyView(view.id(viewId))
        }

        private static func applyStyle(to view: AnyView, payload: CNProgressView2Payload) -> AnyView {
            switch payload.style {
            case "circular":
                AnyView(view.progressViewStyle(.circular))
            default:
                AnyView(view.progressViewStyle(.linear))
            }
        }
    }
}

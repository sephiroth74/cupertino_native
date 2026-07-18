import SwiftUI

enum CNButton2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNButton2Payload>,
        onPressed: @escaping () -> Void,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundButton2View(model: model, onPressed: onPressed, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundButton2View: View {
        @ObservedObject var model: CNViewModel<CNButton2Payload>
        let onPressed: () -> Void
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view = AnyView(
                Button(role: resolveRole(payload.role), action: onPressed) {
                    ForEach(Array(payload.children.enumerated()), id: \.offset) { _, child in
                        CNChildViewBuilder.buildChild(child)
                    }
                },
            )

            view = CNViewModifierApplicator.applyButtonStyle(payload.buttonStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
            view = CNViewModifierApplicator.applyLabelStyle(payload.labelStyle, to: view)

            if #available(macOS 26.0, *) {
                if let reservedIconWidth = payload.labelReservedIconWidth {
                    view = AnyView(view.labelReservedIconWidth(reservedIconWidth))
                }
                if let iconToTitleSpacing = payload.labelIconToTitleSpacing {
                    view = AnyView(view.labelIconToTitleSpacing(iconToTitleSpacing))
                }
            }

            // Shared modifiers
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyEnabled(payload.enabled, to: view)

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

        private func resolveRole(_ role: String?) -> ButtonRole? {
            switch role {
            case "cancel": .cancel
            case "close": .close
            case "confirm": .confirm
            case "destructive": .destructive
            default: nil
            }
        }
    }
}

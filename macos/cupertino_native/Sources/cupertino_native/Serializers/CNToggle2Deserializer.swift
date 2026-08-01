import SwiftUI

enum CNToggle2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNToggle2Payload>,
        onValueChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundToggle2View(
            model: model,
            onValueChanged: onValueChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundToggle2View: View {
        @ObservedObject var model: CNViewModel<CNToggle2Payload>
        let onValueChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let isOnBinding = Binding<Bool>(
                get: { model.payload.isOn },
                set: { newValue in
                    guard newValue != model.payload.isOn else { return }
                    model.payload.isOn = newValue
                    onValueChanged?(newValue)
                },
            )

            var view = if let content = payload.content {
                AnyView(
                    Toggle(isOn: isOnBinding) {
                        CNChildViewBuilder.buildChild(content)
                    },
                )
            } else {
                AnyView(
                    Toggle(isOn: isOnBinding) {
                        EmptyView()
                    },
                )
            }

            // Apply toggle style
            view = applyToggleStyle(payload.toggleStyle, to: view)

            // Disabled state
            if !payload.enabled {
                view = AnyView(view.disabled(true))
            }

            // Apply control size
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
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

            return view
        }

        private func applyToggleStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "switchStyle":
                AnyView(view.toggleStyle(.switch))
            case "checkbox":
                AnyView(view.toggleStyle(.checkbox))
            case "button":
                AnyView(view.toggleStyle(.button))
            default:
                AnyView(view.toggleStyle(.automatic))
            }
        }
    }
}

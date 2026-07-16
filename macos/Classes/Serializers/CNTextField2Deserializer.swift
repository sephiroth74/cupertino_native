import SwiftUI

enum CNTextField2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNTextField2Payload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSubmitted: ((String) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundTextField2View(
            model: model,
            onTextChanged: onTextChanged,
            onSubmitted: onSubmitted,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundTextField2View: View {
        @ObservedObject var model: CNViewModel<CNTextField2Payload>
        let onTextChanged: ((String) -> Void)?
        let onSubmitted: ((String) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let textBinding = Binding<String>(
                get: { model.payload.text },
                set: { newValue in
                    guard newValue != model.payload.text else { return }
                    model.payload.text = newValue
                    onTextChanged?(newValue)
                },
            )

            var view = if let prompt = payload.prompt, !prompt.isEmpty {
                if let placeholder = payload.placeholder, !placeholder.isEmpty {
                    AnyView(
                        TextField(placeholder, text: textBinding, prompt: Text(prompt))
                            .onSubmit { onSubmitted?(model.payload.text) },
                    )
                } else {
                    AnyView(
                        TextField("", text: textBinding, prompt: Text(prompt))
                            .onSubmit { onSubmitted?(model.payload.text) },
                    )
                }
            } else if let placeholder = payload.placeholder, !placeholder.isEmpty {
                AnyView(
                    TextField(placeholder, text: textBinding)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            } else {
                AnyView(
                    TextField("", text: textBinding)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            }

            // Apply font
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)

            // Apply border
            if let borderColor = payload.borderColor {
                let color = ColorUtils.colorFromARGB(borderColor)
                let width = payload.borderWidth ?? 1.0
                view = AnyView(view.border(Color(nsColor: color), width: width))
            }

            // Apply style
            view = applyTextFieldStyle(payload.textFieldStyle, to: view)

            // Apply control size
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

            // Constraints last (outermost)
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

        private func applyTextFieldStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "plain":
                AnyView(view.textFieldStyle(.plain))
            case "roundedBorder":
                AnyView(view.textFieldStyle(.roundedBorder))
            default:
                view
            }
        }
    }
}

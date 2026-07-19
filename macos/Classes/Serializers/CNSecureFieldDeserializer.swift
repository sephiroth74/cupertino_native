import SwiftUI

enum CNSecureFieldDeserializer {
    static func makeRootView(
        model: CNViewModel<CNSecureFieldPayload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSubmitted: ((String) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundSecureFieldView(
            model: model,
            onTextChanged: onTextChanged,
            onSubmitted: onSubmitted,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundSecureFieldView: View {
        @ObservedObject var model: CNViewModel<CNSecureFieldPayload>
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

            let placeholder = payload.placeholder ?? ""
            let promptView: Text? = payload.prompt.flatMap { $0.isEmpty ? nil : Text($0) }

            var view = if let promptView {
                AnyView(
                    SecureField(placeholder, text: textBinding, prompt: promptView)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            } else {
                AnyView(
                    SecureField(placeholder, text: textBinding)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            }

            view = CNViewModifierApplicator.applyFont(payload.font, to: view)

            if let borderColor = payload.borderColor {
                let color = ColorUtils.colorFromARGB(borderColor)
                let width = payload.borderWidth ?? 1.0
                view = AnyView(view.border(Color(nsColor: color), width: width))
            }

            view = applyTextFieldStyle(payload.textFieldStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
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

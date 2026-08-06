import SwiftUI

enum CNSecureFieldDeserializer {
    static func makeRootView(
        model: CNViewModel<CNSecureFieldPayload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSubmitted: ((String) -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundSecureFieldView(
            model: model,
            onTextChanged: onTextChanged,
            onSubmitted: onSubmitted,
            onFocusChanged: onFocusChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundSecureFieldView: View {
        @ObservedObject var model: CNViewModel<CNSecureFieldPayload>
        let onTextChanged: ((String) -> Void)?
        let onSubmitted: ((String) -> Void)?
        let onFocusChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?
        @FocusState private var isFocused: Bool
        @State private var localText: String = ""

        var body: some View {
            let payload = model.payload

            let textBinding = Binding<String>(
                get: { localText },
                set: { newValue in
                    // Store raw; truncation is enforced in onChange so the state
                    // genuinely transitions and the NSSecureTextField re-renders
                    // the capped value (it does not revert on a no-op setter).
                    localText = newValue
                },
            )

            let placeholder = payload.placeholder ?? ""
            let promptView: Text? = payload.prompt.flatMap { $0.isEmpty ? nil : Text($0) }

            var view = if let promptView {
                AnyView(
                    SecureField(placeholder, text: textBinding, prompt: promptView)
                        .onSubmit { onSubmitted?(localText) }
                        .focused($isFocused),
                )
            } else {
                AnyView(
                    SecureField(placeholder, text: textBinding)
                        .onSubmit { onSubmitted?(localText) }
                        .focused($isFocused),
                )
            }

            view = AnyView(
                view
                    .onChange(of: localText) { _, newText in
                        let truncated = CNTextTruncation.truncate(newText, maxLength: model.payload.maxLength)
                        if truncated != newText {
                            localText = truncated
                            return
                        }
                        guard truncated != model.payload.text else { return }
                        model.payload.text = truncated
                        onTextChanged?(truncated)
                    }
                    .onChange(of: model.payload.text) { _, newText in
                        // Dart pushed new text via applyPatch.
                        if newText != localText {
                            localText = newText
                        }
                    }
                    .onChange(of: isFocused) { _, focused in
                        onFocusChanged?(focused)
                    }
                    .onAppear {
                        localText = model.payload.text
                    },
            )

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

            if payload.autofocus {
                view = AnyView(
                    view.onAppear { isFocused = true },
                )
            }

            view = CNViewModifierApplicator.applyHelp(payload.help, to: view)
            view = CNViewModifierApplicator.applyBackground(payload.background, to: view)
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

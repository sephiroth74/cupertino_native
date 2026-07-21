import SwiftUI

enum CNTextField2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNTextField2Payload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)? = nil,
        onSubmitted: ((String) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundTextField2View(
            model: model,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onSubmitted: onSubmitted,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundTextField2View: View {
        @ObservedObject var model: CNViewModel<CNTextField2Payload>
        let onTextChanged: ((String) -> Void)?
        let onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)?
        let onSubmitted: ((String) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?
        @FocusState private var isFocused: Bool

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

            var view: AnyView = if #available(macOS 15.0, *) {
                AnyView(_CNTextField2WithSelection(
                    model: model,
                    textBinding: textBinding,
                    payload: payload,
                    autofocus: payload.autofocus,
                    onSelectionChanged: onSelectionChanged,
                    onSubmitted: onSubmitted,
                ))
            } else {
                makeTextFieldLegacy(textBinding: textBinding, payload: payload)
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

            // Autofocus for legacy path (macOS < 15)
            if #unavailable(macOS 15.0), payload.autofocus {
                view = AnyView(
                    view.focused($isFocused)
                        .onAppear { isFocused = true },
                )
            }

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

        private func makeTextFieldLegacy(textBinding: Binding<String>, payload: CNTextField2Payload) -> AnyView {
            let placeholder = payload.placeholder ?? ""
            let promptView: Text? = payload.prompt.flatMap { $0.isEmpty ? nil : Text($0) }

            if let promptView {
                return AnyView(
                    TextField(placeholder, text: textBinding, prompt: promptView)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            } else {
                return AnyView(
                    TextField(placeholder, text: textBinding)
                        .onSubmit { onSubmitted?(model.payload.text) },
                )
            }
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

    @available(macOS 15.0, *)
    private struct _CNTextField2WithSelection: View {
        @ObservedObject var model: CNViewModel<CNTextField2Payload>
        let textBinding: Binding<String>
        let payload: CNTextField2Payload
        let autofocus: Bool
        let onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)?
        let onSubmitted: ((String) -> Void)?

        @State private var localText: String = ""
        @State private var selection: TextSelection?
        @FocusState private var isFocused: Bool

        var body: some View {
            let placeholder = payload.placeholder ?? ""
            let promptView: Text? = payload.prompt.flatMap { $0.isEmpty ? nil : Text($0) }

            let combinedTextBinding = Binding<String>(
                get: { localText },
                set: { newValue in
                    localText = newValue
                },
            )

            Group {
                if let promptView {
                    TextField(placeholder, text: combinedTextBinding, selection: $selection, prompt: promptView)
                        .onSubmit { onSubmitted?(localText) }
                } else {
                    TextField(placeholder, text: combinedTextBinding, selection: $selection)
                        .onSubmit { onSubmitted?(localText) }
                }
            }
            .focused($isFocused)
            .onChange(of: localText) { _, newText in
                guard newText != model.payload.text else { return }
                // textBinding setter updates model.payload.text AND calls onTextChanged
                textBinding.wrappedValue = newText
            }
            .onChange(of: selection) { _, newSelection in
                reportSelection(newSelection)
            }
            .onChange(of: model.payload.text) { _, newText in
                // Dart pushed new text via applyPatch
                if newText != localText {
                    localText = newText
                }
            }
            .onAppear {
                localText = model.payload.text
                if autofocus {
                    isFocused = true
                }
            }
        }

        private func log(_ message: String) {
            guard model.payload.debugLog else { return }
            NSLog("[CNTextField2][Selection] \(message)")
        }

        private func reportSelection(_ newSelection: TextSelection?) {
            guard let newSelection else {
                log("newSelection is nil, skipping")
                return
            }
            // Use localText which is always in sync with the TextField's selection indices
            let text = localText
            log("reportSelection called. text='\(text)' (count=\(text.count)), isInsertion=\(newSelection.isInsertion)")
            let base: Int
            let extent: Int
            if newSelection.isInsertion {
                switch newSelection.indices {
                case let .selection(range):
                    guard range.lowerBound >= text.startIndex, range.lowerBound <= text.endIndex else {
                        log("ERROR: insertion range.lowerBound out of bounds!")
                        return
                    }
                    base = text.distance(from: text.startIndex, to: range.lowerBound)
                    extent = base
                    log("insertion .selection -> base=\(base)")
                case let .multiSelection(rangeSet):
                    guard let first = rangeSet.ranges.first else { return }
                    guard first.lowerBound >= text.startIndex, first.lowerBound <= text.endIndex else {
                        log("ERROR: insertion multiSelection first.lowerBound out of bounds!")
                        return
                    }
                    base = text.distance(from: text.startIndex, to: first.lowerBound)
                    extent = base
                    log("insertion .multiSelection -> base=\(base)")
                @unknown default:
                    log("ERROR: insertion selection indices is neither .selection nor .multiSelection")
                    return
                }
            } else {
                switch newSelection.indices {
                case let .selection(range):
                    guard range.lowerBound >= text.startIndex, range.lowerBound <= text.endIndex,
                          range.upperBound >= text.startIndex, range.upperBound <= text.endIndex
                    else {
                        log("ERROR: selection range out of bounds!")
                        return
                    }
                    base = text.distance(from: text.startIndex, to: range.lowerBound)
                    extent = text.distance(from: text.startIndex, to: range.upperBound)
                    log("selection .selection -> base=\(base), extent=\(extent)")
                case let .multiSelection(rangeSet):
                    guard let first = rangeSet.ranges.first else { return }
                    guard first.lowerBound >= text.startIndex, first.lowerBound <= text.endIndex,
                          first.upperBound >= text.startIndex, first.upperBound <= text.endIndex
                    else {
                        log("ERROR: selection multiSelection range out of bounds!")
                        return
                    }
                    base = text.distance(from: text.startIndex, to: first.lowerBound)
                    extent = text.distance(from: text.startIndex, to: first.upperBound)
                    log("selection .multiSelection -> base=\(base), extent=\(extent)")
                @unknown default:
                    log("ERROR: selection indices is neither .selection nor .multiSelection")
                    return
                }
            }
            let oldBase = model.payload.selectionBase
            let oldExtent = model.payload.selectionExtent
            log("old=(\(oldBase ?? -1), \(oldExtent ?? -1)) new=(\(base), \(extent))")
            guard base != oldBase || extent != oldExtent else { return }
            model.payload.selectionBase = base
            model.payload.selectionExtent = extent
            onSelectionChanged?(base, extent)
        }
    }
}

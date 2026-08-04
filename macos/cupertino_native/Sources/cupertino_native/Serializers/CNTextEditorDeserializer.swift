import SwiftUI

enum CNTextEditorDeserializer {
    static func makeRootView(
        model: CNViewModel<CNTextEditorPayload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundTextEditorView(
            model: model,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onFocusChanged: onFocusChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundTextEditorView: View {
        @ObservedObject var model: CNViewModel<CNTextEditorPayload>
        let onTextChanged: ((String) -> Void)?
        let onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)?
        let onFocusChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?
        @FocusState private var isFocused: Bool

        var body: some View {
            let payload = model.payload

            let textBinding = Binding<String>(
                get: { model.payload.text },
                set: { rawValue in
                    let newValue = CNTextTruncation.truncate(rawValue, maxLength: model.payload.maxLength)
                    guard newValue != model.payload.text else { return }
                    model.payload.text = newValue
                    onTextChanged?(newValue)
                },
            )

            var view: AnyView = if #available(macOS 15.0, *) {
                AnyView(_CNTextEditorWithSelection(
                    model: model,
                    textBinding: textBinding,
                    autofocus: payload.autofocus,
                    onSelectionChanged: onSelectionChanged,
                    onFocusChanged: onFocusChanged,
                ))
            } else {
                makeTextEditorLegacy(textBinding: textBinding, payload: payload)
            }

            // Read-only editing behaviour.
            if !payload.editable {
                view = AnyView(view.disabled(true))
            }

            // Apply font
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)

            // Apply border
            if let borderColor = payload.borderColor {
                let color = ColorUtils.colorFromARGB(borderColor)
                let width = payload.borderWidth ?? 1.0
                view = AnyView(view.border(Color(nsColor: color), width: width))
            }

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

            // Constraints last (outermost). shrink is always false for the editor,
            // so this expands the view to fill the resolved frame.
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)

            // Autofocus for legacy path (macOS < 15)
            if #unavailable(macOS 15.0), payload.autofocus {
                view = AnyView(
                    view.focused($isFocused)
                        .onAppear { isFocused = true },
                )
            }

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

            return view
        }

        private func makeTextEditorLegacy(textBinding: Binding<String>, payload _: CNTextEditorPayload) -> AnyView {
            AnyView(TextEditor(text: textBinding))
        }
    }

    @available(macOS 15.0, *)
    private struct _CNTextEditorWithSelection: View {
        @ObservedObject var model: CNViewModel<CNTextEditorPayload>
        let textBinding: Binding<String>
        let autofocus: Bool
        let onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)?
        let onFocusChanged: ((Bool) -> Void)?

        @State private var localText: String = ""
        @State private var selection: TextSelection?
        @FocusState private var isFocused: Bool

        var body: some View {
            let combinedTextBinding = Binding<String>(
                get: { localText },
                set: { newValue in
                    // Store raw; truncation is enforced in onChange so the state
                    // genuinely transitions and SwiftUI re-renders the capped value.
                    localText = newValue
                },
            )

            TextEditor(text: combinedTextBinding, selection: $selection)
                .focused($isFocused)
                .onChange(of: localText) { _, newText in
                    let truncated = CNTextTruncation.truncate(newText, maxLength: model.payload.maxLength)
                    if truncated != newText {
                        localText = truncated
                        return
                    }
                    guard truncated != model.payload.text else { return }
                    // textBinding setter updates model.payload.text AND calls onTextChanged
                    textBinding.wrappedValue = truncated
                }
                .onChange(of: selection) { _, newSelection in
                    reportSelection(newSelection)
                }
                .onChange(of: isFocused) { _, focused in
                    onFocusChanged?(focused)
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
            NSLog("[CNTextEditor][Selection] \(message)")
        }

        private func reportSelection(_ newSelection: TextSelection?) {
            guard let newSelection else {
                log("newSelection is nil, skipping")
                return
            }
            let text = localText
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
                case let .multiSelection(rangeSet):
                    guard let first = rangeSet.ranges.first else { return }
                    guard first.lowerBound >= text.startIndex, first.lowerBound <= text.endIndex else {
                        log("ERROR: insertion multiSelection first.lowerBound out of bounds!")
                        return
                    }
                    base = text.distance(from: text.startIndex, to: first.lowerBound)
                    extent = base
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
                @unknown default:
                    log("ERROR: selection indices is neither .selection nor .multiSelection")
                    return
                }
            }
            let oldBase = model.payload.selectionBase
            let oldExtent = model.payload.selectionExtent
            guard base != oldBase || extent != oldExtent else { return }
            model.payload.selectionBase = base
            model.payload.selectionExtent = extent
            onSelectionChanged?(base, extent)
        }
    }
}

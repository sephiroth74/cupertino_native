import SwiftUI

enum CNTextField2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNTextField2Payload>,
        onTextChanged: ((String) -> Void)? = nil,
        onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)? = nil,
        onSubmitted: ((String) -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundTextField2View(
            model: model,
            onTextChanged: onTextChanged,
            onSelectionChanged: onSelectionChanged,
            onSubmitted: onSubmitted,
            onFocusChanged: onFocusChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundTextField2View: View {
        @ObservedObject var model: CNViewModel<CNTextField2Payload>
        let onTextChanged: ((String) -> Void)?
        let onSelectionChanged: ((_ base: Int, _ extent: Int) -> Void)?
        let onSubmitted: ((String) -> Void)?
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
                AnyView(_CNTextField2WithSelection(
                    model: model,
                    textBinding: textBinding,
                    payload: payload,
                    autofocus: payload.autofocus,
                    onSelectionChanged: onSelectionChanged,
                    onSubmitted: onSubmitted,
                    onFocusChanged: onFocusChanged,
                ))
            } else {
                makeTextFieldLegacy(textBinding: textBinding, payload: payload)
            }

            view = CNViewModifierApplicator.applyEnabled(payload.enabled, to: view)

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

            // Constraints last (outermost)
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
            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

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
        let onFocusChanged: ((Bool) -> Void)?

        @State private var localText: String = ""
        @State private var selection: TextSelection?
        @FocusState private var isFocused: Bool

        var body: some View {
            let placeholder = payload.placeholder ?? ""
            let promptView: Text? = payload.prompt.flatMap { $0.isEmpty ? nil : Text($0) }

            // Key that changes whenever Dart pushes a new selection, so an
            // inbound selection (e.g. a combo box autocomplete highlighting the
            // completed suffix) can be applied to the field.
            let incomingSelectionKey = "\(model.payload.selectionBase ?? -1):\(model.payload.selectionExtent ?? -1)"

            let combinedTextBinding = Binding<String>(
                get: { localText },
                set: { newValue in
                    // Store the raw value so the state genuinely transitions.
                    // Truncation happens in onChange below: an NSTextField-backed
                    // TextField only reverts its visible buffer on a real state
                    // change, so truncating here (20 -> 20) would leave the extra
                    // character on screen until the next edit/submit.
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
                let truncated = CNTextTruncation.truncate(newText, maxLength: model.payload.maxLength)
                if truncated != newText {
                    // Reject the overflow. This truncated -> localText transition
                    // forces SwiftUI to re-render the field with the capped value.
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
                // Dart pushed new text via applyPatch. Update the buffer first,
                // then re-apply the incoming selection against the new text so
                // its indices are valid (Dart sends text + selection together).
                if newText != localText {
                    localText = newText
                }
                applyIncomingSelection(in: newText)
            }
            .onChange(of: incomingSelectionKey) { _, _ in
                // Selection-only change from Dart (text unchanged).
                applyIncomingSelection(in: localText)
            }
            .onAppear {
                localText = model.payload.text
                applyIncomingSelection(in: localText)
                if autofocus {
                    isFocused = true
                }
            }
        }

        /// Applies a selection pushed from Dart to the field, mapping integer
        /// offsets to `String.Index` against `text`. No-ops when the payload has
        /// no selection or the offsets fall outside `text` (e.g. a stale index
        /// arriving before the matching text change).
        private func applyIncomingSelection(in text: String) {
            guard let rawBase = model.payload.selectionBase,
                  let rawExtent = model.payload.selectionExtent
            else { return }
            // TextSelection ranges are direction-agnostic; normalize to ascending.
            let lower = min(rawBase, rawExtent)
            let upper = max(rawBase, rawExtent)
            guard lower >= 0, upper <= text.count else {
                log("applyIncomingSelection out of bounds: (\(lower), \(upper)) for count=\(text.count)")
                return
            }
            let startIndex = text.index(text.startIndex, offsetBy: lower)
            let newSelection = if lower == upper {
                TextSelection(insertionPoint: startIndex)
            } else {
                TextSelection(range: startIndex ..< text.index(text.startIndex, offsetBy: upper))
            }
            // Skip if already applied — avoids a redundant re-render and keeps
            // reportSelection's equality guard from bouncing the value back.
            guard selection != newSelection else { return }
            selection = newSelection
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

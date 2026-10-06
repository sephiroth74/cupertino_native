import SwiftUI

enum CNPicker2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNPicker2Payload>,
        onSelectionChanged: @escaping (String) -> Void,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundPicker2View(model: model, onSelectionChanged: onSelectionChanged, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundPicker2View: View {
        @ObservedObject var model: CNViewModel<CNPicker2Payload>
        let onSelectionChanged: (String) -> Void
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let binding = Binding<String>(
                get: { payload.selection },
                set: { newValue in
                    onSelectionChanged(newValue)
                },
            )

            var view = if let labelItems = payload.label, !labelItems.isEmpty {
                AnyView(
                    Picker(selection: binding) {
                        Self.buildItems(payload.children)
                    } label: {
                        CNChildViewBuilder.buildChildren(labelItems)
                    },
                )
            } else {
                AnyView(
                    Picker(selection: binding, label: Text("")) {
                        Self.buildItems(payload.children)
                    }.labelsHidden(),
                )
            }

            view = applyPickerStyle(payload.pickerStyle, to: view)
            // Only a menu picker draws a button bezel for the glass to replace.
            let isMenuPicker = [nil, "automatic", "menu"].contains(payload.pickerStyle)
            let buttonStyle = isMenuPicker
                ? CNViewModifierApplicator.resolveStyle(payload.buttonStyle, glassEffect: payload.glassEffect, bezelFreeStyle: "borderless")
                : payload.buttonStyle
            view = CNViewModifierApplicator.applyButtonStyle(buttonStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyGlassEffect(payload.glassEffect, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyFixedSize(payload.fixedSize, to: view)
            view = CNViewModifierApplicator.applyEnabled(payload.enabled, to: view)
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

        private static func buildItems(_ items: [[String: Any]]) -> some View {
            ForEach(Array(items.enumerated()), id: \.offset) { _, child in
                let tag = child["tag"] as? String ?? ""
                CNChildViewBuilder.buildChild(mirroringTintOnIcon(child)).tag(tag)
            }
        }

        /// Since macOS 27 the closed `.menu` picker is drawn by SwiftUI instead of an
        /// NSPopUpButton, and it ignores `.tint` on the selected label's icon (the open
        /// NSMenu still honors it). Mirroring the tint into the icon's foreground style
        /// keeps both states the same color; `.tint` is kept for the NSMenu items.
        private static func mirroringTintOnIcon(_ child: [String: Any]) -> [String: Any] {
            guard child["type"] as? String == "label",
                  let tint = child["tint"] as? Int,
                  (child["foregroundStyleColors"] as? [Any])?.isEmpty ?? true
            else { return child }

            var child = child
            child["foregroundStyleColors"] = [tint]
            if child["symbolRenderingMode"] as? String == nil {
                child["symbolRenderingMode"] = "monochrome"
            }
            return child
        }

        private func applyPickerStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "inline":
                AnyView(view.pickerStyle(.inline))

            case "menu":
                AnyView(view.pickerStyle(.menu))

            case "segmented":
                AnyView(view.pickerStyle(.segmented))

            case "radioGroup":
                AnyView(view.pickerStyle(.radioGroup))

            case "palette":
                if #available(macOS 14.0, *) {
                    AnyView(view.pickerStyle(.palette))
                } else {
                    view
                }

            case "navigationLink":
                view

            default:
                AnyView(view.pickerStyle(.automatic))
            }
        }
    }
}

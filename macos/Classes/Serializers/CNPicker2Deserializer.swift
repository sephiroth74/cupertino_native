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
                    Picker(selection: binding) {
                        Self.buildItems(payload.children)
                    } label: {
                        EmptyView()
                    },
                )
            }

            view = applyPickerStyle(payload.pickerStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
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

        private static func buildItems(_ items: [[String: Any]]) -> some View {
            ForEach(Array(items.enumerated()), id: \.offset) { _, child in
                let tag = child["tag"] as? String ?? ""
                CNChildViewBuilder.buildChild(child).tag(tag)
            }
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

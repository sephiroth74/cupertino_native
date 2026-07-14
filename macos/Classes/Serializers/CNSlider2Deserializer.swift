import SwiftUI

enum CNSlider2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNSlider2Payload>,
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundSlider2View(
            model: model,
            onValueChanged: onValueChanged,
            onEditingChanged: onEditingChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundSlider2View: View {
        @ObservedObject var model: CNViewModel<CNSlider2Payload>
        let onValueChanged: ((Double) -> Void)?
        let onEditingChanged: ((Bool) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let valueBinding = Binding<Double>(
                get: { model.payload.value },
                set: { newValue in
                    model.payload.value = newValue
                    onValueChanged?(newValue)
                },
            )

            var view = if let step = payload.step, step > 0 {
                AnyView(
                    Slider(
                        value: valueBinding,
                        in: payload.min ... payload.max,
                        step: step,
                        onEditingChanged: { editing in
                            onEditingChanged?(editing)
                        },
                    ),
                )
            } else {
                AnyView(
                    Slider(
                        value: valueBinding,
                        in: payload.min ... payload.max,
                        onEditingChanged: { editing in
                            onEditingChanged?(editing)
                        },
                    ),
                )
            }

            // Apply control size
            view = Self.applyControlSize(to: view, payload: payload)

            // Apply shared modifiers
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

            let viewId = "\(payload.viewDebugId)_\(payload.min)_\(payload.max)_\(payload.step ?? -1)_\(payload.controlSize ?? "regular")"
            return AnyView(view.id(viewId))
        }

        private static func applyControlSize(to view: AnyView, payload: CNSlider2Payload) -> AnyView {
            switch payload.controlSize {
            case "mini":
                AnyView(view.controlSize(.mini))
            case "small":
                AnyView(view.controlSize(.small))
            case "large":
                AnyView(view.controlSize(.large))
            case "extraLarge":
                AnyView(view.controlSize(.extraLarge))
            default:
                AnyView(view.controlSize(.regular))
            }
        }
    }
}

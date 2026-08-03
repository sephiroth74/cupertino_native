import SwiftUI

enum CNStepper2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNStepper2Payload>,
        onValueChanged: ((Double) -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundStepper2View(
            model: model,
            onValueChanged: onValueChanged,
            onEditingChanged: onEditingChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundStepper2View: View {
        @ObservedObject var model: CNViewModel<CNStepper2Payload>
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

            var view = AnyView(
                Stepper(
                    value: valueBinding,
                    in: payload.min ... payload.max,
                    step: payload.step,
                    onEditingChanged: { editing in
                        onEditingChanged?(editing)
                    },
                ) {
                    EmptyView()
                },
            )

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

            let viewId = "\(payload.viewDebugId)_\(payload.min)_\(payload.max)_\(payload.step)_\(payload.controlSize ?? "regular")"
            return AnyView(view.id(viewId))
        }
    }
}

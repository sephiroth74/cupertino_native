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

            var view: AnyView = Self.makeSlider(
                valueBinding: valueBinding,
                payload: payload,
                onEditingChanged: onEditingChanged,
            )

            // Disabled state
            if !payload.enabled {
                view = AnyView(view.disabled(true))
            }

            // Apply control size
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)

            // Apply shared modifiers
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)

            // Paddings
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)

            // Constraints last (outermost)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyHelp(payload.help, to: view)
            view = CNViewModifierApplicator.applyOverlay(payload.overlay, to: view)

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

        private static func makeSlider(
            valueBinding: Binding<Double>,
            payload: CNSlider2Payload,
            onEditingChanged: ((Bool) -> Void)?,
        ) -> AnyView {
            let hasLabels = payload.minimumValueLabel != nil || payload.maximumValueLabel != nil
            let hasTicks = payload.ticks != nil && !payload.ticks!.isEmpty
            let step = hasTicks ? nil : payload.step

            // Ticks (macOS 26+)
            if let ticks = payload.ticks, !ticks.isEmpty {
                if #available(macOS 26.0, *) {
                    return makeTicksSlider(
                        valueBinding: valueBinding,
                        payload: payload,
                        ticks: ticks,
                        hasLabels: hasLabels,
                        onEditingChanged: onEditingChanged,
                    )
                }
            }

            if hasLabels {
                let minLabel = payload.minimumValueLabel.map { Text($0) }
                let maxLabel = payload.maximumValueLabel.map { Text($0) }

                if let step, step > 0 {
                    return AnyView(
                        Slider(
                            value: valueBinding,
                            in: payload.min ... payload.max,
                            step: step,
                            onEditingChanged: { editing in onEditingChanged?(editing) },
                            minimumValueLabel: minLabel,
                            maximumValueLabel: maxLabel,
                            label: { EmptyView() },
                        ),
                    )
                } else {
                    return AnyView(
                        Slider(
                            value: valueBinding,
                            in: payload.min ... payload.max,
                            onEditingChanged: { editing in onEditingChanged?(editing) },
                            minimumValueLabel: minLabel,
                            maximumValueLabel: maxLabel,
                            label: { EmptyView() },
                        ),
                    )
                }
            } else {
                if let step, step > 0 {
                    return AnyView(
                        Slider(
                            value: valueBinding,
                            in: payload.min ... payload.max,
                            step: step,
                            onEditingChanged: { editing in onEditingChanged?(editing) },
                        ),
                    )
                } else {
                    return AnyView(
                        Slider(
                            value: valueBinding,
                            in: payload.min ... payload.max,
                            onEditingChanged: { editing in onEditingChanged?(editing) },
                        ),
                    )
                }
            }
        }

        @available(macOS 26.0, *)
        private static func makeTicksSlider(
            valueBinding: Binding<Double>,
            payload: CNSlider2Payload,
            ticks: [CNSliderTickPayload],
            hasLabels: Bool,
            onEditingChanged: ((Bool) -> Void)?,
        ) -> AnyView {
            let tickLabels = Dictionary(uniqueKeysWithValues: ticks.compactMap { t in
                t.label.map { (t.value, $0) }
            })

            let tickValues = ticks.map(\.value)

            if hasLabels {
                return AnyView(
                    Slider(
                        value: valueBinding,
                        in: payload.min ... payload.max,
                        label: { EmptyView() },
                        minimumValueLabel: { Text(payload.minimumValueLabel ?? "") },
                        maximumValueLabel: { Text(payload.maximumValueLabel ?? "") },
                        ticks: {
                            SliderTickContentForEach(tickValues, id: \.self) { val in
                                if let label = tickLabels[val] {
                                    SliderTick(val) { Text(label) }
                                } else {
                                    SliderTick(val)
                                }
                            }
                        },
                        onEditingChanged: { editing in onEditingChanged?(editing) },
                    ),
                )
            } else {
                return AnyView(
                    Slider(
                        value: valueBinding,
                        in: payload.min ... payload.max,
                        label: { EmptyView() },
                        ticks: {
                            SliderTickContentForEach(tickValues, id: \.self) { val in
                                if let label = tickLabels[val] {
                                    SliderTick(val) { Text(label) }
                                } else {
                                    SliderTick(val)
                                }
                            }
                        },
                        onEditingChanged: { editing in onEditingChanged?(editing) },
                    ),
                )
            }
        }
    }
}

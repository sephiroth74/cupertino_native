import SwiftUI

enum CNGauge2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNGauge2Payload>,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundGauge2View(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundGauge2View: View {
        @ObservedObject var model: CNViewModel<CNGauge2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view: AnyView = makeGauge(payload: payload)

            view = applyGaugeStyle(payload.gaugeStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(
                constraints: payload.constraints, shrink: payload.shrink, to: view,
            )
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

            return view
        }

        private func makeGauge(payload: CNGauge2Payload) -> AnyView {
            AnyView(
                Gauge(value: payload.value, in: payload.min ... payload.max) {
                    buildChildren(payload.label)
                } currentValueLabel: {
                    buildChildren(payload.currentValueLabel)
                } minimumValueLabel: {
                    buildChildren(payload.minimumValueLabel)
                } maximumValueLabel: {
                    buildChildren(payload.maximumValueLabel)
                },
            )
        }

        @ViewBuilder
        private func buildChildren(_ children: [[String: Any]]?) -> some View {
            if let children, !children.isEmpty {
                if children.count == 1 {
                    CNChildViewBuilder.buildChild(children[0])
                } else {
                    VStack {
                        ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                            CNChildViewBuilder.buildChild(child)
                        }
                    }
                }
            }
        }

        private func applyGaugeStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "accessoryCircular":
                AnyView(view.gaugeStyle(.accessoryCircular))
            case "accessoryCircularCapacity":
                AnyView(view.gaugeStyle(.accessoryCircularCapacity))
            case "accessoryLinear":
                AnyView(view.gaugeStyle(.accessoryLinear))
            case "accessoryLinearCapacity":
                AnyView(view.gaugeStyle(.accessoryLinearCapacity))
            case "linearCapacity":
                AnyView(view.gaugeStyle(.linearCapacity))
            default:
                view
            }
        }
    }
}

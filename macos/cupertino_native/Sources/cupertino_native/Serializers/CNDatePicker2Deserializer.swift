import SwiftUI

enum CNDatePicker2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNDatePicker2Payload>,
        onDateChanged: ((Date) -> Void)? = nil,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundDatePicker2View(
            model: model,
            onDateChanged: onDateChanged,
            onSizeChanged: onSizeChanged,
        ))
    }

    private struct _CNBoundDatePicker2View: View {
        @ObservedObject var model: CNViewModel<CNDatePicker2Payload>
        let onDateChanged: ((Date) -> Void)?
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            let date = payload.selection.map { Date(timeIntervalSince1970: $0 / 1000) } ?? Date()

            let dateBinding = Binding<Date>(
                get: { date },
                set: { newDate in
                    model.payload.selection = newDate.timeIntervalSince1970 * 1000
                    onDateChanged?(newDate)
                },
            )

            let components = Self.resolveComponents(payload.displayedComponents)
            let label = payload.label ?? ""

            var view: AnyView

            if let minDate = payload.minDate, let maxDate = payload.maxDate {
                let min = Date(timeIntervalSince1970: minDate / 1000)
                let max = Date(timeIntervalSince1970: maxDate / 1000)
                view = AnyView(DatePicker(label, selection: dateBinding, in: min ... max, displayedComponents: components))
            } else if let minDate = payload.minDate {
                let min = Date(timeIntervalSince1970: minDate / 1000)
                view = AnyView(DatePicker(label, selection: dateBinding, in: min..., displayedComponents: components))
            } else if let maxDate = payload.maxDate {
                let max = Date(timeIntervalSince1970: maxDate / 1000)
                view = AnyView(DatePicker(label, selection: dateBinding, in: ...max, displayedComponents: components))
            } else {
                view = AnyView(DatePicker(label, selection: dateBinding, displayedComponents: components))
            }

            // Disabled state
            if !payload.enabled {
                view = AnyView(view.disabled(true))
            }

            // Apply style
            view = Self.applyStyle(to: view, payload: payload)

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

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { size in
                        onSizeChanged(size)
                    },
                )
            }

            let viewId = "\(payload.viewDebugId)_\(payload.datePickerStyle ?? "automatic")_\(payload.displayedComponents?.joined(separator: ",") ?? "date")_\(payload.controlSize ?? "regular")"
            return AnyView(view.id(viewId))
        }

        private static func resolveComponents(_ components: [String]?) -> DatePickerComponents {
            guard let components else { return .date }
            var result: DatePickerComponents = []
            for component in components {
                switch component {
                case "date":
                    result.insert(.date)
                case "hourAndMinute":
                    result.insert(.hourAndMinute)
                default:
                    break
                }
            }
            return result.isEmpty ? .date : result
        }

        private static func applyStyle(to view: AnyView, payload: CNDatePicker2Payload) -> AnyView {
            switch payload.datePickerStyle {
            case "compact":
                AnyView(view.datePickerStyle(.compact))
            case "graphical":
                AnyView(view.datePickerStyle(.graphical))
            case "field":
                AnyView(view.datePickerStyle(.field))
            default:
                AnyView(view.datePickerStyle(.automatic))
            }
        }
    }
}

import SwiftUI

enum CNLabel2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNLabel2Payload>,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundLabel2View(model: model, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundLabel2View: View {
        @ObservedObject var model: CNViewModel<CNLabel2Payload>
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view = if let imageDict = payload.image,
                          let symbolName = imageDict["systemSymbolName"] as? String, !symbolName.isEmpty
            {
                AnyView(
                    Label {
                        CNChildViewBuilder.buildChild(payload.title ?? ["type": "text", "text": ""])
                    } icon: {
                        CNChildViewBuilder.buildChild(imageDict)
                    },
                )
            } else {
                AnyView(
                    Label {
                        CNChildViewBuilder.buildChild(payload.title ?? ["type": "text", "text": ""])
                    } icon: {
                        EmptyView()
                    },
                )
            }

            view = CNViewModifierApplicator.applyLabelStyle(payload.labelStyle, to: view)

            if #available(macOS 26.0, *) {
                if let reservedIconWidth = payload.labelReservedIconWidth {
                    view = AnyView(view.labelReservedIconWidth(reservedIconWidth))
                }
                if let iconToTitleSpacing = payload.labelIconToTitleSpacing {
                    view = AnyView(view.labelIconToTitleSpacing(iconToTitleSpacing))
                }
            }

            // Apply label-level shared modifiers
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
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
    }
}

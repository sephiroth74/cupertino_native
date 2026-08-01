import SwiftUI

enum CNMenu2Deserializer {
    static func makeRootView(
        model: CNViewModel<CNMenu2Payload>,
        onItemPressed: @escaping (String) -> Void,
        onSizeChanged: ((CGSize) -> Void)? = nil,
    ) -> AnyView {
        AnyView(_CNBoundMenu2View(model: model, onItemPressed: onItemPressed, onSizeChanged: onSizeChanged))
    }

    private struct _CNBoundMenu2View: View {
        @ObservedObject var model: CNViewModel<CNMenu2Payload>
        let onItemPressed: (String) -> Void
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload

            var view = if let primaryActionTag = payload.primaryActionTag {
                AnyView(
                    Menu {
                        Self.buildMenuItems(payload.items, onItemPressed: onItemPressed)
                    } label: {
                        Self.buildLabel(payload.label)
                    } primaryAction: {
                        onItemPressed(primaryActionTag)
                    },
                )
            } else {
                AnyView(
                    Menu {
                        Self.buildMenuItems(payload.items, onItemPressed: onItemPressed)
                    } label: {
                        Self.buildLabel(payload.label)
                    },
                )
            }

            view = applyMenuStyle(payload.menuStyle, to: view)
            view = CNViewModifierApplicator.applyControlSize(payload.controlSize, to: view)
            view = CNViewModifierApplicator.applyFont(payload.font, to: view)
            view = CNViewModifierApplicator.applyForegroundColor(payload.foregroundColor, to: view)
            view = CNViewModifierApplicator.applyTint(payload.tint, to: view)
            view = CNViewModifierApplicator.applyPaddings(payload.paddings, to: view)
            view = CNViewModifierApplicator.applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = CNViewModifierApplicator.applyEnabled(payload.enabled, to: view)
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

        // MARK: - Menu items

        private static func buildMenuItems(_ items: [[String: Any]], onItemPressed: @escaping (String) -> Void) -> AnyView {
            AnyView(
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Self.buildMenuItem(item, onItemPressed: onItemPressed)
                },
            )
        }

        private static func buildMenuItem(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
            let type = dict["type"] as? String ?? ""
            switch type {
            case "button":
                return buildButton(dict, onItemPressed: onItemPressed)
            case "divider":
                return AnyView(Divider())
            case "menu":
                return buildSubMenu(dict, onItemPressed: onItemPressed)
            default:
                return AnyView(EmptyView())
            }
        }

        private static func buildButton(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
            let id = dict["tag"] as? String ?? ""
            let title = dict["title"] as? String ?? ""
            let systemImage = dict["systemImage"] as? String
            let role = CNChannelDeserialization.resolveButtonRole(dict["role"] as? String)
            let badge = dict["badge"]

            var view = if let systemImage, !systemImage.isEmpty {
                AnyView(
                    Button(title, systemImage: systemImage, role: role) {
                        onItemPressed(id)
                    },
                )
            } else {
                AnyView(
                    Button(title, role: role) {
                        onItemPressed(id)
                    },
                )
            }

            view = CNViewModifierApplicator.applyBadge(badge, to: view)
            view = CNViewModifierApplicator.applyTint(dict["tint"], to: view)
            view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)

            if let enabled = dict["enabled"] as? Bool {
                view = AnyView(view.disabled(!enabled))
            }

            return view
        }

        private static func buildSubMenu(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
            let subItems = dict["items"] as? [[String: Any]] ?? []
            let labelItems = dict["label"] as? [[String: Any]] ?? []
            let primaryActionTag = dict["tag"] as? String

            if let primaryActionTag {
                return AnyView(
                    Menu {
                        Self.buildMenuItems(subItems, onItemPressed: onItemPressed)
                    } label: {
                        Self.buildLabel(labelItems)
                    } primaryAction: {
                        onItemPressed(primaryActionTag)
                    },
                )
            } else {
                return AnyView(
                    Menu {
                        Self.buildMenuItems(subItems, onItemPressed: onItemPressed)
                    } label: {
                        Self.buildLabel(labelItems)
                    },
                )
            }
        }

        private static func buildLabel(_ items: [[String: Any]]) -> AnyView {
            AnyView(
                ForEach(Array(items.enumerated()), id: \.offset) { _, child in
                    CNChildViewBuilder.buildChild(child)
                },
            )
        }

        // MARK: - Helpers

        private func applyMenuStyle(_ style: String?, to view: AnyView) -> AnyView {
            switch style {
            case "automatic":
                AnyView(view.menuStyle(.automatic))

            case "button":
                if #available(macOS 14.0, *) {
                    AnyView(view.menuStyle(.button))
                } else {
                    view
                }

            case "borderedButton":
                AnyView(view.menuStyle(.borderedButton))

            case "borderlessButton":
                if #available(macOS 14.0, *) {
                    AnyView(view.menuStyle(.borderlessButton))
                } else {
                    view
                }

            default:
                view
            }
        }
    }
}

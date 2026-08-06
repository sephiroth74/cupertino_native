import Cocoa
import FlutterMacOS

final class CNContextMenuHandler: NSObject {
    private weak var registrar: FlutterPluginRegistrar?
    private var selectedMenuItem: NSMenuItem?

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    func showContextMenu2(args: [String: Any], result: @escaping FlutterResult) {
        guard let items = args["items"] as? [[String: Any]] else {
            result(
                FlutterError(
                    code: "invalid_args",
                    message: "showContextMenu2 expects an 'items' list",
                    details: nil,
                ),
            )
            return
        }

        guard
            let window = registrar?.getFlutterWindow(),
            let contentView = window.contentView
        else {
            result(
                FlutterError(
                    code: "window_unavailable",
                    message: "Unable to resolve Flutter window/content view",
                    details: nil,
                ),
            )
            return
        }

        let menu = buildNSMenu(from: items)

        if let menuWidth = asDouble(args["minWidth"]) {
            menu.minimumWidth = menuWidth
        }

        let anchorPoint = resolveMenuPoint(args: args, contentView: contentView)
        selectedMenuItem = nil
        _ = menu.popUp(positioning: nil, at: anchorPoint, in: contentView)

        // menu.popUp runs a nested event loop that consumes the rightMouseUp.
        // Flutter never sees the release, leaving a phantom active pointer that
        // blocks subsequent left-click gesture recognition. Post a synthetic
        // rightMouseUp so the engine's pointer state resets properly.
        if let flutterView = registrar?.view {
            let locationInWindow = window.mouseLocationOutsideOfEventStream
            let syntheticUp = NSEvent.mouseEvent(
                with: .rightMouseUp,
                location: locationInWindow,
                modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber,
                context: nil,
                eventNumber: 0,
                clickCount: 1,
                pressure: 0,
            )
            if let syntheticUp {
                flutterView.rightMouseUp(with: syntheticUp)
            }
        }

        if let tag = selectedMenuItem?.identifier?.rawValue, !tag.isEmpty {
            result(tag)
        } else {
            result(nil)
        }
    }

    private func buildNSMenu(from items: [[String: Any]]) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        for item in items {
            let type = item["type"] as? String ?? ""
            switch type {
            case "button":
                let menuItem = buildNSMenuItem(from: item)
                menu.addItem(menuItem)
            case "divider":
                menu.addItem(.separator())
            case "menu":
                let menuItem = buildNSSubMenu(from: item)
                menu.addItem(menuItem)
            default:
                break
            }
        }

        return menu
    }

    private func buildNSMenuItem(from dict: [String: Any]) -> NSMenuItem {
        let title = dict["title"] as? String ?? ""
        let tag = dict["tag"] as? String ?? ""
        let systemImage = dict["systemImage"] as? String
        let enabled = dict["enabled"] as? Bool ?? true

        let menuItem = NSMenuItem(title: title, action: #selector(menuItemSelected(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.identifier = NSUserInterfaceItemIdentifier(tag)
        menuItem.isEnabled = enabled

        if let systemImage, !systemImage.isEmpty {
            if let nsImage = NSImage(systemSymbolName: systemImage, accessibilityDescription: nil) {
                menuItem.image = nsImage
            }
        }

        return menuItem
    }

    private func buildNSSubMenu(from dict: [String: Any]) -> NSMenuItem {
        let labelItems = dict["label"] as? [[String: Any]] ?? []
        let subItems = dict["items"] as? [[String: Any]] ?? []

        let title = labelItems.first(where: { ($0["type"] as? String) == "text" || ($0["type"] as? String) == "label" })?["title"] as? String
            ?? labelItems.first?["text"] as? String
            ?? ""

        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        menuItem.submenu = buildNSMenu(from: subItems)

        return menuItem
    }

    // MARK: - Private

    @objc
    private func menuItemSelected(_ sender: NSMenuItem) {
        selectedMenuItem = sender
    }

    private func resolveMenuPoint(args: [String: Any], contentView: NSView) -> NSPoint {
        if let x = asDouble(args["x"]),
           let y = asDouble(args["y"])
        {
            return NSPoint(
                x: x,
                y: contentView.bounds.height - y,
            )
        }

        let mouseScreen = NSEvent.mouseLocation
        guard let window = contentView.window else {
            return .zero
        }
        let windowPoint = window.convertPoint(fromScreen: mouseScreen)
        return contentView.convert(windowPoint, from: nil)
    }

    private func asDouble(_ value: Any?) -> CGFloat? {
        if let number = value as? NSNumber {
            return CGFloat(truncating: number)
        }
        if let value = value as? Double {
            return CGFloat(value)
        }
        return nil
    }
}

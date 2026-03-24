import Cocoa
import FlutterMacOS

final class CupertinoContextMenuHandler: NSObject {
    private weak var registrar: FlutterPluginRegistrar?
    private var selectedMenuItem: NSMenuItem?

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    func showContextMenu(args: [String: Any], result: @escaping FlutterResult) {
        guard let menuJson = args["menu"] as? String else {
            result(
                FlutterError(
                    code: "invalid_args",
                    message: "showContextMenu expects a menu JSON string",
                    details: nil))
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
                    details: nil))
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                result(nil)
                return
            }
            self.presentContextMenu(
                menuJson: menuJson,
                args: args,
                contentView: contentView,
                result: result)
        }
    }

    private func presentContextMenu(
        menuJson: String,
        args: [String: Any],
        contentView: NSView,
        result: @escaping FlutterResult
    ) {
        let menu = deserializeMenu(jsonString: menuJson)
        let anchorPoint = resolveMenuPoint(args: args, contentView: contentView)
        selectedMenuItem = nil
        _ = menu.popUp(positioning: nil, at: anchorPoint, in: contentView)

        guard let selectedItem = selectedMenuItem else {
            result(nil)
            return
        }

        let title: String = selectedItem.title
        let identifier: String = selectedItem.identifier?.rawValue ?? ""
        let tag: Int = selectedItem.tag
        let index: Int = selectedItem.menu?.index(of: selectedItem) ?? -1

        let payload: [String: Any] = [
            "title": title,
            "identifier": identifier,
            "tag": tag,
            "index": index,
        ]

        result(payload)
    }

    @objc
    private func menuItemSelected(_ sender: NSMenuItem) {
        selectedMenuItem = sender
    }

    private func resolveMenuPoint(args: [String: Any], contentView: NSView) -> NSPoint {
        if let x = asDouble(args["x"]),
            let y = asDouble(args["y"])
        {
            let converted = NSPoint(
                x: x,
                y: contentView.bounds.height - y)
            return converted
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

    private func deserializeMenu(jsonString: String) -> NSMenu {
        guard
            let data = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let root = json as? [String: Any]
        else {
            return NSMenu()
        }
        return deserializeMenu(dict: root)
    }

    private func deserializeMenu(dict: [String: Any]) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.selectionMode = .automatic

        guard let items = dict["items"] as? [[String: Any]] else {
            return menu
        }

        for item in items {
            if let separator = item["separator"] as? Bool, separator {
                menu.addItem(.separator())
                continue
            }

            guard let title = item["title"] as? String else { continue }

            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menuItem.target = self
            menuItem.action = #selector(menuItemSelected(_:))

            if let identifier = item["identifier"] as? String, !identifier.isEmpty {
                menuItem.identifier = NSUserInterfaceItemIdentifier(identifier)
            }

            if let tag = item["tag"] as? NSNumber {
                menuItem.tag = tag.intValue
            } else if let tag = item["tag"] as? Int {
                menuItem.tag = tag
            }

            if let enabled = item["enabled"] as? Bool {
                menuItem.isEnabled = enabled
            }

            if let stateString = item["state"] as? String {
                switch stateString {
                case "on":
                    menuItem.state = .on
                case "mixed":
                    menuItem.state = .mixed
                default:
                    menuItem.state = .off
                }
            }

            if let image = item["image"] as? [String: Any] {
                menuItem.image = deserializeImage(dict: image)
            }

            if let submenu = item["submenu"] as? [String: Any] {
                menuItem.submenu = deserializeMenu(dict: submenu)
            }

            menu.addItem(menuItem)
        }

        return menu
    }

    private func deserializeImage(dict: [String: Any]) -> NSImage? {
        guard let systemSymbolName = dict["systemSymbolName"] as? String else {
            return nil
        }

        let baseImage = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
        guard let symbolConfig = dict["symbolConfiguration"] as? [String: Any],
            let type = symbolConfig["type"] as? String
        else {
            return baseImage
        }

        switch type {
        case "hierarchical":
            if let value = symbolConfig["color"] as? NSNumber {
                let color = ColorUtils.colorFromARGB(value.intValue)
                return baseImage?.withSymbolConfiguration(.init(hierarchicalColor: color))
            }
        case "monochrome":
            if let value = symbolConfig["color"] as? NSNumber {
                return baseImage?.tinted(with: ColorUtils.colorFromARGB(value.intValue))
            }
            return baseImage?.withSymbolConfiguration(.preferringMonochrome())
        case "palette":
            if let colors = symbolConfig["colors"] as? [NSNumber], !colors.isEmpty {
                let nsColors = colors.map { ColorUtils.colorFromARGB($0.intValue) }
                return baseImage?.withSymbolConfiguration(.init(paletteColors: nsColors))
            }
        case "multicolor":
            return baseImage?.withSymbolConfiguration(.preferringMulticolor())
        default:
            break
        }

        return baseImage
    }
}

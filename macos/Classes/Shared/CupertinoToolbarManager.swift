import Cocoa
import FlutterMacOS

final class CupertinoToolbarManager {
    private var delegatesByWindowNumber: [Int: ToolbarDelegate] = [:]
    private let eventsChannel: FlutterMethodChannel

    init(messenger: FlutterBinaryMessenger) {
        self.eventsChannel = FlutterMethodChannel(
            name: "cupertino_native/toolbar_events",
            binaryMessenger: messenger
        )
    }

    func setToolbar(window: NSWindow, args: [String: Any], result: @escaping FlutterResult) {
        let identifierRaw = (args["identifier"] as? String) ?? "CupertinoNativeToolbar"
        let items = parseItems(args["items"])
        let allowsUserCustomization = (args["allowsUserCustomization"] as? Bool) ?? false
        let autosavesConfiguration = (args["autosavesConfiguration"] as? Bool) ?? false
        let displayModeRaw = (args["displayMode"] as? String) ?? "iconAndLabel"
        let sizeModeRaw = (args["sizeMode"] as? String) ?? "regular"

        DispatchQueue.main.async {
            let toolbar = NSToolbar(identifier: NSToolbar.Identifier(identifierRaw))
            let delegate = ToolbarDelegate(items: items, eventsChannel: self.eventsChannel)
            toolbar.delegate = delegate
            toolbar.allowsUserCustomization = allowsUserCustomization
            toolbar.autosavesConfiguration = autosavesConfiguration
            toolbar.displayMode = Self.displayMode(from: displayModeRaw)
            toolbar.sizeMode = Self.sizeMode(from: sizeModeRaw)

            window.toolbar = toolbar
            self.delegatesByWindowNumber[window.windowNumber] = delegate
            result(nil)
        }
    }

    func clearToolbar(window: NSWindow, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            self.delegatesByWindowNumber.removeValue(forKey: window.windowNumber)
            window.toolbar = nil
            result(nil)
        }
    }

    private func parseItems(_ raw: Any?) -> [ToolbarItemModel] {
        guard let list = raw as? [Any] else {
            return []
        }

        var parsed: [ToolbarItemModel] = []
        parsed.reserveCapacity(list.count)

        for item in list {
            let dict: [String: Any]
            if let asStringAny = item as? [String: Any] {
                dict = asStringAny
            } else if let asHash = item as? [AnyHashable: Any] {
                var normalized: [String: Any] = [:]
                for (k, v) in asHash {
                    if let key = k as? String {
                        normalized[key] = v
                    }
                }
                dict = normalized
            } else {
                continue
            }

            guard let id = dict["id"] as? String, !id.isEmpty else {
                continue
            }

            let label = (dict["label"] as? String) ?? id
            let toolTip = dict["toolTip"] as? String
            let symbol = dict["systemSymbolName"] as? String
            parsed.append(
                ToolbarItemModel(id: id, label: label, toolTip: toolTip, systemSymbolName: symbol))
        }

        return parsed
    }

    private static func displayMode(from raw: String) -> NSToolbar.DisplayMode {
        switch raw {
        case "iconOnly":
            return .iconOnly
        case "labelOnly":
            return .labelOnly
        case "automatic":
            return .default
        default:
            return .iconAndLabel
        }
    }

    private static func sizeMode(from raw: String) -> NSToolbar.SizeMode {
        switch raw {
        case "small":
            return .small
        case "automatic":
            return .default
        default:
            return .regular
        }
    }
}

private struct ToolbarItemModel {
    let id: String
    let label: String
    let toolTip: String?
    let systemSymbolName: String?
}

private final class ToolbarDelegate: NSObject, NSToolbarDelegate {
    private let items: [ToolbarItemModel]
    private let eventsChannel: FlutterMethodChannel
    private let ids: [NSToolbarItem.Identifier]

    init(items: [ToolbarItemModel], eventsChannel: FlutterMethodChannel) {
        self.items = items
        self.eventsChannel = eventsChannel
        self.ids = items.map { NSToolbarItem.Identifier($0.id) }
        super.init()
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return ids + [.flexibleSpace, .space, .separator]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return ids
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        guard let model = items.first(where: { $0.id == itemIdentifier.rawValue }) else {
            return nil
        }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = model.label
        item.paletteLabel = model.label
        item.toolTip = model.toolTip
        item.target = self
        item.action = #selector(onToolbarItemPressed(_:))

        if let symbolName = model.systemSymbolName {
            item.image = NSImage(
                systemSymbolName: symbolName, accessibilityDescription: model.label)
        }

        return item
    }

    @objc
    private func onToolbarItemPressed(_ sender: NSToolbarItem) {
        eventsChannel.invokeMethod(
            "onToolbarItemPressed", arguments: ["id": sender.itemIdentifier.rawValue])
    }
}

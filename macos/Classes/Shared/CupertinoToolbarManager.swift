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

            let kind = ToolbarItemKind(rawValue: (dict["kind"] as? String) ?? "button") ?? .button
            let label = (dict["label"] as? String) ?? id
            let toolTip = dict["toolTip"] as? String
            let symbol = dict["systemSymbolName"] as? String
            let text = dict["text"] as? String
            let placeholder = dict["placeholder"] as? String
            let width = (dict["width"] as? NSNumber).map { CGFloat(truncating: $0) }
            let items = (dict["items"] as? [String]) ?? []
            let behavior = dict["behavior"] as? String
            let comboButtonStyle = dict["comboButtonStyle"] as? String
            let menuItems = parseMenuItems(dict["menuItems"])
            parsed.append(
                ToolbarItemModel(
                    kind: kind,
                    id: id,
                    label: label,
                    toolTip: toolTip,
                    systemSymbolName: symbol,
                    text: text,
                    placeholder: placeholder,
                    width: width,
                    items: items,
                    behavior: behavior,
                    menuItems: menuItems,
                    comboButtonStyle: comboButtonStyle))
        }

        return parsed
    }

    private func parseMenuItems(_ raw: Any?) -> [ToolbarMenuItemModel] {
        guard let list = raw as? [Any] else {
            return []
        }

        var parsed: [ToolbarMenuItemModel] = []
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

            parsed.append(
                ToolbarMenuItemModel(
                    id: id,
                    title: (dict["title"] as? String) ?? id,
                    tag: (dict["tag"] as? NSNumber)?.intValue,
                    enabled: (dict["enabled"] as? Bool) ?? true,
                    isSeparator: (dict["isSeparator"] as? Bool) ?? false))
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

private enum ToolbarItemKind: String {
    case button
    case searchField
    case comboBox
    case comboButton
}

private struct ToolbarItemModel {
    let kind: ToolbarItemKind
    let id: String
    let label: String
    let toolTip: String?
    let systemSymbolName: String?
    let text: String?
    let placeholder: String?
    let width: CGFloat?
    let items: [String]
    let behavior: String?
    let menuItems: [ToolbarMenuItemModel]
    let comboButtonStyle: String?
}

private struct ToolbarMenuItemModel {
    let id: String
    let title: String
    let tag: Int?
    let enabled: Bool
    let isSeparator: Bool
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

        switch model.kind {
        case .button:
            return makeButtonItem(itemIdentifier: itemIdentifier, model: model)
        case .searchField:
            return makeSearchFieldItem(itemIdentifier: itemIdentifier, model: model)
        case .comboBox:
            return makeComboBoxItem(itemIdentifier: itemIdentifier, model: model)
        case .comboButton:
            return makeComboButtonItem(itemIdentifier: itemIdentifier, model: model)
        }
    }

    private func makeButtonItem(
        itemIdentifier: NSToolbarItem.Identifier,
        model: ToolbarItemModel
    ) -> NSToolbarItem {
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

    private func makeSearchFieldItem(
        itemIdentifier: NSToolbarItem.Identifier,
        model: ToolbarItemModel
    ) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = model.label
        item.paletteLabel = model.label
        item.toolTip = model.toolTip

        let field = ToolbarSearchField(model: model, eventsChannel: eventsChannel)
        item.view = field
        item.minSize = field.intrinsicContentSize
        item.maxSize = field.intrinsicContentSize
        return item
    }

    private func makeComboBoxItem(
        itemIdentifier: NSToolbarItem.Identifier,
        model: ToolbarItemModel
    ) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = model.label
        item.paletteLabel = model.label
        item.toolTip = model.toolTip

        let comboBox = ToolbarComboBox(model: model, eventsChannel: eventsChannel)
        item.view = comboBox
        item.minSize = comboBox.intrinsicContentSize
        item.maxSize = comboBox.intrinsicContentSize
        return item
    }

    private func makeComboButtonItem(
        itemIdentifier: NSToolbarItem.Identifier,
        model: ToolbarItemModel
    ) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = model.label
        item.paletteLabel = model.label
        item.toolTip = model.toolTip

        let comboButton = ToolbarComboButton(model: model, eventsChannel: eventsChannel)
        item.view = comboButton
        item.minSize = comboButton.intrinsicContentSize
        item.maxSize = comboButton.intrinsicContentSize
        return item
    }

    @objc
    private func onToolbarItemPressed(_ sender: NSToolbarItem) {
        eventsChannel.invokeMethod(
            "onToolbarItemPressed", arguments: ["id": sender.itemIdentifier.rawValue])
        eventsChannel.invokeMethod(
            "onToolbarEvent",
            arguments: [
                "id": sender.itemIdentifier.rawValue,
                "type": "buttonPressed",
            ])
    }
}

private final class ToolbarSearchField: NSSearchField, NSSearchFieldDelegate {
    private let itemId: String
    private let eventsChannel: FlutterMethodChannel

    init(model: ToolbarItemModel, eventsChannel: FlutterMethodChannel) {
        self.itemId = model.id
        self.eventsChannel = eventsChannel
        let width = model.width ?? 180
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 28))

        placeholderString = model.placeholder
        stringValue = model.text ?? ""
        delegate = self
        target = self
        action = #selector(onSubmit(_:))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: frame.width, height: 28)
    }

    func controlTextDidChange(_ obj: Notification) {
        eventsChannel.invokeMethod(
            "onToolbarEvent",
            arguments: [
                "id": itemId,
                "type": "searchChanged",
                "text": stringValue,
            ])
    }

    @objc
    private func onSubmit(_ sender: NSSearchField) {
        eventsChannel.invokeMethod(
            "onToolbarEvent",
            arguments: [
                "id": itemId,
                "type": "searchSubmitted",
                "text": stringValue,
            ])
    }
}

private final class ToolbarComboBox: NSComboBox, NSComboBoxDelegate, NSTextFieldDelegate {
    private let itemId: String
    private let eventsChannel: FlutterMethodChannel

    init(model: ToolbarItemModel, eventsChannel: FlutterMethodChannel) {
        self.itemId = model.id
        self.eventsChannel = eventsChannel
        let width = model.width ?? 160
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 28))

        usesDataSource = false
        addItems(withObjectValues: model.items)
        stringValue = model.text ?? ""
        placeholderString = model.placeholder
        delegate = self
        target = self
        action = #selector(onSubmit(_:))
        completes = false
        isButtonBordered = true
        applyBehavior(model.behavior ?? "editable")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: frame.width, height: 28)
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        emitChange(type: "comboBoxChanged")
    }

    func controlTextDidChange(_ obj: Notification) {
        emitChange(type: "comboBoxChanged")
    }

    @objc
    private func onSubmit(_ sender: NSComboBox) {
        emitChange(type: "comboBoxSubmitted")
    }

    private func emitChange(type: String) {
        var payload: [String: Any] = [
            "id": itemId,
            "type": type,
            "text": stringValue,
        ]
        if indexOfSelectedItem >= 0 {
            payload["selectedIndex"] = indexOfSelectedItem
        }
        eventsChannel.invokeMethod("onToolbarEvent", arguments: payload)
    }

    private func applyBehavior(_ raw: String) {
        switch raw {
        case "none":
            isEditable = false
            isEnabled = false
        case "selectable":
            isEditable = false
            isEnabled = true
        default:
            isEditable = true
            isEnabled = true
        }
    }
}

private final class ToolbarComboButton: NSSegmentedControl {
    private let itemId: String
    private let itemLabel: String
    private let eventsChannel: FlutterMethodChannel
    private let menuItems: [ToolbarMenuItemModel]
    private let comboButtonStyle: String

    init(model: ToolbarItemModel, eventsChannel: FlutterMethodChannel) {
        self.itemId = model.id
        self.itemLabel = model.label
        self.eventsChannel = eventsChannel
        self.menuItems = model.menuItems
        self.comboButtonStyle = model.comboButtonStyle ?? "split"

        let width = model.width ?? 160
        super.init(frame: NSRect(x: 0, y: 0, width: width, height: 28))

        segmentCount = 2
        trackingMode = .momentary
        let chevronWidth: CGFloat = comboButtonStyle == "unified" ? 20 : 24
        setWidth(width - chevronWidth, forSegment: 0)
        setWidth(chevronWidth, forSegment: 1)
        setLabel(model.label, forSegment: 0)

        if let symbolName = model.systemSymbolName, model.label.isEmpty {
            setImage(
                NSImage(systemSymbolName: symbolName, accessibilityDescription: model.label),
                forSegment: 0)
        }

        setImage(
            NSImage(systemSymbolName: "chevron.down", accessibilityDescription: "Menu"),
            forSegment: 1)
        target = self
        action = #selector(onSegmentPressed(_:))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: frame.width, height: 28)
    }

    @objc
    private func onSegmentPressed(_ sender: NSSegmentedControl) {
        defer { selectedSegment = -1 }

        if selectedSegment == 0 {
            eventsChannel.invokeMethod(
                "onToolbarEvent",
                arguments: [
                    "id": itemId,
                    "type": "comboButtonPressed",
                ])
            return
        }

        let menu = NSMenu(title: itemLabel)
        for menuItemModel in menuItems {
            if menuItemModel.isSeparator {
                menu.addItem(.separator())
                continue
            }

            let item = NSMenuItem(
                title: menuItemModel.title,
                action: #selector(onMenuItemSelected(_:)),
                keyEquivalent: "")
            item.target = self
            item.isEnabled = menuItemModel.enabled
            item.representedObject = ToolbarMenuItemPayload(
                itemId: itemId,
                menuItemId: menuItemModel.id,
                menuItemTitle: menuItemModel.title,
                menuItemTag: menuItemModel.tag)
            menu.addItem(item)
        }

        menu.popUp(positioning: nil, at: NSPoint(x: bounds.maxX - 8, y: -4), in: self)
    }

    @objc
    private func onMenuItemSelected(_ sender: NSMenuItem) {
        guard let payload = sender.representedObject as? ToolbarMenuItemPayload else {
            return
        }

        var arguments: [String: Any] = [
            "id": payload.itemId,
            "type": "comboButtonItemSelected",
            "menuItemId": payload.menuItemId,
            "menuItemTitle": payload.menuItemTitle,
        ]
        if let tag = payload.menuItemTag {
            arguments["menuItemTag"] = tag
        }
        eventsChannel.invokeMethod("onToolbarEvent", arguments: arguments)
    }
}

private final class ToolbarMenuItemPayload: NSObject {
    let itemId: String
    let menuItemId: String
    let menuItemTitle: String
    let menuItemTag: Int?

    init(itemId: String, menuItemId: String, menuItemTitle: String, menuItemTag: Int?) {
        self.itemId = itemId
        self.menuItemId = menuItemId
        self.menuItemTitle = menuItemTitle
        self.menuItemTag = menuItemTag
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

// MARK: - Models

enum CNToolbarItemKind: String {
    case button
    case picker
    case toggle
}

enum CNToolbarItemPlacement: String {
    case automatic
    case principal
    case navigation
    case status
    case confirmationAction
    case destructiveAction
    case cancellationAction
}

struct CNToolbarItemModel {
    let id: String
    let kind: String // "button", "picker", "toggle" or "group"
    let label: String?
    let placement: CNToolbarItemPlacement
    let systemSymbolName: String?
    let disabled: Bool
    let tint: NSColor?
    let buttonStyle: String?
    let children: [CNToolbarItemModel]? // For group items
    let items: [String]? // For picker items (list of options)
    let selectedValue: String? // For picker items (currently selected value)
    let pickerStyle: String? // For picker items (menu, segmented, etc.)
    let isOn: Bool? // For toggle items (current state)
    let toggleStyle: String? // For toggle items (switch, button, automatic)
}

extension CNToolbarItemModel: Equatable {
    static func == (lhs: CNToolbarItemModel, rhs: CNToolbarItemModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.selectedValue == rhs.selectedValue &&
            lhs.isOn == rhs.isOn
    }
}

// MARK: - Manager

final class CNToolbarManager: NSObject, FlutterStreamHandler {
    private var hostingViews: [Int: NSHostingView<CNToolbarView>] = [:]
    private var eventSink: FlutterEventSink?
    private let eventsChannel: FlutterEventChannel

    init(messenger: FlutterBinaryMessenger) {
        print("Initializing CNToolbarManager")
        let eventChannel = FlutterEventChannel(
            name: "cupertino_native/toolbar_events",
            binaryMessenger: messenger
        )
        eventsChannel = eventChannel
        super.init()
        eventChannel.setStreamHandler(self)
    }

    func makeToolbar(window: NSWindow, args: [String: Any], result: @escaping FlutterResult) {
        print("Making toolbar with args: \(args)")
        let title = (args["title"] as? String) ?? "Toolbar"
        let items = parseToolbarItems(args["items"])
        let showSearch = (args["showSearch"] as? Bool) ?? false

        DispatchQueue.main.async {
            let toolbarView = CNToolbarView(
                title: title,
                items: items,
                showSearch: showSearch,
                onEvent: { [weak self] event in
                    self?.sendEvent(event)
                }
            )

            let hostingView = NSHostingView(rootView: toolbarView)
            hostingView.sceneBridgingOptions = [.toolbars]
            hostingView.autoresizingMask = []

            if let existingHostingView = self.hostingViews[window.windowNumber] {
                existingHostingView.removeFromSuperview()
            }

            window.contentView?.addSubview(hostingView)
            self.hostingViews[window.windowNumber] = hostingView

            print("Toolbar added to window \(window.windowNumber)")
            result(nil)
        }
    }

    func clearToolbar(window: NSWindow, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            self.hostingViews.removeValue(forKey: window.windowNumber)
            window.contentView?.subviews.forEach { subview in
                if let hostingView = subview as? NSHostingView<CNToolbarView> {
                    hostingView.removeFromSuperview()
                }
            }
            result(nil)
        }
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments _: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    func sendEvent(_ data: [String: Any]) {
        print("Sending event: \(data)")
        DispatchQueue.main.async {
            self.eventSink?(data)
        }
    }

    // MARK: - Parsing

    private func parseToolbarItems(_ raw: Any?) -> [CNToolbarItemModel] {
        guard let list = raw as? [Any] else {
            return []
        }

        var parsed: [CNToolbarItemModel] = []
        for item in list {
            guard let dict = item as? [String: Any] else { continue }

            guard let id = dict["id"] as? String, !id.isEmpty else { continue }

            let kind = (dict["kind"] as? String) ?? "button"
            let placementRaw = (dict["placement"] as? String) ?? "automatic"
            let placement = CNToolbarItemPlacement(rawValue: placementRaw) ?? .automatic
            let disabled = (dict["disabled"] as? Bool) ?? false

            var tint: NSColor? = nil
            if let tintInt = dict["tint"] as? Int {
                tint = ColorUtils.colorFromARGB(tintInt)
            }

            if kind == "group" {
                // Parse group with children
                let groupChildren = parseToolbarItems(dict["items"])
                parsed.append(CNToolbarItemModel(
                    id: id,
                    kind: "group",
                    label: nil,
                    placement: placement,
                    systemSymbolName: nil,
                    disabled: disabled,
                    tint: tint,
                    buttonStyle: nil,
                    children: groupChildren,
                    items: nil,
                    selectedValue: nil,
                    pickerStyle: nil,
                    isOn: nil,
                    toggleStyle: nil
                ))
            } else if kind == "picker" {
                // Parse picker item
                let label = (dict["label"] as? String) ?? ""
                let items = (dict["items"] as? [String]) ?? []
                let selectedValue = dict["selectedValue"] as? String
                let pickerStyle = (dict["pickerStyle"] as? String) ?? "menu"

                parsed.append(CNToolbarItemModel(
                    id: id,
                    kind: "picker",
                    label: label,
                    placement: placement,
                    systemSymbolName: nil,
                    disabled: disabled,
                    tint: tint,
                    buttonStyle: nil,
                    children: nil,
                    items: items,
                    selectedValue: selectedValue,
                    pickerStyle: pickerStyle,
                    isOn: nil,
                    toggleStyle: nil
                ))
            } else if kind == "toggle" {
                // Parse toggle item
                let label = (dict["label"] as? String) ?? ""
                let symbol = dict["systemSymbolName"] as? String
                let isOn = (dict["isOn"] as? Bool) ?? false
                let toggleStyle = (dict["toggleStyle"] as? String) ?? "switch"

                parsed.append(CNToolbarItemModel(
                    id: id,
                    kind: "toggle",
                    label: label,
                    placement: placement,
                    systemSymbolName: symbol,
                    disabled: disabled,
                    tint: tint,
                    buttonStyle: nil,
                    children: nil,
                    items: nil,
                    selectedValue: nil,
                    pickerStyle: nil,
                    isOn: isOn,
                    toggleStyle: toggleStyle
                ))
            } else {
                // Parse button item
                let label = (dict["label"] as? String) ?? ""
                let symbol = dict["systemSymbolName"] as? String
                let buttonStyle = dict["buttonStyle"] as? String

                parsed.append(CNToolbarItemModel(
                    id: id,
                    kind: "button",
                    label: label,
                    placement: placement,
                    systemSymbolName: symbol,
                    disabled: disabled,
                    tint: tint,
                    buttonStyle: buttonStyle,
                    children: nil,
                    items: nil,
                    selectedValue: nil,
                    pickerStyle: nil,
                    isOn: nil,
                    toggleStyle: nil
                ))
            }
        }
        return parsed
    }
}

// MARK: - SwiftUI View

struct DynamicToolbarContent: ToolbarContent {
    let items: [CNToolbarItemModel]
    let onEvent: ([String: Any]) -> Void
    let mapPlacement: (CNToolbarItemPlacement) -> ToolbarItemPlacement
    let getTintColor: (CNToolbarItemModel) -> Color?
    let getButtonStyle: (CNToolbarItemModel) -> String
    @Binding var pickerValues: [String: String]
    @Binding var toggleValues: [String: Bool]

    /// Groups items by their placement
    /// Returns: [placement: [group_id: [children]]]
    private var groupsByPlacement: [CNToolbarItemPlacement: [CNToolbarItemModel]] {
        var grouped: [CNToolbarItemPlacement: [CNToolbarItemModel]] = [:]

        for item in items {
            if item.kind == "group" {
                if grouped[item.placement] == nil {
                    grouped[item.placement] = []
                }
                grouped[item.placement]?.append(item)
            }
        }

        return grouped
    }

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        let grouped = groupsByPlacement
        let placements = Array(grouped.keys).sorted { $0.rawValue < $1.rawValue }

        // Unroll placements (max 8 - covers all macOS toolbar placement types)
        if placements.count > 0 {
            renderPlacementAt(0, grouped: grouped, placements: placements)
        }
        if placements.count > 1 {
            renderPlacementAt(1, grouped: grouped, placements: placements)
        }
        if placements.count > 2 {
            renderPlacementAt(2, grouped: grouped, placements: placements)
        }
        if placements.count > 3 {
            renderPlacementAt(3, grouped: grouped, placements: placements)
        }
        if placements.count > 4 {
            renderPlacementAt(4, grouped: grouped, placements: placements)
        }
        if placements.count > 5 {
            renderPlacementAt(5, grouped: grouped, placements: placements)
        }
        if placements.count > 6 {
            renderPlacementAt(6, grouped: grouped, placements: placements)
        }
        if placements.count > 7 {
            renderPlacementAt(7, grouped: grouped, placements: placements)
        }
    }

    @ToolbarContentBuilder
    private func renderPlacementAt(_ index: Int, grouped: [CNToolbarItemPlacement: [CNToolbarItemModel]], placements: [CNToolbarItemPlacement]) -> some ToolbarContent {
        if index < placements.count {
            let placement = placements[index]
            let groupsForPlacement = grouped[placement] ?? []

            // Unroll groups for this placement (max 10 groups per placement)
            if groupsForPlacement.count > 0 {
                renderGroupAt(0, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 1 {
                renderGroupAt(1, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 2 {
                renderGroupAt(2, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 3 {
                renderGroupAt(3, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 4 {
                renderGroupAt(4, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 5 {
                renderGroupAt(5, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 6 {
                renderGroupAt(6, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 7 {
                renderGroupAt(7, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 8 {
                renderGroupAt(8, placement: placement, groups: groupsForPlacement)
            }
            if groupsForPlacement.count > 9 {
                renderGroupAt(9, placement: placement, groups: groupsForPlacement)
            }
        }
    }

    @ToolbarContentBuilder
    private func renderGroupAt(_ index: Int, placement: CNToolbarItemPlacement, groups: [CNToolbarItemModel]) -> some ToolbarContent {
        if index < groups.count {
            let group = groups[index]
            if let children = group.children, !children.isEmpty {
                ToolbarItemGroup(placement: mapPlacement(placement)) {
                    ForEach(children, id: \.id) { child in
                        if child.kind == "picker" {
                            buildPickerMenu(for: child, options: child.items ?? [])
                        } else if child.kind == "toggle" {
                            buildToggleControl(for: child)
                        } else {
                            buildButton(for: child)
                        }
                    }
                }
            }
        }
    }

    private func buildButton(for item: CNToolbarItemModel) -> some View {
        // Handle button items
        let baseButton = Button(action: {
            onEvent(["id": item.id, "type": "buttonPressed"])
        }) {
            if let symbol = item.systemSymbolName, let label = item.label, !label.isEmpty {
                Label(label, systemImage: symbol)
                    .labelStyle(.titleAndIcon)
            } else if let symbol = item.systemSymbolName {
                Image(systemName: symbol)
            } else if let label = item.label, !label.isEmpty {
                Text(label)
            }
        }
        .disabled(item.disabled)
        .foregroundColor(getTintColor(item))

        let style = getButtonStyle(item)
        switch style {
        case "bordered":
            return AnyView(baseButton.buttonStyle(.bordered))
        case "plain":
            return AnyView(baseButton.buttonStyle(.plain))
        case "borderless":
            return AnyView(baseButton.buttonStyle(.borderless))
        case "link":
            return AnyView(baseButton.buttonStyle(.link))
        case "automatic":
            return AnyView(baseButton.buttonStyle(.automatic))
        case "borderedProminent":
            return AnyView(baseButton.buttonStyle(.borderedProminent))
        case "glass":
            return AnyView(baseButton.buttonStyle(.glass))
        case "glassProminent":
            return AnyView(baseButton.buttonStyle(.glassProminent))
        default:
            return AnyView(baseButton)
        }
    }

    private func buildPickerMenu(for item: CNToolbarItemModel, options: [String]) -> some View {
        // Get initial selected value
        let initialValue = item.selectedValue ?? (options.first ?? "")

        // Use binding to pickerValues for state management
        let picker = Picker(item.label ?? "Select", selection: Binding<String>(
            get: { pickerValues[item.id] ?? initialValue },
            set: { newValue in
                pickerValues[item.id] = newValue
                onEvent(["id": item.id, "type": "pickerChanged", "value": newValue])
            }
        )) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .disabled(item.disabled)
        .foregroundColor(getTintColor(item))

        // Apply picker style based on configuration
        let style = item.pickerStyle ?? "menu"
        switch style {
        case "segmented":
            return AnyView(picker.pickerStyle(.segmented))
        case "radioGroup":
            return AnyView(picker.pickerStyle(.radioGroup))
        case "inline":
            return AnyView(picker.pickerStyle(.inline))
        case "menu":
            fallthrough
        default:
            return AnyView(picker.pickerStyle(.menu))
        }
    }

    private func buildToggleControl(for item: CNToolbarItemModel) -> some View {
        // Get initial toggle state
        let initialState = item.isOn ?? false

        // Use binding to toggleValues for state management
        let toggle = Toggle(isOn: Binding<Bool>(
            get: { toggleValues[item.id] ?? initialState },
            set: { newValue in
                toggleValues[item.id] = newValue
                onEvent(["id": item.id, "type": "toggleChanged", "value": newValue])
            }
        )) {
            if let symbol = item.systemSymbolName, let label = item.label, !label.isEmpty {
                Label(label, systemImage: symbol)
                    .labelStyle(.titleAndIcon)
            } else if let symbol = item.systemSymbolName {
                Label("", systemImage: symbol)
            } else if let label = item.label, !label.isEmpty {
                Text(label)
            }
        }
        .disabled(item.disabled)
        .foregroundColor(getTintColor(item))

        // Apply toggle style based on configuration
        let style = item.toggleStyle ?? "switch"
        switch style {
        case "button":
            return AnyView(toggle.toggleStyle(.button))
        case "switch":
            fallthrough
        default:
            return AnyView(toggle.toggleStyle(.switch))
        }
    }
}

struct CNToolbarView: View {
    let title: String
    let items: [CNToolbarItemModel]
    let showSearch: Bool
    let onEvent: ([String: Any]) -> Void

    @State private var searchText = ""
    @State private var pickerValues: [String: String] = [:]
    @State private var toggleValues: [String: Bool] = [:]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
            }
        }
        .toolbar(content: buildToolbarContent)
        .searchable(
            text: $searchText,
            isPresented: .constant(showSearch),
            prompt: "Search"
        )
        .onChange(of: searchText) { _, newValue in
            onEvent([
                "type": "searchChanged",
                "query": newValue,
            ])
        }
        .onSubmit(of: .search) {
            onEvent([
                "type": "searchSubmitted",
                "query": searchText,
            ])
        }
        .onAppear {
            initializePickerValues()
        }
        .onChange(of: items) { _, _ in
            initializePickerValues()
        }
    }

    private func initializePickerValues() {
        // Initialize pickerValues with selectedValue from all pickers and toggleValues from all toggles
        var pickerVals: [String: String] = [:]
        var toggleVals: [String: Bool] = [:]

        func extractValues(from itemList: [CNToolbarItemModel]) {
            for item in itemList {
                if item.kind == "picker", let selectedValue = item.selectedValue {
                    pickerVals[item.id] = selectedValue
                } else if item.kind == "toggle", let isOn = item.isOn {
                    toggleVals[item.id] = isOn
                } else if item.kind == "group", let children = item.children {
                    extractValues(from: children)
                }
            }
        }

        extractValues(from: items)
        pickerValues = pickerVals
        toggleValues = toggleVals
    }

    private func buildToolbarContent() -> some ToolbarContent {
        DynamicToolbarContent(
            items: items,
            onEvent: onEvent,
            mapPlacement: mapPlacement,
            getTintColor: getTintColor,
            getButtonStyle: { item in item.buttonStyle ?? "automatic" },
            pickerValues: $pickerValues,
            toggleValues: $toggleValues
        )
    }

    private func buildButton(for item: CNToolbarItemModel) -> some View {
        let baseButton = Button(action: {
            onEvent(["id": item.id, "type": "buttonPressed"])
        }) {
            // if has both image and label
            if let symbol = item.systemSymbolName, let label = item.label, !label.isEmpty {
                Label(label, systemImage: symbol)
                    .labelStyle(.titleAndIcon)
            } else if let symbol = item.systemSymbolName {
                Image(systemName: symbol)
            } else if let label = item.label, !label.isEmpty {
                Text(label)
            }
        }
        .disabled(item.disabled)
        .foregroundColor(getTintColor(for: item))

        switch item.buttonStyle {
        case "bordered":
            return AnyView(baseButton.buttonStyle(.bordered))
        case "plain":
            return AnyView(baseButton.buttonStyle(.plain))
        case "borderless":
            return AnyView(baseButton.buttonStyle(.borderless))
        case "link":
            return AnyView(baseButton.buttonStyle(.link))
        case "automatic":
            return AnyView(baseButton.buttonStyle(.automatic))
        case "borderedProminent":
            return AnyView(baseButton.buttonStyle(.borderedProminent))
        case "glass":
            return AnyView(baseButton.buttonStyle(.glass))
        case "glassProminent":
            return AnyView(baseButton.buttonStyle(.glassProminent))
        default:
            return AnyView(baseButton)
        }
    }

    private func getTintColor(for item: CNToolbarItemModel) -> Color? {
        if let tintColor = item.tint {
            return Color(nsColor: tintColor)
        }
        return nil
    }

    private func mapPlacement(_ placement: CNToolbarItemPlacement) -> ToolbarItemPlacement {
        switch placement {
        case .automatic:
            return .automatic
        case .principal:
            return .principal
        case .navigation:
            return .navigation
        case .status:
            return .status
        case .confirmationAction:
            return .confirmationAction
        case .destructiveAction:
            return .destructiveAction
        case .cancellationAction:
            return .cancellationAction
        }
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

final class CNToolbarHandler: NSObject {
    private weak var registrar: FlutterPluginRegistrar?
    private var channel: FlutterMethodChannel?
    private var hostingView: NSHostingView<CNToolbarView>?

    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel) {
        self.registrar = registrar
        self.channel = channel
        super.init()
    }

    func makeToolbar(args: [String: Any], result: @escaping FlutterResult) {
        guard let window = registrar?.view?.window,
              let contentView = window.contentView
        else {
            result(FlutterError(code: "window_unavailable", message: "No window available", details: nil))
            return
        }

        let titlePayload = args["title"] as? [String: Any]
        let titleDisplayMode = args["titleDisplayMode"] as? String ?? "automatic"
        let groups = args["groups"] as? [[String: Any]] ?? []
        let searchable = args["searchable"] as? Bool ?? false
        let toolbarBackground = args["toolbarBackground"] as? Int

        let toolbarView = CNToolbarView(
            titlePayload: titlePayload,
            titleDisplayMode: titleDisplayMode,
            groups: groups,
            searchable: searchable,
            onItemPressed: { [weak self] tag in
                self?.channel?.invokeMethod("toolbarItemPressed", arguments: tag)
            },
            onSearchChanged: { [weak self] query in
                self?.channel?.invokeMethod("toolbarSearchChanged", arguments: query)
            },
        )

        if let existing = hostingView {
            existing.removeFromSuperview()
        }

        let hosting = NSHostingView(rootView: toolbarView)
        hosting.sceneBridgingOptions = [.toolbars]
        hosting.frame = .zero
        hosting.autoresizingMask = []
        contentView.addSubview(hosting)

        // Apply toolbar background via AppKit
        if let toolbarBackground {
            window.titlebarAppearsTransparent = true
            window.backgroundColor = ColorUtils.colorFromARGB(toolbarBackground)
        } else {
            window.titlebarAppearsTransparent = false
            window.backgroundColor = .windowBackgroundColor
        }

        hostingView = hosting
        result(nil)
    }

    func clearToolbar(result: @escaping FlutterResult) {
        hostingView?.removeFromSuperview()
        hostingView = nil
        result(nil)
    }
}

// MARK: - SwiftUI Toolbar View

private struct CNToolbarView: View {
    let titlePayload: [String: Any]?
    let titleDisplayMode: String
    let groups: [[String: Any]]
    let searchable: Bool
    let onItemPressed: (String) -> Void
    let onSearchChanged: (String) -> Void

    @State private var searchText = ""

    private var titleText: String {
        guard let payload = titlePayload else { return "" }
        return payload["text"] as? String
            ?? payload["title"] as? String
            ?? ""
    }

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .toolbar {
                CNDynamicToolbarContent(
                    groups: groups,
                    onItemPressed: onItemPressed,
                )
            }
            .navigationTitle(titleText)
            .modifier(TitleDisplayModeModifier(mode: titleDisplayMode))
            .modifier(SearchableModifier(
                isSearchable: searchable,
                searchText: $searchText,
                onSearchChanged: onSearchChanged,
            ))
    }
}

// MARK: - Dynamic Toolbar Content

private struct CNDynamicToolbarContent: ToolbarContent {
    let groups: [[String: Any]]
    let onItemPressed: (String) -> Void

    private struct FlatGroup {
        let id: Int
        let placement: ToolbarItemPlacement
        let children: [[String: Any]]
    }

    private var flatGroups: [FlatGroup] {
        groups.enumerated().map { index, group in
            let placementStr = group["placement"] as? String ?? "automatic"
            let placement = mapPlacement(placementStr)
            let children = group["children"] as? [[String: Any]] ?? []
            return FlatGroup(id: index, placement: placement, children: children)
        }
    }

    @ToolbarContentBuilder
    var body: some ToolbarContent {
        let resolved = flatGroups
        // Unroll up to 10 groups to avoid type-checker complexity
        if resolved.count > 0 {
            renderGroup(resolved[0])
        }
        if resolved.count > 1 {
            renderGroup(resolved[1])
        }
        if resolved.count > 2 {
            renderGroup(resolved[2])
        }
        if resolved.count > 3 {
            renderGroup(resolved[3])
        }
        if resolved.count > 4 {
            renderGroup(resolved[4])
        }
        if resolved.count > 5 {
            renderGroup(resolved[5])
        }
        if resolved.count > 6 {
            renderGroup(resolved[6])
        }
        if resolved.count > 7 {
            renderGroup(resolved[7])
        }
        if resolved.count > 8 {
            renderGroup(resolved[8])
        }
        if resolved.count > 9 {
            renderGroup(resolved[9])
        }
    }

    @ToolbarContentBuilder
    private func renderGroup(_ group: FlatGroup) -> some ToolbarContent {
        ToolbarItemGroup(placement: group.placement) {
            ForEach(Array(group.children.enumerated()), id: \.offset) { _, child in
                CNToolbarChildBuilder.buildChild(child, onItemPressed: onItemPressed)
            }
        }
    }

    private func mapPlacement(_ value: String) -> ToolbarItemPlacement {
        switch value {
        case "principal": .principal
        case "navigation": .navigation
        case "status": .status
        case "primaryAction": .primaryAction
        case "secondaryAction": .secondaryAction
        case "confirmationAction": .confirmationAction
        case "destructiveAction": .destructiveAction
        case "cancellationAction": .cancellationAction
        default: .automatic
        }
    }
}

// MARK: - View Modifiers

private struct TitleDisplayModeModifier: ViewModifier {
    let mode: String

    func body(content: Content) -> some View {
        switch mode {
        case "inline":
            content.toolbarTitleDisplayMode(.inline)
        default:
            content.toolbarTitleDisplayMode(.automatic)
        }
    }
}

private struct SearchableModifier: ViewModifier {
    let isSearchable: Bool
    @Binding var searchText: String
    let onSearchChanged: (String) -> Void

    func body(content: Content) -> some View {
        if isSearchable {
            content
                .searchable(text: $searchText, prompt: "Search")
                .onChange(of: searchText) { _, newValue in
                    onSearchChanged(newValue)
                }
        } else {
            content
        }
    }
}

// MARK: - Child Builder

private enum CNToolbarChildBuilder {
    static func buildChild(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let type = dict["type"] as? String ?? ""
        switch type {
        case "button":
            return buildButton(dict, onItemPressed: onItemPressed)
        case "hstack":
            return buildHStack(dict, onItemPressed: onItemPressed)
        case "vstack":
            return buildVStack(dict, onItemPressed: onItemPressed)
        case "menu":
            return buildMenu(dict, onItemPressed: onItemPressed)
        case "picker":
            return buildPicker(dict, onItemPressed: onItemPressed)
        case "toggle":
            return buildToggle(dict, onItemPressed: onItemPressed)
        case "textField":
            return buildTextField(dict, onItemPressed: onItemPressed)
        default:
            return CNChildViewBuilder.buildChild(dict)
        }
    }

    private static func buildButton(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let title = dict["title"] as? String ?? ""
        let tag = dict["tag"] as? String ?? ""
        let systemImage = dict["systemImage"] as? String
        let enabled = dict["enabled"] as? Bool ?? true
        let buttonStyle = dict["buttonStyle"] as? String
        let labelStyle = dict["labelStyle"] as? String

        var view = AnyView(
            Button {
                onItemPressed(tag)
            } label: {
                if let systemImage, !systemImage.isEmpty {
                    if title.isEmpty {
                        Image(systemName: systemImage)
                    } else {
                        Label(title, systemImage: systemImage)
                    }
                } else {
                    Text(title)
                }
            }
            .disabled(!enabled),
        )

        if let labelStyle {
            view = applyLabelStyle(labelStyle, to: view)
        }

        if let buttonStyle {
            view = applyButtonStyle(buttonStyle, to: view)
        }

        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        view = CNViewModifierApplicator.applyTint(dict["tint"], to: view)
        view = CNViewModifierApplicator.applyControlSize(dict["controlSize"] as? String, to: view)

        return view
    }

    private static func buildHStack(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let items = dict["children"] as? [[String: Any]] ?? []
        let spacing = dict["spacing"] as? CGFloat
        return AnyView(
            HStack(spacing: spacing ?? 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, child in
                    buildChild(child, onItemPressed: onItemPressed)
                }
            },
        )
    }

    private static func buildVStack(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let items = dict["children"] as? [[String: Any]] ?? []
        let spacing = dict["spacing"] as? CGFloat
        return AnyView(
            VStack(spacing: spacing ?? 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, child in
                    buildChild(child, onItemPressed: onItemPressed)
                }
            },
        )
    }

    private static func buildMenu(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let items = dict["items"] as? [[String: Any]] ?? []
        let labelList = dict["label"] as? [[String: Any]] ?? []

        return AnyView(
            Menu {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    let itemType = item["type"] as? String ?? ""
                    if itemType == "button" {
                        let itemTitle = item["title"] as? String ?? ""
                        let itemTag = item["tag"] as? String ?? ""
                        let itemSystemImage = item["systemImage"] as? String
                        Button {
                            onItemPressed(itemTag)
                        } label: {
                            if let itemSystemImage, !itemSystemImage.isEmpty {
                                Label(itemTitle, systemImage: itemSystemImage)
                            } else {
                                Text(itemTitle)
                            }
                        }
                    } else if itemType == "divider" {
                        Divider()
                    }
                }
            } label: {
                if let firstLabel = labelList.first {
                    CNChildViewBuilder.buildChild(firstLabel)
                } else {
                    Text("Menu")
                }
            },
        )
    }

    private static func buildPicker(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let tag = dict["tag"] as? String ?? ""
        let children = dict["children"] as? [[String: Any]] ?? []
        let selection = dict["selection"] as? String ?? ""
        let labelList = dict["label"] as? [[String: Any]]
        let pickerStyle = dict["pickerStyle"] as? String ?? "menu"
        let labelStyle = dict["labelStyle"] as? String

        let pickerView = CNToolbarPickerView(
            tag: tag,
            children: children,
            initialSelection: selection,
            labelList: labelList,
            pickerStyle: pickerStyle,
            labelStyle: labelStyle,
            onChanged: { newValue in
                onItemPressed("\(tag):\(newValue)")
            },
        )

        var view = AnyView(pickerView)
        view = CNViewModifierApplicator.applyControlSize(dict["controlSize"] as? String, to: view)
        view = CNViewModifierApplicator.applyTint(dict["tint"], to: view)
        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        return view
    }

    private static func buildToggle(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let tag = dict["tag"] as? String ?? ""
        let isOn = dict["isOn"] as? Bool ?? false
        let label = dict["label"] as? String
        let systemImage = dict["systemImage"] as? String
        let toggleStyle = dict["toggleStyle"] as? String ?? "switch"

        let toggleView = CNToolbarToggleView(
            tag: tag,
            initialValue: isOn,
            label: label,
            systemImage: systemImage,
            toggleStyle: toggleStyle,
            onChanged: { newValue in
                onItemPressed("\(tag):\(newValue)")
            },
        )

        var view = AnyView(toggleView)
        view = CNViewModifierApplicator.applyControlSize(dict["controlSize"] as? String, to: view)
        view = CNViewModifierApplicator.applyTint(dict["tint"], to: view)
        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        return view
    }

    private static func buildTextField(_ dict: [String: Any], onItemPressed: @escaping (String) -> Void) -> AnyView {
        let tag = dict["tag"] as? String ?? ""
        let text = dict["text"] as? String ?? ""
        let placeholder = dict["placeholder"] as? String ?? ""

        let textFieldView = CNToolbarTextFieldView(
            tag: tag,
            initialText: text,
            placeholder: placeholder,
            onChanged: { newValue in
                onItemPressed("\(tag):\(newValue)")
            },
        )

        var view = AnyView(textFieldView)
        view = CNViewModifierApplicator.applyControlSize(dict["controlSize"] as? String, to: view)
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        return view
    }

    private static func applyButtonStyle(_ style: String, to view: AnyView) -> AnyView {
        switch style {
        case "bordered":
            return AnyView(view.buttonStyle(.bordered))
        case "borderedProminent":
            return AnyView(view.buttonStyle(.borderedProminent))
        case "plain":
            return AnyView(view.buttonStyle(.plain))
        case "borderless":
            return AnyView(view.buttonStyle(.borderless))
        case "link":
            return AnyView(view.buttonStyle(.link))
        case "glass":
            if #available(macOS 26.0, *) {
                return AnyView(view.buttonStyle(.glass))
            }
            return view
        case "glassProminent":
            if #available(macOS 26.0, *) {
                return AnyView(view.buttonStyle(.glassProminent))
            }
            return view
        default:
            return view
        }
    }

    private static func applyLabelStyle(_ style: String, to view: AnyView) -> AnyView {
        switch style {
        case "titleOnly":
            AnyView(view.labelStyle(.titleOnly))
        case "iconOnly":
            AnyView(view.labelStyle(.iconOnly))
        case "titleAndIcon":
            AnyView(view.labelStyle(.titleAndIcon))
        default:
            view
        }
    }
}

// MARK: - Stateful Toolbar Child Views

private struct CNToolbarPickerView: View {
    let tag: String
    let children: [[String: Any]]
    let initialSelection: String
    let labelList: [[String: Any]]?
    let pickerStyle: String
    let labelStyle: String?
    let onChanged: (String) -> Void

    @State private var selection: String

    init(tag: String, children: [[String: Any]], initialSelection: String, labelList: [[String: Any]]?, pickerStyle: String, labelStyle: String?, onChanged: @escaping (String) -> Void) {
        self.tag = tag
        self.children = children
        self.initialSelection = initialSelection
        self.labelList = labelList
        self.pickerStyle = pickerStyle
        self.labelStyle = labelStyle
        self.onChanged = onChanged
        _selection = State(initialValue: initialSelection)
    }

    var body: some View {
        var view = AnyView(
            Picker(selection: $selection) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    let childTag = child["tag"] as? String ?? ""
                    CNChildViewBuilder.buildChild(child).tag(childTag)
                }
            } label: {
                if let labelList, let first = labelList.first {
                    CNChildViewBuilder.buildChild(first)
                } else {
                    EmptyView()
                }
            }
            .onChange(of: selection) { _, newValue in
                onChanged(newValue)
            },
        )

        if let labelStyle {
            switch labelStyle {
            case "titleOnly":
                view = AnyView(view.labelStyle(.titleOnly))
            case "iconOnly":
                view = AnyView(view.labelStyle(.iconOnly))
            case "titleAndIcon":
                view = AnyView(view.labelStyle(.titleAndIcon))
            default:
                break
            }
        }

        switch pickerStyle {
        case "segmented":
            return AnyView(view.pickerStyle(.segmented))
        case "radioGroup":
            return AnyView(view.pickerStyle(.radioGroup))
        case "inline":
            return AnyView(view.pickerStyle(.inline))
        case "palette":
            return AnyView(view.pickerStyle(.palette))
        default:
            return AnyView(view.pickerStyle(.menu))
        }
    }
}

private struct CNToolbarToggleView: View {
    let tag: String
    let initialValue: Bool
    let label: String?
    let systemImage: String?
    let toggleStyle: String
    let onChanged: (Bool) -> Void

    @State private var isOn: Bool

    init(tag: String, initialValue: Bool, label: String?, systemImage: String?, toggleStyle: String, onChanged: @escaping (Bool) -> Void) {
        self.tag = tag
        self.initialValue = initialValue
        self.label = label
        self.systemImage = systemImage
        self.toggleStyle = toggleStyle
        self.onChanged = onChanged
        _isOn = State(initialValue: initialValue)
    }

    var body: some View {
        let toggle = Toggle(isOn: $isOn) {
            if let systemImage, !systemImage.isEmpty, let label, !label.isEmpty {
                Label(label, systemImage: systemImage)
            } else if let systemImage, !systemImage.isEmpty {
                Image(systemName: systemImage)
            } else if let label, !label.isEmpty {
                Text(label)
            }
        }
        .onChange(of: isOn) { _, newValue in
            onChanged(newValue)
        }

        switch toggleStyle {
        case "button":
            AnyView(toggle.toggleStyle(.button))
        case "checkbox":
            AnyView(toggle.toggleStyle(.checkbox))
        default:
            AnyView(toggle.toggleStyle(.switch))
        }
    }
}

private struct CNToolbarTextFieldView: View {
    let tag: String
    let initialText: String
    let placeholder: String
    let onChanged: (String) -> Void

    @State private var text: String

    init(tag: String, initialText: String, placeholder: String, onChanged: @escaping (String) -> Void) {
        self.tag = tag
        self.initialText = initialText
        self.placeholder = placeholder
        self.onChanged = onChanged
        _text = State(initialValue: initialText)
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .onChange(of: text) { _, newValue in
                onChanged(newValue)
            }
            .frame(minWidth: 100)
    }
}

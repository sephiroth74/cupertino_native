import Cocoa
import FlutterMacOS
import SwiftUI

struct CNMenuItemModel {
    let separator: Bool
    let title: String
    let subtitle: String?
    let image: [String: Any]?
    let tag: Int?
    let identifier: String
    let enabled: Bool
    let state: String
    let submenu: [CNMenuItemModel]?
}

extension CNMenuItemModel: CNChannelSerializable {
    init?(channel: [String: Any]) {
        let separator = (channel["separator"] as? Bool) ?? false
        let title = (channel["title"] as? String) ?? ""
        let subtitle = channel["subtitle"] as? String
        let image = channel["image"] as? [String: Any]
        let tag = channel["tag"] as? Int
        let identifier = (channel["identifier"] as? String) ?? UUID().uuidString
        let enabled = (channel["enabled"] as? Bool) ?? true
        let state = (channel["state"] as? String) ?? "off"
        let submenu: [CNMenuItemModel]?
        let decodedSubmenu: [CNMenuItemModel] = CNChannelSerialization.decodeArray(channel["submenu"])
        submenu = decodedSubmenu.isEmpty ? nil : decodedSubmenu

        self.init(
            separator: separator,
            title: title,
            subtitle: subtitle,
            image: image,
            tag: tag,
            identifier: identifier,
            enabled: enabled,
            state: state,
            submenu: submenu
        )
    }

    func toChannel() -> [String: Any] {
        var channel: [String: Any] = [
            "separator": separator,
            "title": title,
            "identifier": identifier,
            "enabled": enabled,
            "state": state,
        ]
        channel["subtitle"] = subtitle
        channel["image"] = image
        channel["tag"] = tag
        channel["submenu"] = submenu.map(CNChannelSerialization.encodeArray)
        return channel
    }
}

func parseCNMenuItems(_ rawMenu: Any?) -> [CNMenuItemModel] {
    guard let menuDict = CNChannelSerialization.asDict(rawMenu) else {
        return []
    }
    return CNChannelSerialization.decodeArray(menuDict["items"])
}

class CupertinoMenuButtonNSView: NSView {
    override var intrinsicContentSize: NSSize {
        if let measuredSize {
            return measuredSize
        }
        return hostingView?.intrinsicContentSize
            ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    private let channel: FlutterMethodChannel
    private var hostingView: NSHostingView<MenuButtonContent>?
    private var measuredSize: NSSize?
    private var args: [String: Any]

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeMenuButton_\(viewId)",
            binaryMessenger: messenger
        )
        self.args = CNChannelSerialization.asDict(args) ?? [:]
        super.init(frame: .zero)

        let isDark = (self.args["isDark"] as? NSNumber)?.boolValue ?? false

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        createHostingView()
        setupMethodCallHandler()

        appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    private func createHostingView() {
        hostingView?.removeFromSuperview()
        let content = MenuButtonContent(
            model: parseArguments(args),
            onSelection: { [weak self] identifier in
                self?.channel.invokeMethod("itemSelected", arguments: ["identifier": identifier])
            },
            onSizeChanged: { [weak self] size in
                guard let self else { return }
                self.measuredSize = NSSize(width: size.width, height: size.height)
                self.invalidateIntrinsicContentSize()
            }
        )
        let hosting = NSHostingView(rootView: content)
        hosting.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: trailingAnchor),
            hosting.topAnchor.constraint(equalTo: topAnchor),
            hosting.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        hostingView = hosting
    }

    private func setupMethodCallHandler() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }

            print("Received method call: \(call.method) with arguments: \(String(describing: call.arguments))")

            switch call.method {
            case "getIntrinsicSize":
                let size = self.hostingView?.intrinsicContentSize ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setMenu":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.args["menu"] = args["menu"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing menu", details: nil))
                }
            case "setIsDark":
                if let args = CNChannelSerialization.asDict(call.arguments), let isDark = (args["value"] as? NSNumber)?.boolValue {
                    self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }
            case "setLabel":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.args["label"] = args["label"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing label", details: nil))
                }
            case "setImage":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.args["image"] = args["image"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing image", details: nil))
                }
            case "setStyle":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.args["style"] = args["style"] ?? args["menuStyle"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }
            case "setControlSize":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    self.args["controlSize"] = args["controlSize"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil))
                }
            case "setFocusable":
                if let args = CNChannelSerialization.asDict(call.arguments), let focusable = (args["focusable"] as? NSNumber)?.boolValue {
                    self.args["focusable"] = focusable
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing focusable", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func parseArguments(_ args: [String: Any]) -> MenuButtonModel {
        print("Parsing menu button arguments: \(args)")

        return MenuButtonModel(
            items: parseCNMenuItems(args["menu"]),
            label: args["label"] as? String,
            image: args["image"] as? [String: Any],
            menuStyle: args["style"] as? String ?? "automatic",
            controlSize: ((args["controlSize"] as? String)?.toControlSize()) ?? .regular,
            focusable: (args["focusable"] as? NSNumber)?.boolValue ?? false
        )
    }
}

private struct MenuButtonModel {
    let items: [CNMenuItemModel]
    let label: String?
    let image: [String: Any]?
    let menuStyle: String
    let controlSize: ControlSize
    let focusable: Bool
}

private struct MenuButtonContent: View {
    let model: MenuButtonModel
    let onSelection: (String) -> Void
    let onSizeChanged: (CGSize) -> Void
    @State private var measuredSize: CGSize = .zero

    var body: some View {
        menuView
            .controlSize(model.controlSize)
            .modifier(ConditionalMenuStyle(name: model.menuStyle))
            .focusable(model.focusable)
            .padding(0)
            .background(SizeReader(size: $measuredSize))
            .onChange(of: measuredSize, initial: true) { newSize, _ in
                onSizeChanged(newSize)
            }
    }

    private var menuView: some View {
        Menu {
            CNMenuEntriesView(items: model.items, onSelection: onSelection)
        } label: {
            buttonLabelView
        }
    }

    @ViewBuilder
    private var buttonLabelView: some View {
        if let image = model.image,
           let label = model.label,
           !label.isEmpty,
           let swiftImage = CNImage.deserialize(image)
        {
            Label {
                Text(label)
            } icon: {
                swiftImage
            }
        } else if let image = model.image,
                  let swiftImage = CNImage.deserialize(image)
        {
            swiftImage
        } else if let label = model.label, !label.isEmpty {
            Text(label)
        } else {
            Text("Menu")
        }
    }

    /// Apply a menu style conditionally using a type-erased ViewModifier
    private struct ConditionalMenuStyle: ViewModifier {
        let name: String
        func body(content: Content) -> some View {
            switch name {
            case "button":
                content.menuStyle(ButtonMenuStyle())
            case "borderlessButton":
                content.menuStyle(BorderlessButtonMenuStyle())
            case "borderedButton":
                content.menuStyle(BorderedButtonMenuStyle())
            default:
                content.menuStyle(DefaultMenuStyle())
            }
        }
    }
}

struct CNMenuEntriesView: View {
    let items: [CNMenuItemModel]
    let onSelection: (String) -> Void

    var body: some View {
        menuItems(items)
    }

    @ViewBuilder
    private func rowView(for item: CNMenuItemModel) -> some View {
        let hasTitle = !item.title.isEmpty
        let hasImage = item.image != nil

        if hasTitle && hasImage {
            HStack(spacing: 8) {
                if let image = item.image,
                   let swiftImage = CNImage.deserialize(image)
                {
                    swiftImage
                }
                Text(item.title)
            }
        } else if hasTitle {
            Text(item.title)
        } else if hasImage {
            if let image = item.image,
               let swiftImage = CNImage.deserialize(image)
            {
                swiftImage
            }
        }
    }

    private func menuItems(_ items: [CNMenuItemModel]) -> AnyView {
        AnyView(
            ForEach(items, id: \.identifier) { item in
                if item.separator {
                    Divider()
                } else if let submenu = item.submenu {
                    Menu {
                        menuItems(submenu)
                    } label: {
                        rowView(for: item)
                    }
                    .disabled(!item.enabled)
                } else {
                    Button(action: { onSelection(item.identifier) }) {
                        rowView(for: item)
                    }
                    .disabled(!item.enabled)
                }
            }
        )
    }
}

private struct SizeReader: View {
    @Binding var size: CGSize

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: proxy.size)
        }
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            size = newSize
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

// MARK: - Models

enum CNToolbarItemKind: String {
    case button
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
    let label: String
    let placement: CNToolbarItemPlacement
    let systemSymbolName: String?
    let disabled: Bool
    let tintColor: NSColor?
    let buttonStyle: String?
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

            let label = (dict["label"] as? String) ?? id
            let placementRaw = (dict["placement"] as? String) ?? "automatic"
            let placement = CNToolbarItemPlacement(rawValue: placementRaw) ?? .automatic
            let symbol = dict["systemSymbolName"] as? String
            let disabled = (dict["disabled"] as? Bool) ?? false
            let tintColorHex = dict["tintColor"] as? String
            let buttonStyle = dict["buttonStyle"] as? String

            let tintColor = tintColorHex.flatMap { hex -> NSColor? in
                let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
                guard let rgbValue = UInt32(hex, radix: 16) else { return nil }
                let red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
                let green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
                let blue = CGFloat(rgbValue & 0xFF) / 255.0
                return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
            }

            parsed.append(CNToolbarItemModel(
                id: id,
                label: label,
                placement: placement,
                systemSymbolName: symbol,
                disabled: disabled,
                tintColor: tintColor,
                buttonStyle: buttonStyle
            ))
        }
        return parsed
    }
}

// MARK: - SwiftUI View

struct CNToolbarView: View {
    let title: String
    let items: [CNToolbarItemModel]
    let showSearch: Bool
    let onEvent: ([String: Any]) -> Void

    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                ForEach(items, id: \.id) { item in
                    buildButton(for: item)
                }
            }
        }
        .searchable(
            text: $searchText,
            isPresented: .constant(showSearch),
            prompt: "Search"
        )
        .onChange(of: searchText) { oldValue, newValue in
            onEvent([
                "type": "searchChanged",
                "query": newValue
            ])
        }
        .onSubmit(of: .search) {
            onEvent([
                "type": "searchSubmitted",
                "query": searchText
            ])
        }
    }

    private func buildButton(for item: CNToolbarItemModel) -> some View {
        let baseButton = Button(action: {
            onEvent(["id": item.id, "type": "buttonPressed"])
        }) {
            if let symbol = item.systemSymbolName {
                Image(systemName: symbol)
            } else {
                Text(item.label)
            }
        }
        .disabled(item.disabled)
        .tint(getTintColor(for: item))

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

    private func getTintColor(for item: CNToolbarItemModel) -> Color {
        if let tintColor = item.tintColor {
            return Color(nsColor: tintColor)
        }
        return .accentColor
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

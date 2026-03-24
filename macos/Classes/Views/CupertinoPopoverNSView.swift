import Cocoa
import FlutterMacOS

private final class CupertinoPopoverContentViewController: NSViewController {
    private let popoverTitle: String?
    private let message: String
    private let actions: [[String: Any]]
    private let width: CGFloat
    private let onSelect: (Int) -> Void

    init(
        title: String?,
        message: String,
        actions: [[String: Any]],
        width: CGFloat,
        onSelect: @escaping (Int) -> Void
    ) {
        self.popoverTitle = title
        self.message = message
        self.actions = actions
        self.width = width
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: width, height: 10))
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let popoverTitle, !popoverTitle.isEmpty {
            let titleLabel = NSTextField(labelWithString: popoverTitle)
            titleLabel.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.maximumNumberOfLines = 0
            stack.addArrangedSubview(titleLabel)
        }

        let messageLabel = NSTextField(wrappingLabelWithString: message)
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.maximumNumberOfLines = 0
        stack.addArrangedSubview(messageLabel)

        let buttons = NSStackView()
        buttons.orientation = .vertical
        buttons.alignment = .trailing
        buttons.spacing = 8
        buttons.translatesAutoresizingMaskIntoConstraints = false

        for (index, action) in actions.enumerated() {
            let label = (action["label"] as? String) ?? "Action"
            let button = NSButton(
                title: label, target: self, action: #selector(handleButtonPress(_:)))
            button.tag = index
            button.isEnabled = (action["enabled"] as? Bool) ?? true
            button.bezelStyle = .rounded
            button.setButtonType(.momentaryPushIn)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
            if #available(macOS 11.0, *) {
                button.hasDestructiveAction = (action["isDestructive"] as? Bool) == true
            }
            if (action["isDefault"] as? Bool) == true {
                button.keyEquivalent = "\r"
            }
            buttons.addArrangedSubview(button)
        }

        stack.addArrangedSubview(buttons)
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        self.view = container
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        let fitting = view.fittingSize
        preferredContentSize = NSSize(width: width, height: max(fitting.height, 44))
    }

    @objc
    private func handleButtonPress(_ sender: NSButton) {
        onSelect(sender.tag)
    }
}

class CupertinoPopoverNSView: NSView, NSPopoverDelegate {
    private let channel: FlutterMethodChannel
    private let button: NSButton
    private let popover = NSPopover()
    private var popoverTitle: String?
    private var popoverMessage: String = ""
    private var popoverActions: [[String: Any]] = []
    private var popoverWidth: CGFloat = 280
    private var preferredEdge: NSRectEdge = .maxY

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativePopover_\(viewId)", binaryMessenger: messenger)
        button = NSButton(title: "", target: nil, action: nil)
        super.init(frame: .zero)

        var title: String?
        var iconName: String?
        var iconSize: CGFloat?
        var iconColor: NSColor?
        var makeRound = false
        var buttonStyle = "plain"
        var isDark = false
        var tint: NSColor?
        var behavior = "transient"
        var preferredEdgeName = "bottom"
        var transparentOverlay = false

        if let dict = args as? [String: Any] {
            if let value = dict["transparentOverlay"] as? NSNumber {
                transparentOverlay = value.boolValue
            }
            if let value = dict["buttonTitle"] as? String { title = value }
            if let value = dict["buttonIconName"] as? String { iconName = value }
            if let value = dict["buttonIconSize"] as? NSNumber {
                iconSize = CGFloat(truncating: value)
            }
            if let value = dict["buttonIconColor"] as? NSNumber {
                iconColor = ColorUtils.colorFromARGB(value.intValue)
            }
            if let value = dict["round"] as? NSNumber { makeRound = value.boolValue }
            if let value = dict["buttonStyle"] as? String { buttonStyle = value }
            if let value = dict["isDark"] as? NSNumber { isDark = value.boolValue }
            if let value = dict["behavior"] as? String { behavior = value }
            if let value = dict["preferredEdge"] as? String { preferredEdgeName = value }
            if let value = dict["popoverTitle"] as? String { popoverTitle = value }
            if let value = dict["popoverMessage"] as? String { popoverMessage = value }
            if let value = dict["actions"] as? [[String: Any]] { popoverActions = value }
            if let value = dict["popoverWidth"] as? NSNumber {
                popoverWidth = CGFloat(truncating: value)
            }
            if let style = dict["style"] as? [String: Any], let value = style["tint"] as? NSNumber {
                tint = ColorUtils.colorFromARGB(value.intValue)
            }
            if let mode = dict["buttonIconRenderingMode"] as? String {
                _ = mode
            }
        }

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        if transparentOverlay {
            button.title = ""
            button.image = nil
            button.isBordered = false
            button.bezelStyle = .texturedRounded
        } else {
            if let title { button.title = title }
            if let iconName,
                var image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
            {
                if #available(macOS 12.0, *), let iconSize {
                    let configuration = NSImage.SymbolConfiguration(
                        pointSize: iconSize, weight: .regular)
                    image = image.withSymbolConfiguration(configuration) ?? image
                }
                if let iconColor { image = image.tinted(with: iconColor) }
                button.image = image
                button.imagePosition = .imageOnly
            }
        }

        switch buttonStyle {
        case "plain":
            button.bezelStyle = .texturedRounded
            button.isBordered = false
        case "gray", "tinted", "glass", "prominentGlass":
            button.bezelStyle = .texturedRounded
        case "bordered", "borderedProminent", "filled":
            button.bezelStyle = .rounded
        default:
            button.bezelStyle = .rounded
        }
        if makeRound { button.bezelStyle = .circular }
        if #available(macOS 10.14, *), let tint {
            if ["filled", "borderedProminent", "prominentGlass"].contains(buttonStyle) {
                button.bezelColor = tint
                button.contentTintColor = .white
            } else {
                button.contentTintColor = tint
            }
        }

        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        popover.delegate = self
        popover.behavior = Self.popoverBehavior(from: behavior)
        preferredEdge = Self.preferredEdge(from: preferredEdgeName)
        rebuildPopoverContent()

        button.target = self
        button.action = #selector(onButtonPressed(_:))

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }
            switch call.method {
            case "getIntrinsicSize":
                let size = self.button.intrinsicContentSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setStyle":
                if let args = call.arguments as? [String: Any] {
                    if #available(macOS 10.14, *), let value = args["tint"] as? NSNumber {
                        let color = ColorUtils.colorFromARGB(value.intValue)
                        if let styleName = args["buttonStyle"] as? String,
                            ["filled", "borderedProminent", "prominentGlass"].contains(styleName)
                        {
                            self.button.bezelColor = color
                            self.button.contentTintColor = .white
                        } else {
                            self.button.contentTintColor = color
                        }
                    }
                    if let styleName = args["buttonStyle"] as? String {
                        switch styleName {
                        case "plain":
                            self.button.bezelStyle = .texturedRounded
                            self.button.isBordered = false
                        case "gray", "tinted", "glass", "prominentGlass":
                            self.button.bezelStyle = .texturedRounded
                            self.button.isBordered = true
                        case "bordered", "borderedProminent", "filled":
                            self.button.bezelStyle = .rounded
                            self.button.isBordered = true
                        default:
                            self.button.bezelStyle = .rounded
                        }
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }
            case "setButtonTitle":
                if let args = call.arguments as? [String: Any], let value = args["title"] as? String
                {
                    self.button.title = value
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing title", details: nil))
                }
            case "setButtonIcon":
                if let args = call.arguments as? [String: Any] {
                    if let name = args["buttonIconName"] as? String,
                        var image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
                    {
                        if #available(macOS 12.0, *),
                            let value = args["buttonIconSize"] as? NSNumber
                        {
                            let configuration = NSImage.SymbolConfiguration(
                                pointSize: CGFloat(truncating: value), weight: .regular)
                            image = image.withSymbolConfiguration(configuration) ?? image
                        }
                        if let value = args["buttonIconColor"] as? NSNumber {
                            image = image.tinted(with: ColorUtils.colorFromARGB(value.intValue))
                        }
                        self.button.image = image
                        self.button.imagePosition = .imageOnly
                    } else {
                        self.button.image = nil
                    }
                    if let value = args["round"] as? NSNumber, value.boolValue {
                        self.button.bezelStyle = .circular
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing icon args", details: nil))
                }
            case "setBrightness":
                if let args = call.arguments as? [String: Any],
                    let isDark = (args["isDark"] as? NSNumber)?.boolValue
                {
                    self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }
            case "setPopoverContent":
                if let args = call.arguments as? [String: Any] {
                    self.popoverTitle = args["title"] as? String
                    self.popoverMessage = (args["message"] as? String) ?? ""
                    self.popoverActions = (args["actions"] as? [[String: Any]]) ?? []
                    if let value = args["popoverWidth"] as? NSNumber {
                        self.popoverWidth = CGFloat(truncating: value)
                    }
                    self.rebuildPopoverContent()
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing popover content", details: nil))
                }
            case "setPopoverBehavior":
                if let args = call.arguments as? [String: Any] {
                    if let value = args["behavior"] as? String {
                        self.popover.behavior = Self.popoverBehavior(from: value)
                    }
                    if let value = args["preferredEdge"] as? String {
                        self.preferredEdge = Self.preferredEdge(from: value)
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing popover behavior", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    @objc
    private func onButtonPressed(_ sender: NSButton) {
        if popover.isShown {
            popover.performClose(nil)
            return
        }
        rebuildPopoverContent()
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: preferredEdge)
    }

    private func rebuildPopoverContent() {
        let controller = CupertinoPopoverContentViewController(
            title: popoverTitle,
            message: popoverMessage,
            actions: popoverActions,
            width: popoverWidth
        ) { [weak self] index in
            guard let self else { return }
            self.popover.performClose(nil)
            self.channel.invokeMethod("actionSelected", arguments: ["index": index])
        }
        controller.loadViewIfNeeded()
        controller.view.layoutSubtreeIfNeeded()
        let fittingSize = controller.view.fittingSize
        popover.contentViewController = controller
        popover.contentSize = NSSize(width: popoverWidth, height: max(fittingSize.height, 44))
    }

    private static func popoverBehavior(from value: String) -> NSPopover.Behavior {
        switch value {
        case "applicationDefined":
            return .applicationDefined
        case "semitransient":
            return .semitransient
        default:
            return .transient
        }
    }

    private static func preferredEdge(from value: String) -> NSRectEdge {
        switch value {
        case "top":
            return .minY
        case "left":
            return .minX
        case "right":
            return .maxX
        default:
            return .maxY
        }
    }
}

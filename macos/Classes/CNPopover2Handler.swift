import Cocoa
import FlutterMacOS

class CNPopover2Handler: NSObject, NSPopoverDelegate {
    private weak var registrar: FlutterPluginRegistrar?
    private var activePopover: NSPopover?
    private var pendingResult: FlutterResult?
    private var actions: [PopoverAction] = []

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    func showPopover(args: [String: Any], result: @escaping FlutterResult) {
        guard let window = registrar?.view?.window,
              let contentView = window.contentView
        else {
            result(FlutterError(code: "window_unavailable", message: "No window available for popover", details: nil))
            return
        }

        // Close any existing popover
        if let existing = activePopover, existing.isShown {
            existing.performClose(nil)
            if let pending = pendingResult {
                pending(nil)
            }
        }

        let title = args["title"] as? String
        let message = args["message"] as? String
        actions = parseActions(args["actions"])
        let behaviorStr = (args["behavior"] as? String) ?? "transient"
        let preferredEdgeStr = (args["preferredEdge"] as? String) ?? "bottom"
        let popoverWidth = (args["popoverWidth"] as? NSNumber)?.doubleValue ?? 280.0

        // Anchor rect in Flutter coordinates (origin top-left)
        let anchorX = (args["anchorX"] as? NSNumber)?.doubleValue ?? 0
        let anchorY = (args["anchorY"] as? NSNumber)?.doubleValue ?? 0
        let anchorWidth = (args["anchorWidth"] as? NSNumber)?.doubleValue ?? 0
        let anchorHeight = (args["anchorHeight"] as? NSNumber)?.doubleValue ?? 0

        // contentView uses standard AppKit coordinates (origin bottom-left)
        // Flutter sends top-left origin, so flip Y
        let viewHeight = Double(contentView.bounds.height)
        let nativeY = viewHeight - anchorY - anchorHeight
        let anchorRect = NSRect(x: anchorX, y: nativeY, width: anchorWidth, height: anchorHeight)

        pendingResult = result

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                result(nil)
                return
            }

            let popover = NSPopover()
            popover.delegate = self
            popover.behavior = Self.popoverBehavior(from: behaviorStr)
            popover.animates = true

            let controller = CNPopoverContentViewController(
                title: title,
                message: message,
                actions: actions,
                width: CGFloat(popoverWidth),
            ) { [weak self] index in
                guard let self else { return }
                activePopover?.performClose(nil)
                completePending(index: index)
            }

            controller.loadViewIfNeeded()
            controller.view.layoutSubtreeIfNeeded()
            let fittingSize = controller.view.fittingSize
            popover.contentViewController = controller
            popover.contentSize = NSSize(width: popoverWidth, height: max(Double(fittingSize.height), 44))

            activePopover = popover
            popover.show(relativeTo: anchorRect, of: contentView, preferredEdge: Self.preferredEdge(from: preferredEdgeStr))
        }
    }

    // MARK: - NSPopoverDelegate

    func popoverDidClose(_: Notification) {
        // If closed without selection (e.g. clicking outside), return nil
        if pendingResult != nil {
            pendingResult?(nil)
            pendingResult = nil
        }
        activePopover = nil
    }

    // MARK: - Private

    private func completePending(index: Int) {
        guard let result = pendingResult else { return }
        pendingResult = nil

        let selectedTag: String? = if index < actions.count {
            actions[index].tag
        } else {
            nil
        }

        result([
            "selectedIndex": index,
            "selectedTag": selectedTag as Any,
        ])
    }

    private static func popoverBehavior(from value: String) -> NSPopover.Behavior {
        switch value {
        case "applicationDefined": .applicationDefined
        case "semitransient": .semitransient
        default: .transient
        }
    }

    private static func preferredEdge(from value: String) -> NSRectEdge {
        switch value {
        case "top": .minY
        case "leading": .minX
        case "trailing": .maxX
        default: .maxY
        }
    }

    // MARK: - Parsing

    struct PopoverAction {
        let title: String
        let role: String?
        let tag: String?
        let enabled: Bool
    }

    private func parseActions(_ raw: Any?) -> [PopoverAction] {
        guard let list = raw as? [[String: Any]], !list.isEmpty else {
            return [PopoverAction(title: "OK", role: nil, tag: nil, enabled: true)]
        }

        return list.map { dict in
            let title = (dict["title"] as? String) ?? "OK"
            let role = dict["role"] as? String
            let tag = dict["tag"] as? String
            let enabled = (dict["enabled"] as? Bool) ?? true
            return PopoverAction(title: title, role: role, tag: tag, enabled: enabled)
        }
    }
}

// MARK: - Popover Content View Controller

private final class CNPopoverContentViewController: NSViewController {
    private let popoverTitle: String?
    private let message: String?
    private let actions: [CNPopover2Handler.PopoverAction]
    private let width: CGFloat
    private let onSelect: (Int) -> Void

    init(
        title: String?,
        message: String?,
        actions: [CNPopover2Handler.PopoverAction],
        width: CGFloat,
        onSelect: @escaping (Int) -> Void,
    ) {
        popoverTitle = title
        self.message = message
        self.actions = actions
        self.width = width
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        if let message, !message.isEmpty {
            let messageLabel = NSTextField(wrappingLabelWithString: message)
            messageLabel.lineBreakMode = .byWordWrapping
            messageLabel.maximumNumberOfLines = 0
            stack.addArrangedSubview(messageLabel)
        }

        let buttons = NSStackView()
        buttons.orientation = .vertical
        buttons.alignment = .trailing
        buttons.spacing = 8
        buttons.translatesAutoresizingMaskIntoConstraints = false

        for (index, action) in actions.enumerated() {
            let button = NSButton(
                title: action.title, target: self, action: #selector(handleButtonPress(_:)),
            )
            button.tag = index
            button.isEnabled = action.enabled
            button.bezelStyle = .rounded
            button.setButtonType(.momentaryPushIn)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
            if #available(macOS 11.0, *) {
                button.hasDestructiveAction = action.role == "destructive"
            }
            if index == 0 {
                button.keyEquivalent = "\r"
            }
            if action.role == "cancel" {
                button.keyEquivalent = "\u{1b}"
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

        view = container
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

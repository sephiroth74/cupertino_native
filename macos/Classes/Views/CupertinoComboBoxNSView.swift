import Cocoa
import FlutterMacOS

// Custom NSComboBox that handles delayed popup opening when no focus
class MyComboBox: NSComboBox {
    var isPopupOpen = false
    var mouseWasDown = false

    private func debugLog(_ message: String) {
        NSLog("[MyComboBox] \(message)")
    }

    private func firstResponderDescription() -> String {
        guard let firstResponder = window?.firstResponder else {
            return "nil"
        }

        if firstResponder === self {
            return "self"
        }

        if let editor = currentEditor(), firstResponder === editor {
            return "fieldEditor"
        }

        return String(describing: type(of: firstResponder))
    }

    private func hasEffectiveFocus() -> Bool {
        guard let window else {
            return false
        }

        if window.firstResponder === self {
            return true
        }

        if let editor = currentEditor(), window.firstResponder === editor {
            return true
        }

        return false
    }

    private func eventOriginDescription(_ event: NSEvent) -> String {
        let pointInSelf = convert(event.locationInWindow, from: nil)
        let isInsideBounds = bounds.contains(pointInSelf)
        let hitView = superview?.hitTest(convert(event.locationInWindow, to: superview))
        let hitViewDescription: String

        if hitView === self {
            hitViewDescription = "self"
        } else if let hitView {
            hitViewDescription = String(describing: type(of: hitView))
        } else {
            hitViewDescription = "nil"
        }

        let hitResult = cell?.hitTest(for: event, in: bounds, of: self).rawValue ?? 0

        return "insideBounds=\(isInsideBounds) hitView=\(hitViewDescription) cellHit=\(hitResult)"
    }

    override func mouseDown(with event: NSEvent) {
        let hadFocus = hasEffectiveFocus()
        debugLog(
            "mouseDown hadFocus=\(hadFocus) firstResponder=\(firstResponderDescription()) \(eventOriginDescription(event))"
        )
        mouseWasDown = true

    }

    override func mouseUp(with event: NSEvent) {
        if !mouseWasDown {
            debugLog("mouseUp ignored, no preceding mouseDown")
            return
        }

        let hasFocus = hasEffectiveFocus()
        debugLog(
            "mouseUp hasFocus=\(hasFocus) firstResponder=\(firstResponderDescription()) \(eventOriginDescription(event))"
        )
        let hitResult = cell?.hitTest(for: event, in: bounds, of: self).rawValue ?? 0

        super.mouseUp(with: event)

        if hitResult == 5 && !isPopupOpen {
            debugLog("mouseUp scheduling popup open on next run loop")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.isPopupOpen {
                    self.debugLog("scheduled popup open skipped because popup is already open")
                    return
                }
                self.debugLog("scheduled popup open executing")
                self.cell?.perform(Selector("popUp:"))
            }
        }

        mouseWasDown = false
    }

    override func becomeFirstResponder() -> Bool {
        let hadFocus = hasEffectiveFocus()
        let result = super.becomeFirstResponder()
        debugLog(
            "becomeFirstResponder hadFocus=\(hadFocus) result=\(result) firstResponder=\(firstResponderDescription())"
        )
        return result
    }

    override func resignFirstResponder() -> Bool {
        let hadFocus = hasEffectiveFocus()
        debugLog(
            "resignFirstResponder hadFocus=\(hadFocus) firstResponder=\(firstResponderDescription())"
        )
        let result = super.resignFirstResponder()
        return result
    }

    func hasFocus() -> Bool {
        return hasEffectiveFocus()
    }

}

class CupertinoComboBoxNSView: NSView, NSComboBoxDelegate {
    private let channel: FlutterMethodChannel
    private let comboBox = MyComboBox(frame: .zero)
    private var isUpdatingFromDart = false

    private func debugLog(_ message: String) {
        NSLog("[CupertinoComboBoxNSView] \(message)")
    }

    private func firstResponderDescription() -> String {
        guard let firstResponder = window?.firstResponder else {
            return "nil"
        }

        if firstResponder === comboBox {
            return "comboBox"
        }

        if let editor = comboBox.currentEditor(), firstResponder === editor {
            return "fieldEditor"
        }

        return String(describing: type(of: firstResponder))
    }

    private func describeEvent(_ event: NSEvent) -> String {
        let location = NSStringFromPoint(event.locationInWindow)
        return
            "type=\(event.type.rawValue)"
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeComboBox_\(viewId)",
            binaryMessenger: messenger)
        super.init(frame: .zero)

        parseArgs(args)
        setupComboBox()
        configureChannel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func parseArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }

        // items — must be parsed before text so stringValue is set after items are loaded
        if let items = args["items"] as? [String] {
            comboBox.removeAllItems()
            if !items.isEmpty {
                comboBox.addItems(withObjectValues: items)
            }
        }

        // text
        if let text = args["text"] as? String {
            comboBox.stringValue = text
        }

        // behavior
        if let behavior = args["behavior"] as? String {
            applyBehavior(behavior)
        }

        // placeholder
        if let placeholder = args["placeholder"] as? String {
            comboBox.placeholderString = placeholder
        }

        // textColor
        if let textColor = args["textColor"] as? Int {
            comboBox.textColor = ColorUtils.colorFromARGB(textColor)
        }

        // font
        if let fontDict = args["font"] as? [String: Any],
            let font = FontUtils.fontFromDictionary(fontDict)
        {
            comboBox.font = font
        }

        // controlSize
        if let controlSize = args["controlSize"] as? String {
            comboBox.controlSize = Self.parseControlSize(controlSize)
        }

        // enabled
        if let enabled = (args["enabled"] as? NSNumber)?.boolValue {
            comboBox.isEnabled = enabled
        }

        // isDark
        if let isDark = (args["isDark"] as? NSNumber)?.boolValue {
            appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }
    }

    private func setupComboBox() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        comboBox.usesDataSource = false
        comboBox.completes = true
        comboBox.numberOfVisibleItems = 8

        comboBox.delegate = self
        comboBox.target = self
        comboBox.action = #selector(handleSubmit(_:))

        comboBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(comboBox)

        NSLayoutConstraint.activate([
            comboBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            comboBox.trailingAnchor.constraint(equalTo: trailingAnchor),
            comboBox.topAnchor.constraint(equalTo: topAnchor),
            comboBox.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    /// Applies the isEditable/isEnabled combination for the given behavior string.
    private func applyBehavior(_ raw: String) {
        switch raw {
        case "none":
            comboBox.isEditable = false
            comboBox.isEnabled = true
        case "selectable":
            comboBox.isEditable = false
            comboBox.isEnabled = true
        default:  // "editable"
            comboBox.isEditable = true
            comboBox.isEnabled = true
        }
    }

    private func configureChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            self.debugLog("Received method call: \(call.method)")

            switch call.method {

            case "getIntrinsicSize":
                let size = self.comboBox.intrinsicContentSize
                result(["width": Double(size.width), "height": Double(size.height)])

            case "setText":
                if let args = call.arguments as? [String: Any],
                    let value = args["value"] as? String
                {
                    self.isUpdatingFromDart = true
                    defer { self.isUpdatingFromDart = false }
                    self.comboBox.stringValue = value
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing text value", details: nil))
                }

            case "setItems":
                if let args = call.arguments as? [String: Any],
                    let items = args["value"] as? [String]
                {
                    let currentText = self.comboBox.stringValue
                    self.comboBox.removeAllItems()
                    if !items.isEmpty {
                        self.comboBox.addItems(withObjectValues: items)
                    }
                    // Preserve stringValue only if it's still in the new list
                    if items.contains(currentText) {
                        self.comboBox.stringValue = currentText
                    } else {
                        self.comboBox.stringValue = ""
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing items value", details: nil))
                }

            case "setBehavior":
                if let args = call.arguments as? [String: Any],
                    let value = args["value"] as? String
                {
                    self.applyBehavior(value)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing behavior value", details: nil))
                }

            case "setPlaceholder":
                if let args = call.arguments as? [String: Any] {
                    self.comboBox.placeholderString = args["value"] as? String
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing placeholder value", details: nil))
                }

            case "setTextColor":
                if let args = call.arguments as? [String: Any] {
                    if let value = args["value"] as? Int {
                        self.comboBox.textColor = ColorUtils.colorFromARGB(value)
                    } else {
                        self.comboBox.textColor = nil
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing textColor value", details: nil))
                }

            case "setPlaceholderColor":
                // NSComboBox doesn't expose a direct placeholderColor API; silently ignore.
                result(nil)

            case "setBackgroundColor":
                // NSComboBox background is managed by AppKit; silently ignore.
                result(nil)

            case "setFont":
                if let args = call.arguments as? [String: Any] {
                    if let fontDict = args["value"] as? [String: Any],
                        let font = FontUtils.fontFromDictionary(fontDict)
                    {
                        self.comboBox.font = font
                    } else {
                        self.comboBox.font = nil
                    }
                    self.notifySizeChange()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing font value", details: nil))
                }

            case "setPlaceholderFont":
                // NSComboBox doesn't expose a separate placeholder font; silently ignore.
                result(nil)

            case "setEnabled":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.comboBox.isEnabled = value
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled value", details: nil))
                }

            case "setControlSize":
                if let args = call.arguments as? [String: Any],
                    let value = args["value"] as? String
                {
                    self.comboBox.controlSize = Self.parseControlSize(value)
                    self.notifySizeChange()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing controlSize value", details: nil))
                }

            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.appearance = NSAppearance(named: value ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark value", details: nil))
                }

            case "setBezelStyle":
                // NSComboBox doesn't support changing bezel styles safely like NSTextField.
                // Doing so clips its rendering bounds. We silently ignore it.
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Notifies Flutter that the intrinsic size may have changed.
    private func notifySizeChange() {
        let size = comboBox.intrinsicContentSize
        channel.invokeMethod(
            "intrinsicSizeChanged",
            arguments: ["width": Double(size.width), "height": Double(size.height)])
    }

    @objc private func handleSubmit(_ sender: NSComboBox) {
        debugLog("submitted value=\(sender.stringValue)")
        channel.invokeMethod("submitted", arguments: sender.stringValue)
    }

    func controlTextDidChange(_ obj: Notification) {
        debugLog(
            "controlTextDidChange value=\(comboBox.stringValue), isUpdatingFromDart=\(isUpdatingFromDart)"
        )
        guard !isUpdatingFromDart else { return }
        // Only fire textChanged when the combo box is actually editable (behavior == editable).
        guard comboBox.isEditable else { return }
        channel.invokeMethod("textChanged", arguments: comboBox.stringValue)
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        debugLog("notification object=\(String(describing: notification.object))")
    }

    func comboBoxWillPopUp(_ notification: Notification) {
        comboBox.isPopupOpen = true
        debugLog(
            "comboBoxWillPopUp responder=\(firstResponderDescription()) currentEvent=\(window?.currentEvent.map(describeEvent) ?? "nil")"
        )
    }

    func comboBoxWillDismiss(_ notification: Notification) {
        comboBox.isPopupOpen = false
        debugLog(
            "comboBoxWillDismiss responder=\(firstResponderDescription()) currentEvent=\(window?.currentEvent.map(describeEvent) ?? "nil")"
        )
    }

    private static func parseControlSize(_ rawValue: String) -> NSControl.ControlSize {
        return ControlSizeUtils.controlSizeFromString(rawValue)
    }

}

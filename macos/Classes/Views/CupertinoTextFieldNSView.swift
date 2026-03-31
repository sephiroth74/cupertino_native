import Cocoa
import FlutterMacOS

class CupertinoTextFieldNSView: NSView, NSTextFieldDelegate, MyTextFieldDelegate {
    private let channel: FlutterMethodChannel
    private let textField = MyTextField(frame: .zero)
    private var placeholderColor: NSColor?
    private var isUpdatingFromDart = false

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeTextField_\(viewId)",
            binaryMessenger: messenger)
        super.init(frame: .zero)

        parseArgs(args)
        setupTextField()
        configureChannel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func parseArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }

        if let text = args["text"] as? String {
            textField.stringValue = text
        }

        if let placeholder = args["placeholder"] as? String {
            textField.placeholderString = placeholder
        }

        if let textColor = args["textColor"] as? Int {
            textField.textColor = ColorUtils.colorFromARGB(textColor)
        }

        if let placeholderColor = args["placeholderColor"] as? Int {
            self.placeholderColor = ColorUtils.colorFromARGB(placeholderColor)
        }

        if let backgroundColor = args["backgroundColor"] as? Int {
            textField.drawsBackground = true
            textField.backgroundColor = ColorUtils.colorFromARGB(backgroundColor)
        } else {
            textField.drawsBackground = false
            textField.backgroundColor = .clear
        }

        if let fontDict = args["font"] as? [String: Any],
            let font = FontUtils.fontFromDictionary(fontDict)
        {
            textField.font = font
        }

        if let enabled = (args["enabled"] as? NSNumber)?.boolValue {
            textField.isEnabled = enabled
        }

        if let isDark = (args["isDark"] as? NSNumber)?.boolValue {
            appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }

        if let controlSize = args["controlSize"] as? String {
            textField.controlSize = Self.parseControlSize(controlSize)
        }

        if let bezelStyle = args["bezelStyle"] as? String {
            Self.applyBezelStyle(bezelStyle, to: textField)
        }

        applyPlaceholderColor()
    }

    private func setupTextField() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        textField.wantsLayer = true
        textField.callback = self
        textField.delegate = self
        textField.target = self
        textField.action = #selector(handleSubmit(_:))

        textField.translatesAutoresizingMaskIntoConstraints = false

        // add some padding
        let padding: CGFloat = 1

        // we should add the textfield inside a view with some padding around it in order
        // to prevent the textfield borders to be cut

        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        containerView.addSubview(textField)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -padding),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func configureChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let size = self.textField.intrinsicContentSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setText":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    self.isUpdatingFromDart = true
                    self.textField.stringValue = value
                    self.isUpdatingFromDart = false
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing text value", details: nil))
                }
            case "setSelection":
                if let args = call.arguments as? [String: Any],
                    let base = args["base"] as? Int,
                    let extent = args["extent"] as? Int
                {
                    if let editor = self.textField.currentEditor() as? NSTextView {
                        let length = max(0, extent - base)
                        let location = min(max(0, base), self.textField.stringValue.count)
                        let range = NSRange(location: location, length: length)
                        self.isUpdatingFromDart = true
                        editor.setSelectedRange(range)
                        self.isUpdatingFromDart = false
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing selection values", details: nil))
                }
            case "setPlaceholder":
                if let args = call.arguments as? [String: Any] {
                    self.textField.placeholderString = args["value"] as? String
                    self.applyPlaceholderColor()
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing placeholder value", details: nil))
                }
            case "setTextColor":
                if let args = call.arguments as? [String: Any] {
                    let value = args["value"] as? Int
                    self.textField.textColor = value.map(ColorUtils.colorFromARGB)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing textColor value", details: nil))
                }
            case "setPlaceholderColor":
                if let args = call.arguments as? [String: Any] {
                    let value = args["value"] as? Int
                    self.placeholderColor = value.map(ColorUtils.colorFromARGB)
                    self.applyPlaceholderColor()
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing placeholderColor value",
                            details: nil))
                }
            case "setBackgroundColor":
                if let args = call.arguments as? [String: Any] {
                    if let value = args["value"] as? Int {
                        self.textField.drawsBackground = true
                        self.textField.backgroundColor = ColorUtils.colorFromARGB(value)
                    } else {
                        self.textField.drawsBackground = false
                        self.textField.backgroundColor = .clear
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing backgroundColor value", details: nil
                        ))
                }
            case "setFont":
                if let args = call.arguments as? [String: Any] {
                    if let fontDict = args["value"] as? [String: Any],
                        let font = FontUtils.fontFromDictionary(fontDict)
                    {
                        self.textField.font = font
                    } else {
                        self.textField.font = nil
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing font value", details: nil))
                }
            case "setEnabled":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.textField.isEnabled = value
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing enabled value", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    self.textField.controlSize = Self.parseControlSize(value)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing controlSize value", details: nil))
                }
            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.appearance = NSAppearance(named: value ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing isDark value", details: nil))
                }
            case "setBezelStyle":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    Self.applyBezelStyle(value, to: self.textField)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing bezelStyle value", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func handleSubmit(_ sender: NSTextField) {
        channel.invokeMethod("submitted", arguments: sender.stringValue)
    }

    func controlTextDidChange(_ obj: Notification) {
        guard !isUpdatingFromDart else { return }
        //let selectedRange = textField.selectedRange
        channel.invokeMethod("textChanged", arguments: textField.stringValue)
    }

    func textFieldDidChangeSelection(_ textField: MyTextField, _ range: NSRange) {
        guard !isUpdatingFromDart else { return }
        channel.invokeMethod(
            "selectionChanged",
            arguments: ["base": range.location, "extent": range.location + range.length])
    }

    private func applyPlaceholderColor() {
        guard let placeholder = textField.placeholderString, !placeholder.isEmpty else {
            textField.placeholderAttributedString = nil
            return
        }

        if let placeholderColor {
            textField.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: placeholderColor])
        } else {
            textField.placeholderAttributedString = NSAttributedString(string: placeholder)
        }
    }

    private static func parseControlSize(_ rawValue: String) -> NSControl.ControlSize {
        switch rawValue {
        case "mini": return .mini
        case "small": return .small
        case "large": return .large
        case "extraLarge":
            if #available(macOS 26.0, *) { return .extraLarge }
            return .large
        default: return .regular
        }
    }

    private static func applyBezelStyle(_ rawValue: String, to field: NSTextField) {
        switch rawValue {
        case "none":
            field.isBezeled = false
            field.isBordered = false
        case "line":
            field.isBezeled = false
            field.isBordered = true
        case "bezel":
            field.isBordered = true
            field.isBezeled = true
            field.bezelStyle = .squareBezel
        default:
            field.isBordered = true
            field.isBezeled = true
            field.bezelStyle = .roundedBezel
        }
    }

}
class MyTextField: NSTextField, NSTextViewDelegate {
    weak open var callback: (any MyTextFieldDelegate)?

    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        return result
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        if let textView = notification.object as? NSTextView,
            textView == self.currentEditor()
        {
            let range = textView.selectedRange()
            callback?.textFieldDidChangeSelection(self, range)
        }
    }

}

protocol MyTextFieldDelegate: NSObjectProtocol {
    @MainActor func textFieldDidChangeSelection(_ textField: MyTextField, _ range: NSRange)
}

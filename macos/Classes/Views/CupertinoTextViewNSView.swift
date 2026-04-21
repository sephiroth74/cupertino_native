import Cocoa
import FlutterMacOS

class CupertinoTextViewNSView: NSView, NSTextViewDelegate {
    private let channel: FlutterMethodChannel
    private let scrollView = NSScrollView(frame: .zero)
    private let textView = NSTextView(frame: .zero)
    private let placeholderLabel = NSTextField(labelWithString: "")

    private var placeholderColor: NSColor?
    private var placeholderFont: NSFont?
    private var isUpdatingFromDart = false

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeTextView_\(viewId)",
            binaryMessenger: messenger)
        super.init(frame: .zero)

        parseArgs(args)
        setupTextView()
        applyInitialSelection(args)
        configureChannel()
        updatePlaceholderVisibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func parseArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }

        if let text = args["text"] as? String {
            textView.string = text
        }

        if let placeholder = args["placeholder"] as? String {
            placeholderLabel.stringValue = placeholder
        }

        if let textColor = args["textColor"] as? Int {
            textView.textColor = ColorUtils.colorFromARGB(textColor)
        }

        if let placeholderColor = args["placeholderColor"] as? Int {
            self.placeholderColor = ColorUtils.colorFromARGB(placeholderColor)
        }

        if let backgroundColor = args["backgroundColor"] as? Int {
            textView.drawsBackground = true
            textView.backgroundColor = ColorUtils.colorFromARGB(backgroundColor)
        } else {
            textView.drawsBackground = false
            textView.backgroundColor = .clear
        }

        if let fontDict = args["font"] as? [String: Any],
            let font = FontUtils.fontFromDictionary(fontDict)
        {
            textView.font = font
        }

        if let fontDict = args["placeholderFont"] as? [String: Any],
            let font = FontUtils.fontFromDictionary(fontDict)
        {
            placeholderFont = font
        }

        if let enabled = (args["enabled"] as? NSNumber)?.boolValue {
            textView.isEditable = enabled
        }

        if let isDark = (args["isDark"] as? NSNumber)?.boolValue {
            appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }

        applyPlaceholderStyle()
    }

    private func setupTextView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false

        textView.isRichText = false
        textView.importsGraphics = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isContinuousSpellCheckingEnabled = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainerInset = NSSize(width: 4, height: 6)
        textView.delegate = self

        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude)

        scrollView.documentView = textView

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.alignment = .left
        placeholderLabel.maximumNumberOfLines = 1

        addSubview(scrollView)
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -8),
        ])
    }

    private func configureChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }

            switch call.method {
            case "setText":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    self.isUpdatingFromDart = true
                    self.textView.string = value
                    self.isUpdatingFromDart = false
                    self.updatePlaceholderVisibility()
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
                    let length = max(0, extent - base)
                    let textLength = (self.textView.string as NSString).length
                    let location = min(max(0, base), textLength)
                    let clampedLength = min(length, max(0, textLength - location))
                    self.isUpdatingFromDart = true
                    self.textView.setSelectedRange(
                        NSRange(location: location, length: clampedLength))
                    self.isUpdatingFromDart = false
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing selection values", details: nil))
                }
            case "setPlaceholder":
                if let args = call.arguments as? [String: Any] {
                    self.placeholderLabel.stringValue = (args["value"] as? String) ?? ""
                    self.updatePlaceholderVisibility()
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing placeholder value", details: nil))
                }
            case "setTextColor":
                if let args = call.arguments as? [String: Any] {
                    let value = args["value"] as? Int
                    self.textView.textColor = value.map(ColorUtils.colorFromARGB)
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
                    self.applyPlaceholderStyle()
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
                        self.textView.drawsBackground = true
                        self.textView.backgroundColor = ColorUtils.colorFromARGB(value)
                    } else {
                        self.textView.drawsBackground = false
                        self.textView.backgroundColor = .clear
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
                        self.textView.font = font
                    } else {
                        self.textView.font = nil
                    }
                    self.applyPlaceholderStyle()
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing font value", details: nil))
                }
            case "setPlaceholderFont":
                if let args = call.arguments as? [String: Any] {
                    if let fontDict = args["value"] as? [String: Any],
                        let font = FontUtils.fontFromDictionary(fontDict)
                    {
                        self.placeholderFont = font
                    } else {
                        self.placeholderFont = nil
                    }
                    self.applyPlaceholderStyle()
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing placeholderFont value", details: nil
                        ))
                }
            case "setEnabled":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.boolValue
                {
                    self.textView.isEditable = value
                    self.textView.isSelectable = true
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing enabled value", details: nil))
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
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func textDidChange(_ notification: Notification) {
        guard !isUpdatingFromDart else { return }
        updatePlaceholderVisibility()
        channel.invokeMethod("textChanged", arguments: textView.string)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        guard !isUpdatingFromDart else { return }
        let range = textView.selectedRange()
        channel.invokeMethod(
            "selectionChanged",
            arguments: ["base": range.location, "extent": range.location + range.length])
    }

    private func applyInitialSelection(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }
        guard let base = args["selectionBase"] as? Int,
            let extent = args["selectionExtent"] as? Int
        else {
            return
        }

        let length = max(0, extent - base)
        let textLength = (textView.string as NSString).length
        let location = min(max(0, base), textLength)
        let clampedLength = min(length, max(0, textLength - location))
        textView.setSelectedRange(NSRange(location: location, length: clampedLength))
    }

    private func applyPlaceholderStyle() {
        let fontToUse =
            placeholderFont
            ?? textView.font
            ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        placeholderLabel.font = fontToUse
        placeholderLabel.textColor = placeholderColor ?? NSColor.placeholderTextColor
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textView.string.isEmpty || placeholderLabel.stringValue.isEmpty
    }
}

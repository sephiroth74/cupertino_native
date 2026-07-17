import Cocoa
import FlutterMacOS

class CupertinoSearchField2NSView: NSView, NSSearchFieldDelegate, NSTextSuggestionsDelegate {
    typealias SuggestionItemType = String

    private let channel: FlutterMethodChannel
    private let searchField = NSSearchField(frame: .zero)
    private var placeholderText: String?
    private var placeholderColor: NSColor?
    private var isUpdatingFromDart = false
    private var hasSuggestions = false
    private var debugLog = false
    private var font: NSFont?

    private func log(_ message: String) {
        guard debugLog else { return }
        NSLog("[CupertinoSearchField2NSView] \(message)")
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeSearchField2_\(viewId)",
            binaryMessenger: messenger,
        )
        super.init(frame: .zero)

        setupSearchField()
        applyArgs(args, viewId: viewId)
        configureChannel(viewId: viewId)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupSearchField() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        searchField.delegate = self
        if #available(macOS 15.0, *) {
            searchField.suggestionsDelegate = self
        }
        searchField.sendsSearchStringImmediately = false
        searchField.sendsWholeSearchString = true

        searchField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(searchField)
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.topAnchor.constraint(equalTo: topAnchor),
            searchField.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Payload handling

    private func applyArgs(_ rawArgs: Any?, viewId _: Int64) {
        guard let args = rawArgs as? [String: Any] else { return }
        applyPayload(args)
    }

    private func applyPayload(_ args: [String: Any]) {
        if let value = args["debugLog"] as? Bool {
            debugLog = value
        }

        if let text = args["text"] as? String {
            isUpdatingFromDart = true
            searchField.stringValue = text
            isUpdatingFromDart = false
        }

        if let placeholder = args["placeholder"] as? String {
            placeholderText = placeholder
        } else if args.keys.contains("placeholder") {
            placeholderText = nil
        }

        if let textColor = args["textColor"] as? Int {
            searchField.textColor = ColorUtils.colorFromARGB(textColor)
        } else if args.keys.contains("textColor") {
            searchField.textColor = nil
        }

        if let color = args["placeholderColor"] as? Int {
            placeholderColor = ColorUtils.colorFromARGB(color)
        } else if args.keys.contains("placeholderColor") {
            placeholderColor = NSColor.placeholderTextColor
        }

        if let fontDict = args["font"] as? [String: Any],
           let font = FontUtils.fontFromDictionary(fontDict)
        {
            self.font = font
        } else if args.keys.contains("font") {
            font = nil
        }

        if let controlSize = args["controlSize"] as? String {
            searchField.controlSize = ControlSizeUtils.controlSizeFromString(controlSize)
        }

        if let bezelStyle = args["bezelStyle"] as? String {
            Self.applyBezelStyle(bezelStyle, to: searchField)
        }

        if let enabled = args["enabled"] as? Bool {
            searchField.isEnabled = enabled
        }

        if let value = args["hasSuggestions"] as? Bool {
            hasSuggestions = value
        }

        applyPlaceholder()
        applyFont()
    }

    // MARK: - Channel

    private func configureChannel(viewId _: Int64) {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "setData":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(args)
                    log("setData keys=\(Array(args.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(patch)
                    log("applyPatch keys=\(Array(patch.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            case "getIntrinsicSize":
                let size = searchField.intrinsicContentSize
                log("getIntrinsicSize -> \(size)")
                result(["width": Double(size.width), "height": Double(size.height)])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Delegate methods

    func controlTextDidChange(_: Notification) {
        guard !isUpdatingFromDart else { return }
        let text = searchField.stringValue
        log("textChanged: \(text)")
        channel.invokeMethod("textChanged", arguments: text)
    }

    func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            let text = searchField.stringValue
            log("submitted: \(text)")
            channel.invokeMethod("submitted", arguments: text)
            return true
        }
        return false
    }

    @available(macOS 15.0, *)
    func textField(
        _ textField: NSTextField,
        provideUpdatedSuggestions responseHandler: @escaping (NSSuggestionItemResponse<String>) -> Void,
    ) {
        guard hasSuggestions else {
            responseHandler(NSSuggestionItemResponse<String>())
            return
        }

        let query = textField.stringValue
        log("requestSuggestions: query=\(query)")

        channel.invokeMethod("requestSuggestions", arguments: ["query": query]) { [weak self] result in
            guard let self else {
                responseHandler(NSSuggestionItemResponse<String>())
                return
            }

            log("requestSuggestions: \result=\(String(describing: result))")

            let values = result as? [String] ?? []
            log("suggestions received: \(values.count) items")
            let items = values.map { NSSuggestionItem<String>(representedValue: $0, title: $0) }
            responseHandler(NSSuggestionItemResponse<String>(items: items))
        }
    }

    @available(macOS 15.0, *)
    func textField(_: NSTextField, didSelect item: NSSuggestionItem<String>) {
        let value = item.representedValue
        log("suggestion selected: \(value)")
        isUpdatingFromDart = true
        searchField.stringValue = value
        isUpdatingFromDart = false
        channel.invokeMethod("textChanged", arguments: value)
        channel.invokeMethod("submitted", arguments: value)
    }

    // MARK: - Helpers

    private func applyPlaceholder() {
        guard let placeholder = placeholderText, !placeholder.isEmpty else {
            searchField.placeholderAttributedString = nil
            searchField.placeholderString = nil
            return
        }

        let effectiveFont = font ?? searchField.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)

        if let placeholderColor {
            searchField.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: placeholderColor, .font: effectiveFont],
            )
        } else {
            searchField.placeholderAttributedString = nil
            searchField.placeholderString = placeholder
        }
    }

    private func applyFont() {
        if let font {
            searchField.font = font
        }
    }

    private static func applyBezelStyle(_ rawValue: String, to field: NSSearchField) {
        switch rawValue {
        case "none":
            field.isBezeled = false
            field.isBordered = false
        case "line":
            field.isBezeled = false
            field.isBordered = true
        case "bezel":
            field.isBezeled = true
            field.bezelStyle = .squareBezel
        default:
            field.isBezeled = true
            field.bezelStyle = .roundedBezel
        }
    }
}

import Cocoa
import FlutterMacOS

@available(macOS 15.0, *)
typealias SearchSuggestionItem = NSSuggestionItem<String>

@available(macOS 15.0, *)
typealias SearchSuggestionResponse = NSSuggestionItemResponse<String>

class CupertinoSearchFieldNSView: NSView, NSSearchFieldDelegate, NSTextSuggestionsDelegate {
    typealias SuggestionItemType = String

    private let channel: FlutterMethodChannel
    private let searchField = NSSearchField(frame: .zero)
    private var placeholderColor: NSColor?

    private var isUpdatingFromDart = false
    private var suggestions: [String] = []

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeSearchField_\(viewId)",
            binaryMessenger: messenger)
        super.init(frame: .zero)

        parseArgs(args)
        setupSearchField()
        configureChannel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func parseArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }

        if let text = args["text"] as? String {
            searchField.stringValue = text
        }

        if let placeholder = args["placeholder"] as? String {
            searchField.placeholderString = placeholder
        }

        if let textColor = args["textColor"] as? Int {
            searchField.textColor = ColorUtils.colorFromARGB(textColor)
        }

        if let placeholderColor = args["placeholderColor"] as? Int {
            self.placeholderColor = ColorUtils.colorFromARGB(placeholderColor)
        }

        if let backgroundColor = args["backgroundColor"] as? Int {
            searchField.drawsBackground = true
            searchField.backgroundColor = ColorUtils.colorFromARGB(backgroundColor)
        } else {
            searchField.drawsBackground = false
            searchField.backgroundColor = .clear
        }

        if let fontDict = args["font"] as? [String: Any],
            let font = FontUtils.fontFromDictionary(fontDict)
        {
            searchField.font = font
        }

        if let enabled = (args["enabled"] as? NSNumber)?.boolValue {
            searchField.isEnabled = enabled
        }

        if let isDark = (args["isDark"] as? NSNumber)?.boolValue {
            appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        }

        if let controlSize = args["controlSize"] as? String {
            searchField.controlSize = Self.parseControlSize(controlSize)
        }

        if let bezelStyle = args["bezelStyle"] as? String {
            Self.applyBezelStyle(bezelStyle, to: searchField)
        }

        if let rawSuggestions = args["suggestions"] as? [String] {
            suggestions = rawSuggestions
        }

        applyPlaceholderColor()
    }

    private func setupSearchField() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        searchField.delegate = self
        if #available(macOS 15.0, *) {
            searchField.suggestionsDelegate = self
        }
        searchField.target = self
        searchField.action = #selector(handleSubmit(_:))

        addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor),
            searchField.topAnchor.constraint(equalTo: topAnchor),
            searchField.bottomAnchor.constraint(equalTo: bottomAnchor),
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
                let size = self.searchField.intrinsicContentSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setText":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    self.isUpdatingFromDart = true
                    self.searchField.stringValue = value
                    self.isUpdatingFromDart = false
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing text value", details: nil))
                }
            case "setPlaceholder":
                if let args = call.arguments as? [String: Any] {
                    self.searchField.placeholderString = args["value"] as? String
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
                    self.searchField.textColor = value.map(ColorUtils.colorFromARGB)
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
                            code: "bad_args",
                            message: "Missing placeholderColor value",
                            details: nil))
                }
            case "setBackgroundColor":
                if let args = call.arguments as? [String: Any] {
                    if let value = args["value"] as? Int {
                        self.searchField.drawsBackground = true
                        self.searchField.backgroundColor = ColorUtils.colorFromARGB(value)
                    } else {
                        self.searchField.drawsBackground = false
                        self.searchField.backgroundColor = .clear
                    }
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args",
                            message: "Missing backgroundColor value",
                            details: nil))
                }
            case "setFont":
                if let args = call.arguments as? [String: Any] {
                    if let fontDict = args["value"] as? [String: Any],
                        let font = FontUtils.fontFromDictionary(fontDict)
                    {
                        self.searchField.font = font
                    } else {
                        self.searchField.font = nil
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
                    self.searchField.isEnabled = value
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing enabled value", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any], let value = args["value"] as? String
                {
                    self.searchField.controlSize = Self.parseControlSize(value)
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
                    Self.applyBezelStyle(value, to: self.searchField)
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing bezelStyle value", details: nil))
                }
            case "setSuggestions":
                if let args = call.arguments as? [String: Any],
                    let value = args["value"] as? [String]
                {
                    self.suggestions = value
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing suggestions value", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func handleSubmit(_ sender: NSSearchField) {
        channel.invokeMethod("submitted", arguments: sender.stringValue)
    }

    func controlTextDidChange(_ obj: Notification) {
        guard !isUpdatingFromDart else { return }
        channel.invokeMethod("textChanged", arguments: searchField.stringValue)
    }

    func control(
        _ control: NSControl,
        textView: NSTextView,
        completions words: [String],
        forPartialWordRange charRange: NSRange,
        indexOfSelectedItem index: UnsafeMutablePointer<Int>
    ) -> [String] {
        let query = searchField.stringValue
        guard !query.isEmpty, !suggestions.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return suggestions.filter { $0.lowercased().contains(lowercasedQuery) }
    }

    @available(macOS 15.0, *)
    func textField(
        _ textField: NSTextField,
        provideUpdatedSuggestions responseHandler: @escaping (SearchSuggestionResponse) -> Void
    ) {
        let query = textField.stringValue

        channel.invokeMethod("requestSuggestions", arguments: ["query": query]) {
            [weak self] result in
            guard let self else {
                responseHandler(SearchSuggestionResponse())
                return
            }

            let valuesFromFlutter = result as? [String]
            let values = valuesFromFlutter ?? self.filteredSuggestions(for: query)
            let items = values.map { SearchSuggestionItem(representedValue: $0, title: $0) }
            responseHandler(SearchSuggestionResponse(items: items))
        }
    }

    @available(macOS 15.0, *)
    func textField(_ textField: NSTextField, didSelect item: SearchSuggestionItem) {
        let value = item.representedValue
        isUpdatingFromDart = true
        searchField.stringValue = value
        isUpdatingFromDart = false
        channel.invokeMethod("textChanged", arguments: value)
        channel.invokeMethod("submitted", arguments: value)
    }

    private func filteredSuggestions(for query: String) -> [String] {
        guard !query.isEmpty, !suggestions.isEmpty else { return [] }
        let lower = query.lowercased()
        return suggestions.filter { $0.lowercased().contains(lower) }
    }

    private func applyPlaceholderColor() {
        guard let placeholder = searchField.placeholderString, !placeholder.isEmpty else {
            searchField.placeholderAttributedString = nil
            return
        }

        if let placeholderColor {
            searchField.placeholderAttributedString = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: placeholderColor])
        } else {
            searchField.placeholderAttributedString = NSAttributedString(string: placeholder)
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

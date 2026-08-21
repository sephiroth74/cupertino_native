import Cocoa
import FlutterMacOS

/// Value carried by a suggestion item: `id` is the opaque handle Dart uses to
/// resolve the picked item back to the object it returned, `value` is the text
/// written into the field once the item is selected.
struct CNSuggestionItemValue: Hashable {
    let id: String
    let value: String
}

class CupertinoSearchField2NSView: NSView, NSSearchFieldDelegate, NSTextSuggestionsDelegate {
    typealias SuggestionItemType = CNSuggestionItemValue

    private let channel: FlutterMethodChannel
    private let searchField = NSSearchField(frame: .zero)
    private var placeholderText: String?
    private var placeholderColor: NSColor?
    private var isUpdatingFromDart = false
    private var hasSuggestions = false
    private var autofocus = false
    private var didAutofocus = false
    private var debugLog = false
    private var font: NSFont?
    private var ignorePointer = false

    /// Mirrors a `CNDisabled` scope on the Flutter side: Flutter can only gate
    /// its own hit testing, so the platform view has to remove itself from
    /// AppKit's hit-test walk. See `CNWidgetNSView.hitTest(_:)`.
    override func hitTest(_ point: NSPoint) -> NSView? {
        ignorePointer ? nil : super.hitTest(point)
    }

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

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Autofocus only once: re-focusing on every window move would fight
        // whatever the user (or another view) focused afterwards, and each
        // makeFirstResponder on a search field selects all its text.
        if autofocus, !didAutofocus, window != nil {
            didAutofocus = true
            DispatchQueue.main.async { [weak self] in
                guard let self, let window else { return }
                window.makeFirstResponder(searchField)
                // Becoming first responder selects the whole string; move the
                // caret to the end so typing continues instead of overwriting.
                if let editor = searchField.currentEditor() {
                    let end = (searchField.stringValue as NSString).length
                    editor.selectedRange = NSRange(location: end, length: 0)
                }
            }
        }
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

        // Only touch stringValue when it actually differs: assigning it selects
        // the whole text by default, so re-applying the current value (e.g. an
        // echo of what the user just typed) would reselect everything on every
        // keystroke. When the value genuinely differs and the field is being
        // edited, collapse the selection to the end so typing continues
        // naturally instead of overwriting the field.
        if let text = args["text"] as? String, text != searchField.stringValue {
            isUpdatingFromDart = true
            searchField.stringValue = text
            if let editor = searchField.currentEditor() {
                let end = (text as NSString).length
                editor.selectedRange = NSRange(location: end, length: 0)
            }
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

        if args.keys.contains("ignorePointer") {
            ignorePointer = args["ignorePointer"] as? Bool ?? false
        }

        if args.keys.contains("help") {
            searchField.toolTip = args["help"] as? String
        }

        if let value = args["hasSuggestions"] as? Bool {
            hasSuggestions = value
        }

        if let value = args["autofocus"] as? Bool {
            autofocus = value
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

    func controlTextDidBeginEditing(_: Notification) {
        log("focusChanged: true")
        channel.invokeMethod("focusChanged", arguments: true)
    }

    func controlTextDidEndEditing(_: Notification) {
        log("focusChanged: false")
        channel.invokeMethod("focusChanged", arguments: false)
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
        provideUpdatedSuggestions responseHandler: @escaping (NSSuggestionItemResponse<SuggestionItemType>) -> Void,
    ) {
        guard hasSuggestions else {
            responseHandler(NSSuggestionItemResponse<SuggestionItemType>())
            return
        }

        let query = textField.stringValue
        log("requestSuggestions: query=\(query)")

        channel.invokeMethod("requestSuggestions", arguments: ["query": query]) { [weak self] result in
            guard let self else {
                responseHandler(NSSuggestionItemResponse<SuggestionItemType>())
                return
            }

            let sections = Self.decodeSections(result)
            log("suggestions received: \(sections.count) section(s), \(sections.reduce(0) { $0 + $1.items.count }) items")
            responseHandler(NSSuggestionItemResponse<SuggestionItemType>(itemSections: sections))
        }
    }

    @available(macOS 15.0, *)
    func textField(_: NSTextField, didSelect item: NSSuggestionItem<SuggestionItemType>) {
        let selected = item.representedValue
        log("suggestion selected: id=\(selected.id) value=\(selected.value)")
        isUpdatingFromDart = true
        searchField.stringValue = selected.value
        isUpdatingFromDart = false
        // Dart owns the fan-out from here (controller text, onChanged,
        // onSuggestionSelected, onSubmitted) so ordering stays in one place.
        channel.invokeMethod("suggestionSelected", arguments: ["id": selected.id, "value": selected.value])
    }

    // MARK: - Suggestions decoding

    @available(macOS 15.0, *)
    private static func decodeSections(_ result: Any?) -> [NSSuggestionItemSection<CNSuggestionItemValue>] {
        guard let dict = CNChannelSerialization.asDict(result) else { return [] }
        let rawSections = CNChannelSerialization.asArray(dict["sections"])

        return rawSections.compactMap { rawSection -> NSSuggestionItemSection<CNSuggestionItemValue>? in
            guard let section = CNChannelSerialization.asDict(rawSection) else { return nil }
            let items = CNChannelSerialization.asArray(section["items"]).compactMap { raw in
                CNChannelSerialization.asDict(raw).flatMap { makeSuggestionItem($0) }
            }
            // An empty section would still draw its header, so drop it.
            guard !items.isEmpty else { return nil }
            return NSSuggestionItemSection(
                title: CNChannelDeserialization.decodeString(section["title"]),
                items: items,
            )
        }
    }

    @available(macOS 15.0, *)
    private static func makeSuggestionItem(_ raw: [String: Any]) -> NSSuggestionItem<CNSuggestionItemValue>? {
        guard let title = CNChannelDeserialization.decodeString(raw["title"]) else { return nil }
        let value = CNChannelDeserialization.decodeString(raw["value"]) ?? title
        let id = CNChannelDeserialization.decodeString(raw["id"]) ?? value

        var item = NSSuggestionItem(
            representedValue: CNSuggestionItemValue(id: id, value: value),
            title: title,
        )

        if let secondary = CNChannelDeserialization.decodeString(raw["secondaryTitle"]), !secondary.isEmpty {
            item.secondaryTitle = secondary
        }

        if let toolTip = CNChannelDeserialization.decodeString(raw["help"]), !toolTip.isEmpty {
            item.toolTip = toolTip
        }

        if let symbolName = CNChannelDeserialization.decodeString(raw["systemImage"]), !symbolName.isEmpty {
            item.image = makeSymbolImage(named: symbolName, accessibilityDescription: title, raw: raw)
        }

        return item
    }

    private static func makeSymbolImage(
        named symbolName: String,
        accessibilityDescription: String,
        raw: [String: Any],
    ) -> NSImage? {
        guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityDescription) else {
            return nil
        }
        guard let argb = CNChannelDeserialization.decodeInt(raw["imageColor"]) else { return image }
        let color = ColorUtils.colorFromARGB(argb)
        // Palette rendering is what tints a symbol without flattening it to a
        // template mask, so a multi-layer glyph keeps its shape.
        return image.withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors: [color])) ?? image
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

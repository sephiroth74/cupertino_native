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
    private let searchField = CNSearchFieldControl(frame: .zero)
    private var bezelStyle: String?
    private var paddings: CNPaddingsPayload?
    private var glassEffect: [String: Any]?
    /// The `NSGlassEffectView` hosting the search field while a glass is shown.
    private var glassView: NSView?
    private var glassConstraints: [NSLayoutConstraint] = []
    private var fieldConstraints: [NSLayoutConstraint] = []
    /// Total inset between this view's edges and the search field.
    private var fieldInsets = NSEdgeInsetsZero
    private var placeholderText: String?
    private var placeholderColor: NSColor?
    private var isUpdatingFromDart = false
    private var hasSuggestions = false
    private var autofocus = false
    private var didAutofocus = false
    private var debugLog = false
    private var font: NSFont?
    private var ignorePointer = false
    private var borderColor: NSColor?
    private var borderWidth: CGFloat?
    private var cornerRadius: CGFloat?

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
        applyGlassEffect()
    }

    override func layout() {
        super.layout()
        updateGlassShape()
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

        if args.keys.contains("bezelStyle") {
            bezelStyle = args["bezelStyle"] as? String
        }

        if args.keys.contains("paddings") {
            paddings = CNPaddingsPayload.fromChannel(args["paddings"] as? [String: Any])
        }

        if args.keys.contains("glassEffect") {
            glassEffect = args["glassEffect"] as? [String: Any]
        }

        if args.keys.contains("borderColor") {
            borderColor = CNChannelDeserialization.decodeInt(args["borderColor"]).map(ColorUtils.colorFromARGB)
        }

        if args.keys.contains("borderWidth") {
            borderWidth = CNChannelDeserialization.decodeCGFloat(args["borderWidth"])
        }

        if args.keys.contains("cornerRadius") {
            cornerRadius = CNChannelDeserialization.decodeCGFloat(args["cornerRadius"])
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
        applyBorder()
        if args.keys.contains("bezelStyle") || args.keys.contains("glassEffect") {
            applyBezelStyle()
        }
        if args.keys.contains("paddings") || args.keys.contains("glassEffect") || args.keys.contains("bezelStyle") {
            applyGlassEffect()
        }
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
                let field = searchField.intrinsicContentSize
                // A width without intrinsic metric stays negative so Dart keeps
                // treating it as unknown.
                let size = CGSize(
                    width: field.width < 0 ? field.width : field.width + fieldInsets.left + fieldInsets.right,
                    height: field.height + fieldInsets.top + fieldInsets.bottom,
                )
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

    /// Draws the border on the search field's own layer, on top of whatever the
    /// AppKit bezel paints. Combine with the `none` bezel style for a fully
    /// custom outline.
    private func applyBorder() {
        let radius = cornerRadius ?? 0
        let width = borderWidth ?? 0
        guard radius > 0 || width > 0 || borderColor != nil else {
            // Nothing requested: leave the layer untouched so the plain control
            // keeps its stock focus ring instead of a clipped one.
            searchField.layer?.borderWidth = 0
            searchField.layer?.borderColor = nil
            searchField.layer?.cornerRadius = 0
            searchField.layer?.masksToBounds = false
            return
        }

        searchField.wantsLayer = true
        guard let layer = searchField.layer else { return }
        layer.borderWidth = width
        layer.borderColor = borderColor?.cgColor
        layer.cornerRadius = radius
        // Without this the cell keeps drawing its square background outside the
        // rounded border. The trade-off is a focus ring clipped to the same
        // shape, which is the lesser surprise when a radius was asked for.
        layer.masksToBounds = radius > 0
    }

    /// With a glass effect the glass is the bezel: a bezel style left at its
    /// default resolves to `none`, an explicit one is kept.
    private func applyBezelStyle() {
        let style = CNViewModifierApplicator.resolveStyle(bezelStyle, glassEffect: glassEffect, bezelFreeStyle: "none")
        Self.applyBezelStyle(style, to: searchField)
    }

    private static func applyBezelStyle(_ rawValue: String?, to field: NSSearchField) {
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

    // MARK: - Glass effect

    /// AppKit counterpart of `CNViewModifierApplicator.applyGlassEffect`: on
    /// macOS 26+ the search field becomes the content of an `NSGlassEffectView`,
    /// inset by the glass padding, and the glass is inset by `paddings`. Without
    /// a glass the field is inset by `paddings` only; `identity` keeps the glass
    /// padding but draws no glass, like SwiftUI's `Glass.identity`.
    private func applyGlassEffect() {
        let outer = Self.edgeInsets(paddings)

        guard #available(macOS 26.0, *), let glassEffect else {
            removeGlassView()
            pinSearchField(in: self, insets: outer)
            return
        }

        let inner = Self.edgeInsets(CNPaddingsPayload.fromChannel(glassEffect["padding"] as? [String: Any]))
        guard glassEffect["variant"] as? String != "identity" else {
            removeGlassView()
            pinSearchField(in: self, insets: Self.adding(outer, inner))
            return
        }

        let glass = glassView as? NSGlassEffectView ?? makeGlassView()
        glass.style = glassEffect["variant"] as? String == "clear" ? .clear : .regular
        glass.tintColor = CNChannelDeserialization.decodeInt(glassEffect["tint"]).map(ColorUtils.colorFromARGB)
        // `effectIsInteractive` only exists in the macOS 27 SDK; KVC keeps the
        // plugin building against the macOS 26 one.
        if glass.responds(to: NSSelectorFromString("setEffectIsInteractive:")) {
            glass.setValue(CNChannelDeserialization.decodeBool(glassEffect["interactive"]) == true, forKey: "effectIsInteractive")
        }

        // A shape inset moves the glass edge, not the field: positive values
        // shrink the glass around it, negative ones grow it.
        let shapeInset = CNChannelDeserialization.decodeCGFloat((glassEffect["shape"] as? [String: Any])?["inset"]) ?? 0
        let inset = NSEdgeInsets(top: shapeInset, left: shapeInset, bottom: shapeInset, right: shapeInset)
        Self.pin(glass, in: self, insets: Self.adding(outer, inset), replacing: &glassConstraints)
        pinSearchField(in: glass.contentView!, insets: Self.adding(inner, Self.negated(inset)))
        fieldInsets = Self.adding(outer, inner)

        // Without a bezel of its own the field takes its focus ring from the
        // glass, like the System Settings sidebar search field.
        searchField.searchCell?.focusRingView = searchField.isBezeled ? nil : glass
        needsLayout = true
    }

    @available(macOS 26.0, *)
    private func makeGlassView() -> NSGlassEffectView {
        let glass = NSGlassEffectView()
        glass.translatesAutoresizingMaskIntoConstraints = false
        glass.contentView = NSView()
        addSubview(glass)
        glassView = glass
        return glass
    }

    private func removeGlassView() {
        searchField.searchCell?.focusRingView = nil
        guard let glassView else { return }
        NSLayoutConstraint.deactivate(glassConstraints)
        glassConstraints = []
        glassView.removeFromSuperview()
        self.glassView = nil
    }

    private func pinSearchField(in container: NSView, insets: NSEdgeInsets) {
        Self.pin(searchField, in: container, insets: insets, replacing: &fieldConstraints)
        fieldInsets = insets
    }

    /// `NSGlassEffectView` only has a uniform corner radius, so the glass shape
    /// collapses to one: half the short side for capsules (the default),
    /// circles and ellipses, the largest corner for uneven rectangles.
    private func updateGlassShape() {
        guard #available(macOS 26.0, *), let glass = glassView as? NSGlassEffectView else { return }
        let size = glass.bounds.size
        let maxRadius = min(size.width, size.height) / 2
        let radius = min(Self.glassCornerRadius(glassEffect?["shape"] as? [String: Any]) ?? maxRadius, maxRadius)
        if glass.cornerRadius != radius {
            glass.cornerRadius = radius
        }
        if let cell = searchField.searchCell, cell.focusRingView != nil {
            cell.focusRingCornerRadius = radius
            searchField.noteFocusRingMaskChanged()
        }
    }

    /// The corner radius of a `CNShape` payload, or nil for fully rounded shapes.
    private static func glassCornerRadius(_ shape: [String: Any]?) -> CGFloat? {
        guard let shape else { return nil }
        switch shape["type"] as? String {
        case "rectangle":
            return 0
        case "roundedRectangle":
            if let width = CNChannelDeserialization.decodeCGFloat(shape["cornerWidth"]),
               let height = CNChannelDeserialization.decodeCGFloat(shape["cornerHeight"])
            {
                return min(width, height)
            }
            return CNChannelDeserialization.decodeCGFloat(shape["cornerRadius"]) ?? 8
        case "unevenRoundedRectangle":
            return ["topLeading", "bottomLeading", "bottomTrailing", "topTrailing"]
                .compactMap { CNChannelDeserialization.decodeCGFloat(shape[$0]) }
                .max() ?? 0
        default:
            return nil
        }
    }

    /// Moves `view` into `container` (if needed) and pins its edges with `insets`,
    /// replacing the previous `constraints`.
    private static func pin(
        _ view: NSView,
        in container: NSView,
        insets: NSEdgeInsets,
        replacing constraints: inout [NSLayoutConstraint],
    ) {
        NSLayoutConstraint.deactivate(constraints)
        if view.superview !== container {
            view.removeFromSuperview()
            container.addSubview(view)
        }
        constraints = [
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private static func edgeInsets(_ paddings: CNPaddingsPayload?) -> NSEdgeInsets {
        guard let paddings else { return NSEdgeInsetsZero }
        return NSEdgeInsets(top: paddings.top, left: paddings.leading, bottom: paddings.bottom, right: paddings.trailing)
    }

    private static func adding(_ lhs: NSEdgeInsets, _ rhs: NSEdgeInsets) -> NSEdgeInsets {
        NSEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }

    private static func negated(_ insets: NSEdgeInsets) -> NSEdgeInsets {
        NSEdgeInsets(top: -insets.top, left: -insets.left, bottom: -insets.bottom, right: -insets.right)
    }
}

/// `NSSearchField` drawn by a `CNSearchFieldCell`.
private final class CNSearchFieldControl: NSSearchField {
    override class var cellClass: AnyClass? {
        get { CNSearchFieldCell.self }
        set {}
    }

    var searchCell: CNSearchFieldCell? {
        cell as? CNSearchFieldCell
    }
}

/// Fixes how a search field without a bezel edits and shows focus.
///
/// AppKit hands such a field's editor the whole cell frame, so the text being
/// edited slides under the magnifier; editing inside `searchTextRect(forBounds:)`
/// keeps it where the idle text is drawn. When `focusRingView` is set (the glass
/// the field sits in), the focus ring outlines that view instead of the bare
/// text rect.
private final class CNSearchFieldCell: NSSearchFieldCell {
    weak var focusRingView: NSView?
    var focusRingCornerRadius: CGFloat = 0

    override func edit(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        event: NSEvent?,
    ) {
        super.edit(withFrame: editingRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    override func select(
        withFrame rect: NSRect,
        in controlView: NSView,
        editor textObj: NSText,
        delegate: Any?,
        start selStart: Int,
        length selLength: Int,
    ) {
        super.select(
            withFrame: editingRect(forBounds: rect),
            in: controlView,
            editor: textObj,
            delegate: delegate,
            start: selStart,
            length: selLength,
        )
    }

    override func focusRingMaskBounds(forFrame cellFrame: NSRect, in controlView: NSView) -> NSRect {
        focusRingRect(in: controlView) ?? super.focusRingMaskBounds(forFrame: cellFrame, in: controlView)
    }

    override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
        guard let rect = focusRingRect(in: controlView) else {
            super.drawFocusRingMask(withFrame: cellFrame, in: controlView)
            return
        }
        let radius = min(focusRingCornerRadius, rect.width / 2, rect.height / 2)
        NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
    }

    private func editingRect(forBounds rect: NSRect) -> NSRect {
        isBezeled ? rect : searchTextRect(forBounds: rect)
    }

    private func focusRingRect(in controlView: NSView) -> NSRect? {
        guard let focusRingView else { return nil }
        return controlView.convert(focusRingView.bounds, from: focusRingView)
    }
}

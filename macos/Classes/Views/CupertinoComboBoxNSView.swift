import Cocoa
import FlutterMacOS

class CupertinoComboBoxNSView: NSView, NSComboBoxDelegate, NSComboBoxDataSource {
    private let channel: FlutterMethodChannel
    private let comboBox = NSComboBox(frame: .zero)
    private var items: [String] = []
    private var isUpdatingFromDart = false
    private var debugLog = false

    private func log(_ message: String) {
        guard debugLog else { return }
        NSLog("[CupertinoComboBoxNSView] \(message)")
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeComboBox_\(viewId)",
            binaryMessenger: messenger,
        )
        super.init(frame: .zero)

        setupComboBox()
        applyArgs(args)
        configureChannel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupComboBox() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        comboBox.usesDataSource = true
        comboBox.dataSource = self
        comboBox.delegate = self
        comboBox.hasVerticalScroller = true

        comboBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(comboBox)
        NSLayoutConstraint.activate([
            comboBox.leadingAnchor.constraint(equalTo: leadingAnchor),
            comboBox.trailingAnchor.constraint(equalTo: trailingAnchor),
            comboBox.topAnchor.constraint(equalTo: topAnchor),
            comboBox.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Payload handling

    private func applyArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }
        applyPayload(args)
    }

    private func applyPayload(_ args: [String: Any]) {
        if let value = args["debugLog"] as? Bool {
            debugLog = value
        }

        if let newItems = args["items"] as? [String] {
            items = newItems
            comboBox.reloadData()
        }

        if let text = args["text"] as? String {
            isUpdatingFromDart = true
            comboBox.stringValue = text
            isUpdatingFromDart = false
        }

        if let placeholder = args["placeholder"] as? String {
            comboBox.placeholderString = placeholder
        } else if args.keys.contains("placeholder") {
            comboBox.placeholderString = nil
        }

        if let textColor = args["textColor"] as? Int {
            comboBox.textColor = ColorUtils.colorFromARGB(textColor)
        } else if args.keys.contains("textColor") {
            comboBox.textColor = nil
        }

        if let fontDict = args["font"] as? [String: Any],
           let font = FontUtils.fontFromDictionary(fontDict)
        {
            comboBox.font = font
        }

        if let controlSize = args["controlSize"] as? String {
            comboBox.controlSize = ControlSizeUtils.controlSizeFromString(controlSize)
        }

        if let numberOfVisibleItems = args["numberOfVisibleItems"] as? Int {
            comboBox.numberOfVisibleItems = numberOfVisibleItems
        }

        if let completes = args["completes"] as? Bool {
            comboBox.completes = completes
        }

        if let enabled = args["enabled"] as? Bool {
            comboBox.isEnabled = enabled
        }
    }

    // MARK: - Channel

    private func configureChannel() {
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
                let size = comboBox.intrinsicContentSize
                log("getIntrinsicSize -> \(size)")
                result(["width": Double(size.width), "height": Double(size.height)])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - NSComboBoxDataSource

    func numberOfItems(in _: NSComboBox) -> Int {
        items.count
    }

    func comboBox(_: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    func comboBox(_: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        items.firstIndex(of: string) ?? NSNotFound
    }

    func comboBox(_: NSComboBox, completedString string: String) -> String? {
        items.first { $0.lowercased().hasPrefix(string.lowercased()) }
    }

    // MARK: - NSComboBoxDelegate

    func comboBoxSelectionDidChange(_: Notification) {
        guard !isUpdatingFromDart else { return }
        let index = comboBox.indexOfSelectedItem
        log("selectionChanged: \(index)")
        channel.invokeMethod("selectionChanged", arguments: index)

        if index >= 0, index < items.count {
            let text = items[index]
            log("textChanged (from selection): \(text)")
            channel.invokeMethod("textChanged", arguments: text)
        }
    }

    func controlTextDidChange(_: Notification) {
        guard !isUpdatingFromDart else { return }
        let text = comboBox.stringValue
        log("textChanged: \(text)")
        channel.invokeMethod("textChanged", arguments: text)
    }
}

import Cocoa
import FlutterMacOS

class CupertinoColorWell2NSView: NSView {
    private let channel: FlutterMethodChannel
    private let colorWell: NSColorWell

    private var enabled: Bool = true
    private var supportsAlpha: Bool = true
    private var style: NSColorWell.Style = .default

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeColorWell2_\(viewId)", binaryMessenger: messenger,
        )
        colorWell = NSColorWell()
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        colorWell.target = self
        colorWell.action = #selector(colorWellChanged(_:))
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        addSubview(colorWell)
        NSLayoutConstraint.activate([
            colorWell.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorWell.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorWell.topAnchor.constraint(equalTo: topAnchor),
            colorWell.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let dict = CNChannelDeserialization.asDict(args) {
            applyPayload(dict)
        }

        configureMethodChannel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureMethodChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "getIntrinsicSize":
                let size = colorWell.intrinsicContentSize
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setData":
                if let dict = CNChannelDeserialization.asDict(call.arguments) {
                    applyPayload(dict)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let dict = CNChannelDeserialization.asDict(call.arguments) {
                    applyPayload(dict)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func applyPayload(_ dict: [String: Any]) {
        if dict.keys.contains("color") {
            if let colorValue = CNChannelDeserialization.decodeInt(dict["color"]) {
                colorWell.color = ColorUtils.colorFromARGB(colorValue)
            }
        }

        if dict.keys.contains("enabled") {
            enabled = CNChannelDeserialization.decodeBool(dict["enabled"]) ?? true
            colorWell.isEnabled = enabled
        }

        if dict.keys.contains("supportsAlpha") {
            supportsAlpha = CNChannelDeserialization.decodeBool(dict["supportsAlpha"]) ?? true
            colorWell.supportsAlpha = supportsAlpha
        }

        if dict.keys.contains("style") {
            let styleName = CNChannelDeserialization.decodeString(dict["style"])
            switch styleName {
            case "minimal":
                style = .minimal
            case "expanded":
                style = .expanded
            default:
                style = .default
            }
            colorWell.colorWellStyle = style
        }
    }

    @objc private func colorWellChanged(_ sender: NSColorWell) {
        let colorValue = ColorUtils.colorToArgb(sender.color)
        channel.invokeMethod("colorChanged", arguments: colorValue)
    }
}

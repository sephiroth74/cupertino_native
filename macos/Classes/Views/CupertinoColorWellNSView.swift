import Cocoa
import FlutterMacOS

class CupertinoColorWellNSView: NSView {
    private let channel: FlutterMethodChannel
    private let colorWell: NSColorWell
    private var payload: CNColorWellPayload?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeColorWell_\(viewId)", binaryMessenger: messenger,
        )
        colorWell = NSColorWell()
        payload = CNColorWellDeserializer.decode(args)
        super.init(frame: .zero)

        setupColorWell()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupColorWell() {
        colorWell.target = self
        colorWell.action = #selector(colorWellChanged(_:))

        addSubview(colorWell)
        colorWell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorWell.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorWell.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorWell.topAnchor.constraint(equalTo: topAnchor),
            colorWell.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let payload {
            CNColorWellDeserializer.apply(payload: payload, to: colorWell, in: self)
        }

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }
            switch call.method {
            case "getIntrinsicSize":
                let s = colorWell.intrinsicContentSize
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setColorWell":
                if let parsed: CNColorWellPayload = CNChannelSerialization.decode(call.arguments) {
                    payload = parsed
                    CNColorWellDeserializer.apply(payload: parsed, to: colorWell, in: self)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid color well payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func colorWellChanged(_ sender: NSColorWell) {
        let colorValue = ColorUtils.colorToArgb(sender.color)
        channel.invokeMethod("colorChanged", arguments: colorValue)
    }

    override func layout() {
        super.layout()
        colorWell.frame = bounds
    }
}

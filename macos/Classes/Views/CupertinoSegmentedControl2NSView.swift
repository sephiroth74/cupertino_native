import Cocoa
import FlutterMacOS

class CupertinoSegmentedControl2NSView: NSView {
    let channel: FlutterMethodChannel
    private let control: NSSegmentedControl
    private var payload: CNSegmentedControl2Payload

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativeSegmentedControl2_\(viewId)", binaryMessenger: messenger)
        control = NSSegmentedControl(labels: [], trackingMode: .selectOne, target: nil, action: nil)
        payload = CNSegmentedControl2Payload(viewId: viewId)

        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        control.target = self
        control.action = #selector(onChanged(_:))
        control.translatesAutoresizingMaskIntoConstraints = false
        addSubview(control)

        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: leadingAnchor),
            control.trailingAnchor.constraint(equalTo: trailingAnchor),
            control.topAnchor.constraint(equalTo: topAnchor),
            control.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if let dict = CNChannelSerialization.asDict(args) {
            payload.applyPatch(dict)
        }
        applyPayload()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Method Channel

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setData":
            if let dict = CNChannelSerialization.asDict(call.arguments) {
                payload = CNSegmentedControl2Payload(viewId: 0)
                payload.applyPatch(dict)
                applyPayload()
            }
            result(nil)
        case "applyPatch":
            if let dict = CNChannelSerialization.asDict(call.arguments) {
                payload.applyPatch(dict)
                applyPayload()
            }
            result(nil)
        case "getIntrinsicSize":
            let size = control.intrinsicContentSize
            result(["width": Double(size.width), "height": Double(size.height)])
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Apply payload to control

    private func applyPayload() {
        let labels = payload.labels ?? []
        let symbols = payload.symbols ?? []
        let count = max(labels.count, symbols.count)

        control.segmentCount = count

        for i in 0 ..< count {
            if !symbols.isEmpty, i < symbols.count {
                if let image = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
                    control.setImage(image, forSegment: i)
                    control.setLabel("", forSegment: i)
                } else {
                    control.setImage(nil, forSegment: i)
                    control.setLabel(symbols[i], forSegment: i)
                }
            } else if i < labels.count {
                control.setImage(nil, forSegment: i)
                control.setLabel(labels[i], forSegment: i)
            }
        }

        if payload.selectedIndex >= 0, payload.selectedIndex < count {
            control.selectedSegment = payload.selectedIndex
        }

        control.isEnabled = payload.enabled

        // Constraints: when shrink=false, expand to fill
        control.setContentHuggingPriority(
            payload.shrink ? .defaultHigh : .defaultLow,
            for: .horizontal,
        )

        notifyIntrinsicSizeChanged()
    }

    private func notifyIntrinsicSizeChanged() {
        let size = control.intrinsicContentSize
        channel.invokeMethod("intrinsicSizeChanged", arguments: [
            "width": Double(size.width),
            "height": Double(size.height),
        ])
    }

    // MARK: - Action

    @objc private func onChanged(_ sender: NSSegmentedControl) {
        payload.selectedIndex = sender.selectedSegment
        channel.invokeMethod("valueChanged", arguments: ["index": sender.selectedSegment])
    }
}

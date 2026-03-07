import Cocoa
import FlutterMacOS

class CupertinoStepperNSView: NSView {
    private let channel: FlutterMethodChannel
    private let stepper: NSStepper = NSStepper()

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeStepper_\(viewId)",
            binaryMessenger: messenger)

        let stepper = self.stepper

        var initialValue: Double = 0
        var minValue: Double = 0
        var maxValue: Double = 100
        var increment: Double = 1
        var isEnabled: Bool = true
        var isAutorepeat: Bool = true
        var valueWraps: Bool = false
        var isDark: Bool = false
        var controlSize: NSControl.ControlSize = .regular

        if let dict = args as? [String: Any] {
            if let v = dict["value"] as? NSNumber { initialValue = v.doubleValue }
            if let v = dict["min"] as? NSNumber { minValue = v.doubleValue }
            if let v = dict["max"] as? NSNumber { maxValue = v.doubleValue }
            if let v = dict["step"] as? NSNumber { increment = v.doubleValue }
            if let v = dict["isEnabled"] as? NSNumber { isEnabled = v.boolValue }
            if let v = dict["isAutorepeat"] as? NSNumber { isAutorepeat = v.boolValue }
            if let v = dict["valueWraps"] as? NSNumber { valueWraps = v.boolValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let v = dict["controlSize"] as? String {
                controlSize = ControlSizeUtils.controlSizeFromString(v)
            }
        }

        super.init(frame: .zero)

        stepper.minValue = minValue
        stepper.maxValue = maxValue
        stepper.increment = increment
        stepper.doubleValue = initialValue
        stepper.isEnabled = isEnabled
        stepper.autorepeat = isAutorepeat
        stepper.valueWraps = valueWraps
        stepper.controlSize = controlSize

        stepper.wantsLayer = true
        stepper.layer?.backgroundColor = NSColor.clear.cgColor
        stepper.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        stepper.target = self
        stepper.action = #selector(onStepperValueChanged(_:))

        addSubview(stepper)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepper.leadingAnchor.constraint(equalTo: leadingAnchor),
            stepper.trailingAnchor.constraint(equalTo: trailingAnchor),
            stepper.topAnchor.constraint(equalTo: topAnchor),
            stepper.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getIntrinsicSize":
                let size = stepper.intrinsicContentSize
                result(["width": size.width, "height": size.height])
            case "setValue":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.doubleValue
                {
                    if value >= stepper.minValue && value <= stepper.maxValue {
                        stepper.doubleValue = value
                        result(nil)
                    } else {
                        result(
                            FlutterError(
                                code: "bad_args", message: "Value out of range", details: nil))
                    }
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setRange":
                if let args = call.arguments as? [String: Any],
                    let min = (args["min"] as? NSNumber)?.doubleValue,
                    let max = (args["max"] as? NSNumber)?.doubleValue
                {
                    stepper.minValue = min
                    stepper.maxValue = max
                    if stepper.doubleValue < min { stepper.doubleValue = min }
                    if stepper.doubleValue > max { stepper.doubleValue = max }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing min/max", details: nil))
                }
            case "setIncrement":
                if let args = call.arguments as? [String: Any],
                    let increment = (args["value"] as? NSNumber)?.doubleValue
                {
                    stepper.increment = increment
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsEnabled":
                if let args = call.arguments as? [String: Any],
                    let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    stepper.isEnabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsAutorepeat":
                if let args = call.arguments as? [String: Any],
                    let isAutorepeat = (args["value"] as? NSNumber)?.boolValue
                {
                    stepper.autorepeat = isAutorepeat
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setValueWraps":
                if let args = call.arguments as? [String: Any],
                    let valueWraps = (args["value"] as? NSNumber)?.boolValue
                {
                    stepper.valueWraps = valueWraps
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                    let isDark = (args["value"] as? NSNumber)?.boolValue
                {
                    stepper.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setControlSize":
                if let args = call.arguments as? [String: Any],
                    let size = args["value"] as? String
                {
                    stepper.controlSize = ControlSizeUtils.controlSizeFromString(size)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        self.postsFrameChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewSizeChanged),
            name: NSView.frameDidChangeNotification,
            object: self
        )
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)

        if newWindow == nil {
            self.postsFrameChangedNotifications = false
            NotificationCenter.default.removeObserver(
                self, name: NSView.frameDidChangeNotification, object: self)
        }

    }

    @objc func viewSizeChanged(_ notification: Notification) {
        let size = stepper.intrinsicContentSize

        channel.invokeMethod(
            "intrinsicSizeChanged", arguments: ["width": size.width, "height": size.height])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    @objc func onStepperValueChanged(_ sender: NSStepper) {
        channel.invokeMethod("valueChanged", arguments: ["value": sender.doubleValue])
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoProgressIndicatorNSView: NSView {
    private let channel: FlutterMethodChannel
    private let progressIndicator: NSProgressIndicator
    private var currentProgressStyle: String = "spinning"
    private var currentProgressSize: String = "regular"
    private var currentProgressValue: Double = 0.0
    private var currentProgressMaxValue: Double = 1.0
    private var currentProgressIndeterminate: Bool = false

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.progressIndicator = NSProgressIndicator()
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeProgressIndicator_\(viewId)", binaryMessenger: messenger
        )
        super.init(frame: .zero)

        var progressStyle: String = "spinning"
        var progressSize: String = "regular"
        var progressValue: Double = 0.0
        var progressMaxValue: Double = 1.0
        var progressIndeterminate: Bool = false
        var isDark: Bool = false

        if let dict = args as? [String: Any] {
            if let ps = dict["progressStyle"] as? String { progressStyle = ps }
            if let ps = dict["progressSize"] as? String { progressSize = ps }
            if let pv = dict["progressValue"] as? Double { progressValue = pv }
            if let pmv = dict["progressMaxValue"] as? Double { progressMaxValue = pmv }
            if let pi = dict["progressIndeterminate"] as? Bool { progressIndeterminate = pi }
            if let pd = dict["isDark"] as? Bool { isDark = pd }
        }

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        switch progressStyle {
        case "spinning": progressIndicator.style = .spinning
        case "bar": progressIndicator.style = .bar
        default: progressIndicator.style = .spinning
        }

        switch progressSize {
        case "mini": progressIndicator.controlSize = .mini
        case "small": progressIndicator.controlSize = .small
        case "regular": progressIndicator.controlSize = .regular
        case "large": progressIndicator.controlSize = .large
        case "extraLarge":
            progressIndicator.controlSize =
                if #available(macOS 26.0, *) {
                    .extraLarge
                } else {
                    .large
                }
        default: progressIndicator.controlSize = .regular
        }

        progressIndicator.isIndeterminate = progressIndeterminate
        progressIndicator.doubleValue = progressValue
        progressIndicator.maxValue = progressMaxValue

        currentProgressStyle = progressStyle
        currentProgressSize = progressSize
        currentProgressValue = progressValue
        currentProgressMaxValue = progressMaxValue
        currentProgressIndeterminate = progressIndeterminate

        addSubview(progressIndicator)
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressIndicator.topAnchor.constraint(equalTo: topAnchor),
            progressIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        _setupChannel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {
    }

    override func viewWillMove(toSuperview newSuperview: NSView?) {
        if newSuperview == nil {
            progressIndicator.stopAnimation(nil)
        } else {
            if currentProgressIndeterminate {
                progressIndicator.startAnimation(nil)
            }
        }
    }

    private func _setupChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }
            switch call.method {
            case "startAnimation":
                self.progressIndicator.startAnimation(nil)
                result(nil)
            case "stopAnimation":
                self.progressIndicator.stopAnimation(nil)
                result(nil)
            case "getIntrinsicSize":
                let s = self.progressIndicator.intrinsicContentSize
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setBrightness":
                if let args = call.arguments as? [String: Any],
                    let isDark = (args["isDark"] as? NSNumber)?.boolValue
                {
                    self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }
            case "updateProgress":
                if let args = call.arguments as? [String: Any] {
                    if let progressStyle = args["progressStyle"] as? String {
                        self.currentProgressStyle = progressStyle
                        switch progressStyle {
                        case "spinning": self.progressIndicator.style = .spinning
                        case "bar": self.progressIndicator.style = .bar
                        default: self.progressIndicator.style = .spinning
                        }
                    }
                    if let progressSize = args["progressSize"] as? String {
                        self.currentProgressSize = progressSize
                        switch progressSize {
                        case "mini": self.progressIndicator.controlSize = .mini
                        case "small": self.progressIndicator.controlSize = .small
                        case "regular": self.progressIndicator.controlSize = .regular
                        case "large": self.progressIndicator.controlSize = .large
                        case "extraLarge":
                            self.progressIndicator.controlSize =
                                if #available(macOS 26.0, *) {
                                    .extraLarge
                                } else {
                                    .large
                                }
                        default: self.progressIndicator.controlSize = .regular
                        }
                    }
                    if let progressValue = args["progressValue"] as? Double {
                        self.currentProgressValue = progressValue
                        self.progressIndicator.doubleValue = progressValue
                    }
                    if let progressMaxValue = args["progressMaxValue"] as? Double {
                        self.currentProgressMaxValue = progressMaxValue
                        self.progressIndicator.maxValue = progressMaxValue
                    }
                    if let progressIndeterminate = args["progressIndeterminate"] as? Bool {
                        self.currentProgressIndeterminate = progressIndeterminate
                        self.progressIndicator.isIndeterminate = progressIndeterminate
                    }
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoLevelIndicatorNSView: NSView {
    private let channel: FlutterMethodChannel
    @objc let model: RangeModel = RangeModel()

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeLevelIndicator_\(viewId)", binaryMessenger: messenger)

        let levelIndicator = NSLevelIndicator()

        var initialValue: Double = 0
        var minValue: Double = 0
        var maxValue: Double = 1
        var warningValue: Double? = nil
        var criticalValue: Double? = nil
        var isEnabled: Bool = true
        var isEditable: Bool = true
        var isContinuous: Bool = true
        var isDark: Bool = false
        var fillColor: NSColor? = nil
        var warningColor: NSColor? = nil
        var criticalColor: NSColor? = nil
        var levelIndicatorStyle: NSLevelIndicator.Style = .continuousCapacity

        if let dict = args as? [String: Any] {
            if let v = dict["value"] as? NSNumber { initialValue = v.doubleValue }
            if let v = dict["min"] as? NSNumber { minValue = v.doubleValue }
            if let v = dict["max"] as? NSNumber { maxValue = v.doubleValue }
            if let v = dict["isEnabled"] as? NSNumber { isEnabled = v.boolValue }
            if let v = dict["isEditable"] as? NSNumber { isEditable = v.boolValue }
            if let v = dict["isContinuous"] as? NSNumber { isContinuous = v.boolValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let v = dict["levelIndicatorStyle"] as? String {
                levelIndicatorStyle = Self.levelIndicatorStyleFromString(v)
            }
            if let v = dict["fillColor"] as? NSNumber {
                fillColor = ColorUtils.colorFromARGB(v.intValue)
            }
            if let v = dict["warningColor"] as? NSNumber {
                warningColor = ColorUtils.colorFromARGB(v.intValue)
            }
            if let v = dict["criticalColor"] as? NSNumber {
                criticalColor = ColorUtils.colorFromARGB(v.intValue)
            }
            if let v = dict["warningValue"] as? NSNumber { warningValue = v.doubleValue }
            if let v = dict["criticalValue"] as? NSNumber { criticalValue = v.doubleValue }
        }

        super.init(frame: .zero)

        self.model.updateValues(minValue: minValue, maxValue: maxValue, value: initialValue)

        levelIndicator.bind(.value, to: self.model, withKeyPath: "value", options: nil)
        levelIndicator.bind(.minValue, to: self.model, withKeyPath: "minValue", options: nil)
        levelIndicator.bind(.maxValue, to: self.model, withKeyPath: "maxValue", options: nil)

        self.model.onChange = { value in
            self.channel.invokeMethod("valueChanged", arguments: ["value": value])
        }

        levelIndicator.isEnabled = isEnabled
        levelIndicator.isEditable = isEditable
        levelIndicator.isContinuous = isContinuous
        levelIndicator.levelIndicatorStyle = levelIndicatorStyle

        if let fillColor = fillColor {
            levelIndicator.fillColor = fillColor
        }
        if let warningColor = warningColor {
            levelIndicator.warningFillColor = warningColor
        }
        if let criticalColor = criticalColor {
            levelIndicator.criticalFillColor = criticalColor
        }
        if let warningValue = warningValue {
            levelIndicator.warningValue = warningValue
        }
        if let criticalValue = criticalValue {
            levelIndicator.criticalValue = criticalValue
        }

        levelIndicator.wantsLayer = true
        levelIndicator.layer?.backgroundColor = NSColor.clear.cgColor
        levelIndicator.target = self
        levelIndicator.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        addSubview(levelIndicator)
        levelIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            levelIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            levelIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            levelIndicator.topAnchor.constraint(equalTo: topAnchor),
            levelIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getIntrinsicSize":
                let size = levelIndicator.intrinsicContentSize
                result(["width": size.width, "height": size.height])
            case "updateRange":
                if let args = call.arguments as? [String: Any],
                    let min = (args["min"] as? NSNumber)?.doubleValue,
                    let max = (args["max"] as? NSNumber)?.doubleValue
                {
                    self.model.updateRange(minValue: min, maxValue: max)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing min/max", details: nil))
                }
            case "setValue":
                if let args = call.arguments as? [String: Any],
                    let value = (args["value"] as? NSNumber)?.doubleValue
                {
                    if value >= self.model.minValue && value <= self.model.maxValue {
                        self.model.value = value
                        result(nil)
                    } else {
                        result(
                            FlutterError(
                                code: "bad_args", message: "Value out of range", details: nil))
                    }
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsEnabled":
                if let args = call.arguments as? [String: Any],
                    let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    levelIndicator.isEnabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsEditable":
                if let args = call.arguments as? [String: Any],
                    let editable = (args["value"] as? NSNumber)?.boolValue
                {
                    levelIndicator.isEditable = editable
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsContinuous":
                if let args = call.arguments as? [String: Any],
                    let continuous = (args["value"] as? NSNumber)?.boolValue
                {
                    levelIndicator.isContinuous = continuous
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                    let isDark = (args["value"] as? NSNumber)?.boolValue
                {
                    levelIndicator.appearance =
                        NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setLevelIndicatorStyle":
                if let args = call.arguments as? [String: Any],
                    let styleStr = args["value"] as? String
                {
                    levelIndicator.levelIndicatorStyle =
                        Self.levelIndicatorStyleFromString(styleStr)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setFillColor":
                if let args = call.arguments as? [String: Any],
                    let fillColorNum = args["value"] as? NSNumber
                {
                    levelIndicator.fillColor = ColorUtils.colorFromARGB(fillColorNum.intValue)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setWarningColor":
                if let args = call.arguments as? [String: Any],
                    let warningColorNum = args["value"] as? NSNumber
                {
                    levelIndicator.warningFillColor = ColorUtils.colorFromARGB(warningColorNum.intValue)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setCriticalColor":
                if let args = call.arguments as? [String: Any],
                    let criticalColorNum = args["value"] as? NSNumber
                {
                    levelIndicator.criticalFillColor = ColorUtils.colorFromARGB(
                        criticalColorNum.intValue)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setWarningValue":
                if let args = call.arguments as? [String: Any],
                    let warningValue = (args["value"] as? NSNumber)?.doubleValue
                {
                    levelIndicator.warningValue = warningValue
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            case "setCriticalValue":
                if let args = call.arguments as? [String: Any],
                    let criticalValue = (args["value"] as? NSNumber)?.doubleValue
                {
                    levelIndicator.criticalValue = criticalValue
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func levelIndicatorStyleFromString(_ str: String) -> NSLevelIndicator.Style {
        switch str {
        case "continuousCapacity": return .continuousCapacity
        case "discreteCapacity": return .discreteCapacity
        case "rating": return .rating
        case "relevancy": return .relevancy
        default: return .continuousCapacity
        }
    }
}

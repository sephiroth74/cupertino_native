import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoDatePickerNSView: NSView {
    private let channel: FlutterMethodChannel
    private let datePicker: NSDatePicker = .init()

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeDatePicker_\(viewId)", binaryMessenger: messenger
        )
        super.init(frame: .zero)

        var datePickerStyle: NSDatePicker.Style = .textField
        var datePickerMode: NSDatePicker.Mode = .single
        var datePickerElements: NSDatePicker.ElementFlags = [.yearMonthDay]
        var isBordered = false
        var dateValue: Date? = nil
        var drawsBackground = true
        var isDark = false
        var backgroundColor = NSColor.controlBackgroundColor
        var textColor = NSColor.controlTextColor
        var minDate: Date? = nil
        var maxDate: Date? = nil
        var font: NSFont? = nil
        var locale: Locale? = nil
        var isEnabled = true

        if let dict = args as? [String: Any] {
            if let styleStr = dict["datePickerStyle"] as? String {
                datePickerStyle = Self.datePickerStyleFromString(styleStr)
            }
            if let modeStr = dict["datePickerMode"] as? String {
                datePickerMode = Self.datePickerModeFromString(modeStr)
            }
            if let elementsArr = dict["datePickerElements"] as? [String] {
                datePickerElements = Self.datePickerElementsFromStrings(elementsArr)
            }
            if let v = dict["isBordered"] as? Bool { isBordered = v }
            if let v = dict["dateValue"] as? TimeInterval {
                dateValue = Date(timeIntervalSince1970: v / 1000)
            }
            if let v = dict["drawsBackground"] as? Bool { drawsBackground = v }
            if let v = dict["isDark"] as? Bool { isDark = v }
            if let v = dict["backgroundColor"] as? Int {
                backgroundColor = ColorUtils.colorFromARGB(v)
            }
            if let v = dict["textColor"] as? Int {
                textColor = ColorUtils.colorFromARGB(v)
            }
            if let v = dict["minDate"] as? TimeInterval {
                minDate = Date(timeIntervalSince1970: v / 1000)
            }
            if let v = dict["maxDate"] as? TimeInterval {
                maxDate = Date(timeIntervalSince1970: v / 1000)
            }
            if let fontDict = dict["font"] as? [String: Any] {
                font = FontUtils.fontFromDictionary(fontDict)
            }
            if let localeStr = dict["locale"] as? String {
                locale = Locale(identifier: localeStr)
            }
            if let v = dict["isEnabled"] as? Bool { isEnabled = v }
        }

        datePicker.datePickerStyle = datePickerStyle
        datePicker.datePickerMode = datePickerMode
        datePicker.datePickerElements = datePickerElements
        datePicker.isBordered = isBordered
        datePicker.dateValue = dateValue ?? Date()
        datePicker.drawsBackground = drawsBackground
        datePicker.backgroundColor = backgroundColor
        datePicker.textColor = textColor
        datePicker.minDate = minDate
        datePicker.maxDate = maxDate
        datePicker.locale = locale
        datePicker.isEnabled = isEnabled
        datePicker.font =
            font
                ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.regular)

        datePicker.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        datePicker.target = self
        datePicker.action = #selector(dateChanged)

        addSubview(datePicker)

        datePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        channel.setMethodCallHandler { call, result in
            NSLog(
                "Received method call: \(call.method)"
            )
            switch call.method {
            case "getIntrinsicSize":
                let size = self.datePicker.intrinsicContentSize
                result(["width": size.width, "height": size.height])

            case "setIsDark":
                if let args = call.arguments as? [String: Any],
                   let isDark = (args["value"] as? NSNumber)?.boolValue
                {
                    self.datePicker.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }

            case "setIsEnabled":
                if let args = call.arguments as? [String: Any],
                   let enabled = (args["value"] as? NSNumber)?.boolValue
                {
                    self.datePicker.isEnabled = enabled
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
                }

            case "setDatePickerStyle":
                if let args = call.arguments as? [String: Any],
                   let styleStr = args["value"] as? String
                {
                    self.datePicker.datePickerStyle = Self.datePickerStyleFromString(styleStr)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }

            case "setDatePickerElements":
                if let args = call.arguments as? [String: Any],
                   let elementsArr = args["value"] as? [String]
                {
                    self.datePicker.datePickerElements =
                        Self.datePickerElementsFromStrings(elementsArr)
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing elements", details: nil)
                    )
                }

            case "setFont":
                if let args = call.arguments as? [String: Any],
                   let fontDict = args["value"] as? [String: Any],
                   let font = FontUtils.fontFromDictionary(fontDict)
                {
                    self.datePicker.font = font
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing font", details: nil))
                }

            case "setBackgroundColor":
                if let args = call.arguments as? [String: Any],
                   let colorInt = args["value"] as? Int
                {
                    self.datePicker.backgroundColor = ColorUtils.colorFromARGB(colorInt)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing color", details: nil))
                }

            case "setTextColor":
                if let args = call.arguments as? [String: Any],
                   let colorInt = args["value"] as? Int
                {
                    self.datePicker.textColor = ColorUtils.colorFromARGB(colorInt)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing color", details: nil))
                }

            case "setMinDate":
                if let args = call.arguments as? [String: Any],
                   let timestamp = args["value"] as? TimeInterval
                {
                    self.datePicker.minDate = Date(timeIntervalSince1970: timestamp / 1000)
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing timestamp", details: nil)
                    )
                }

            case "setMaxDate":
                if let args = call.arguments as? [String: Any],
                   let timestamp = args["value"] as? TimeInterval
                {
                    self.datePicker.maxDate = Date(timeIntervalSince1970: timestamp / 1000)
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing timestamp", details: nil)
                    )
                }

            case "setLocale":
                if let args = call.arguments as? [String: Any],
                   let localeStr = args["value"] as? String
                {
                    self.datePicker.locale = Locale(identifier: localeStr)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing locale", details: nil))
                }

            case "setIsBordered":
                if let args = call.arguments as? [String: Any],
                   let bordered = (args["value"] as? NSNumber)?.boolValue
                {
                    self.datePicker.isBordered = bordered
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing bordered", details: nil)
                    )
                }

            case "setDrawsBackground":
                if let args = call.arguments as? [String: Any],
                   let draws = (args["value"] as? NSNumber)?.boolValue
                {
                    self.datePicker.drawsBackground = draws
                    result(nil)
                } else {
                    result(
                        FlutterError(
                            code: "bad_args", message: "Missing drawsBackground", details: nil
                        )
                    )
                }

            case "setDateValue":
                if let args = call.arguments as? [String: Any],
                   let timestamp = args["value"] as? TimeInterval
                {
                    self.datePicker.dateValue = Date(timeIntervalSince1970: timestamp / 1000)
                    result(nil)
                } else {
                    result(
                        FlutterError(code: "bad_args", message: "Missing timestamp", details: nil)
                    )
                }

            case "setDatePickerMode":
                if let args = call.arguments as? [String: Any],
                   let modeStr = args["value"] as? String
                {
                    self.datePicker.datePickerMode = Self.datePickerModeFromString(modeStr)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing mode", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dateChanged() {
        let date = datePicker.dateValue
        let interval = datePicker.timeInterval

        let timestamp = date.timeIntervalSince1970 * 1000
        let intervalMs = interval * 1000

        channel.invokeMethod(
            "onDateChanged", arguments: ["timestamp": timestamp, "interval": intervalMs]
        )
    }

    private static func datePickerModeFromString(_ mode: String) -> NSDatePicker.Mode {
        switch mode {
        case "range":
            return NSDatePicker.Mode.range
        default:
            return NSDatePicker.Mode.single
        }
    }

    private static func datePickerStyleFromString(_ style: String) -> NSDatePicker.Style {
        switch style {
        case "clockAndCalendar":
            return NSDatePicker.Style.clockAndCalendar
        case "textFieldAndStepper":
            return NSDatePicker.Style.textFieldAndStepper
        case "textField":
            return NSDatePicker.Style.textField
        default:
            return NSDatePicker.Style.clockAndCalendar
        }
    }

    private static func datePickerElementsFromStrings(_ elements: [String])
        -> NSDatePicker.ElementFlags
    {
        var result: NSDatePicker.ElementFlags = []
        for element in elements {
            if let flag = datePickerElementFromString(element) {
                result.insert(flag)
            }
        }
        return result
    }

    private static func datePickerElementFromString(_ element: String) -> NSDatePicker.ElementFlags? {
        switch element {
        case "hourMinute":
            return NSDatePicker.ElementFlags.hourMinute
        case "hourMinuteSecond":
            return NSDatePicker.ElementFlags.hourMinuteSecond
        case "timeZone":
            return NSDatePicker.ElementFlags.timeZone
        case "yearMonth":
            return NSDatePicker.ElementFlags.yearMonth
        case "yearMonthDay":
            return NSDatePicker.ElementFlags.yearMonthDay
        case "era":
            return NSDatePicker.ElementFlags.era
        default:
            return nil
        }
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoDatePickerNSView: NSView {
    private let channel: FlutterMethodChannel
    private let datePicker: NSDatePicker = NSDatePicker()

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(
            name: "CupertinoNativeDatePicker_\(viewId)", binaryMessenger: messenger)
        super.init(frame: .zero)

        var datePickerStyle: NSDatePicker.Style = .textField
        var datePickerMode: NSDatePicker.Mode = .single
        var datePickerElements: NSDatePicker.ElementFlags = [.yearMonthDay]
        var isBordered: Bool = false
        var dateValue: Date? = nil
        var drawsBackground: Bool = true
        var isDark: Bool = false
        var backgroundColor: NSColor = NSColor.controlBackgroundColor
        var textColor: NSColor = NSColor.controlTextColor
        var minDate: Date? = nil
        var maxDate: Date? = nil

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

        }

        self.datePicker.datePickerStyle = datePickerStyle
        self.datePicker.datePickerMode = datePickerMode
        self.datePicker.datePickerElements = datePickerElements
        self.datePicker.isBordered = isBordered
        self.datePicker.dateValue = dateValue ?? Date()
        self.datePicker.drawsBackground = drawsBackground
        self.datePicker.backgroundColor = backgroundColor
        self.datePicker.textColor = textColor
        self.datePicker.minDate = minDate
        self.datePicker.maxDate = maxDate

        self.datePicker.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

        // parse locale from "en-US" format
        //if let localeStr = dict["locale"] as? String {
        //    let locale = Locale(identifier: localeStr)
        //    self.datePicker.locale = locale
        //}

        let localeStr = "en-US"

        self.datePicker.locale = Locale(identifier: localeStr)
        //self.datePicker.timeZone = TimeZone.current
        //self.datePicker.calendar = Calendar
        self.datePicker.font = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: NSFont.Weight.regular)

        self.datePicker.target = self
        self.datePicker.action = #selector(dateChanged)

        addSubview(self.datePicker)

        self.datePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.datePicker.topAnchor.constraint(equalTo: topAnchor),
            self.datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        self.channel.setMethodCallHandler { call, result in
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

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func dateChanged() {
        // let date = self.datePicker.dateValue
        // let timestamp = date.timeIntervalSince1970 * 1000
        //channel.invokeMethod("onDateChanged", arguments: timestamp)
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

    private static func datePickerElementFromString(_ element: String) -> NSDatePicker.ElementFlags?
    {
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

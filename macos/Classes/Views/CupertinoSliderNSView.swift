import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoSliderNSView: NSView {
  private let channel: FlutterMethodChannel
  @objc let myModel: SliderModel = SliderModel()

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeSlider_\(viewId)", binaryMessenger: messenger)

    let slider = NSSlider()

    var initialValue: Double = 0
    var minValue: Double = 0
    var maxValue: Double = 1
    var enabled: Bool = true
    var isDark: Bool = false
    var tint: NSColor? = nil
    var tickMarks: Int = 0
    var tickMarkPosition: NSSlider.TickMarkPosition? = nil
    var type: NSSlider.SliderType = .linear
    var isContinuous: Bool = true
    var isVertical: Bool = false
    var controlSize: NSControl.ControlSize = .regular
    var allowsTickMarkValuesOnly: Bool = false

    if let dict = args as? [String: Any] {
      if let v = dict["value"] as? NSNumber { initialValue = v.doubleValue }
      if let v = dict["min"] as? NSNumber { minValue = v.doubleValue }
      if let v = dict["max"] as? NSNumber { maxValue = v.doubleValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let v = dict["type"] as? String { type = Self.sliderTypeFromString(v) }
      if let v = dict["tickMarkPosition"] as? String {
        tickMarkPosition = Self.tickMarkPositionFromString(v)
      }
      if let v = dict["tickMarks"] as? NSNumber { tickMarks = v.intValue }
      if let v = dict["allowsTickMarkValuesOnly"] as? NSNumber {
        allowsTickMarkValuesOnly = v.boolValue
      }
      if let v = dict["isContinuous"] as? NSNumber { isContinuous = v.boolValue }
      if let v = dict["tint"] as? NSNumber { tint = Self.colorFromARGB(v.intValue) }
      if let v = dict["isVertical"] as? NSNumber { isVertical = v.boolValue }
      if let v = dict["size"] as? String {
        controlSize = ControlSizeUtils.controlSizeFromString(v)
      }
    }

    super.init(frame: .zero)

    self.myModel.updateValues(minValue: minValue, maxValue: maxValue, value: initialValue)

    slider.bind(.value, to: self.myModel, withKeyPath: "value", options: nil)
    slider.bind(.minValue, to: self.myModel, withKeyPath: "minValue", options: nil)
    slider.bind(.maxValue, to: self.myModel, withKeyPath: "maxValue", options: nil)

    self.myModel.onChange = { value in
      NSLog("myModel.onChange \(value)")
      self.channel.invokeMethod("valueChanged", arguments: ["value": value])
    }

    slider.controlSize = controlSize
    slider.isEnabled = enabled
    slider.isContinuous = isContinuous
    slider.sliderType = type
    slider.isVertical = isVertical
    slider.numberOfTickMarks = tickMarks
    slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly

    if tickMarkPosition != nil {
      slider.tickMarkPosition = tickMarkPosition!
      NSLog("tickMarkPosition: \(tickMarkPosition!)")
    }

    if let tint = tint {
      slider.trackFillColor = tint
    }

    NSLog("tickMarks: %d", tickMarks)
    NSLog("allowsTickMarkValuesOnly: %d", allowsTickMarkValuesOnly)

    slider.wantsLayer = true
    slider.layer?.backgroundColor = NSColor.clear.cgColor
    slider.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    slider.target = self
    slider.action = #selector(onSliderValueChanged(_:))

    addSubview(slider)
    slider.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      slider.leadingAnchor.constraint(equalTo: leadingAnchor),
      slider.trailingAnchor.constraint(equalTo: trailingAnchor),
      slider.topAnchor.constraint(equalTo: topAnchor),
      slider.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    if !isVertical {
      // slider.bounds = frame.insetBy(dx: 20.0, dy: 20.0)
    }

    channel.setMethodCallHandler { call, result in

      switch call.method {
      case "getIntrinsicSize":
        let size = slider.intrinsicContentSize
        result(["width": size.width, "height": size.height])
      case "setValue":
        if let args = call.arguments as? [String: Any],
          let value = (args["value"] as? NSNumber)?.doubleValue
        {
          if value != self.myModel.value {
            self.myModel.value = value
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
        }
      case "setRange":
        if let args = call.arguments as? [String: Any],
          let min = (args["min"] as? NSNumber)?.doubleValue,
          let max = (args["max"] as? NSNumber)?.doubleValue
        {
          self.myModel.minValue = min
          self.myModel.maxValue = max
          if self.myModel.value < min { self.myModel.value = min }
          if self.myModel.value > max { self.myModel.value = max }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing min/max", details: nil))
        }
      case "setEnabled":
        if let args = call.arguments as? [String: Any],
          let enabled = (args["enabled"] as? NSNumber)?.boolValue
        {
          slider.isEnabled = enabled
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let tintNum = args["tint"] as? NSNumber {
            let ns = Self.colorFromARGB(tintNum.intValue)
            slider.trackFillColor = ns
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["isDark"] as? NSNumber)?.boolValue
        {
          slider.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setTickMarks":
        if let args = call.arguments as? [String: Any],
          let tickMarks = (args["tickMarks"] as? NSNumber)?.intValue
        {
          slider.numberOfTickMarks = tickMarks
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing tickMarks", details: nil))
        }
      case "setTickMarkPosition":
        if let args = call.arguments as? [String: Any],
          let tickMarkPosition = args["tickMarkPosition"] as? String
        {
          slider.tickMarkPosition = Self.tickMarkPositionFromString(tickMarkPosition)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing tickMarkPosition", details: nil))
        }
      case "setAllowsTickMarkValuesOnly":
        if let args = call.arguments as? [String: Any],
          let allowsTickMarkValuesOnly = (args["allowsTickMarkValuesOnly"] as? NSNumber)?.boolValue
        {
          slider.allowsTickMarkValuesOnly = allowsTickMarkValuesOnly
          result(nil)
        } else {
          result(
            FlutterError(
              code: "bad_args", message: "Missing allowsTickMarkValuesOnly", details: nil))
        }
      case "setType":
        if let args = call.arguments as? [String: Any],
          let type = args["type"] as? String
        {
          slider.sliderType = Self.sliderTypeFromString(type)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing type", details: nil))
        }
      case "setIsContinuous":
        if let args = call.arguments as? [String: Any],
          let isContinuous = (args["isContinuous"] as? NSNumber)?.boolValue
        {
          slider.isContinuous = isContinuous
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isContinuous", details: nil))
        }
      case "setIsVertical":
        if let args = call.arguments as? [String: Any],
          let isVertical = (args["isVertical"] as? NSNumber)?.boolValue
        {
          slider.isVertical = isVertical
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isVertical", details: nil))
        }
      case "setSize":
        if let args = call.arguments as? [String: Any],
          let size = args["size"] as? String
        {
          slider.controlSize = ControlSizeUtils.controlSizeFromString(size)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing size", details: nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }

  @objc func onSliderValueChanged(_ sender: NSSlider) {
    NSLog("onSliderValueChanged: \(sender.doubleValue)")
    myModel.value = sender.doubleValue
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }

  private static func tickMarkPositionFromString(_ s: String) -> NSSlider.TickMarkPosition {
    switch s {
    case "above":
      return .above
    case "below":
      return .below
    case "leading":
      return .leading
    case "trailing":
      return .trailing
    default:
      return .above
    }
  }

  private static func sliderTypeFromString(_ s: String) -> NSSlider.SliderType {
    switch s {
    case "circular":
      return .circular
    case "linear":
      return .linear
    default:
      return .linear
    }
  }
}

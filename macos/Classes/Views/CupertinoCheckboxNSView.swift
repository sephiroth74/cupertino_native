import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoCheckboxNSView: NSView {
  private let channel: FlutterMethodChannel
  private let hostingController: NSHostingController<CupertinoCheckboxView>

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeCheckbox_\(viewId)", binaryMessenger: messenger)

    var initialValue: Bool = false
    var enabled: Bool = true
    var isDark: Bool = false
    var initialTint: NSColor? = nil
    var controlSize: ControlSize = .regular
    var label: String? = nil
    var systemImage: String? = nil
    if let dict = args as? [String: Any] {
      if let v = dict["value"] as? NSNumber { initialValue = v.boolValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let v = dict["label"] as? String { label = v }
      if let v = dict["systemImage"] as? String { systemImage = v }
      if let v = dict["controlSize"] as? String {
        switch v {
        case "mini": controlSize = .mini
        case "small": controlSize = .small
        case "regular": controlSize = .regular
        case "large": controlSize = .large
        case "extraLarge": controlSize = .large
        default: controlSize = .regular
        }
      }
      if let v = dict["tint"] as? NSNumber {
        initialTint = ColorUtils.colorFromARGB(v.intValue)
      }
    }

    var channelRef: FlutterMethodChannel? = nil
    let model = CheckboxModel(
      value: initialValue, label: label, systemImage: systemImage, enabled: enabled
    ) { newValue in
      channelRef?.invokeMethod("valueChanged", arguments: ["value": newValue])
    }
    model.controlSize = controlSize

    self.hostingController = NSHostingController(rootView: CupertinoCheckboxView(model: model))
    super.init(frame: .zero)

    channelRef = self.channel

    hostingController.view.wantsLayer = true
    hostingController.view.layer?.backgroundColor = NSColor.clear.cgColor
    hostingController.view.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
    if let tint = initialTint {
      model.tintColor = Color(tint)
    }

    addSubview(hostingController.view)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getIntrinsicSize":
        let size = self.hostingController.view.intrinsicContentSize
        result(["width": size.width, "height": size.height])

      case "setValue":
        if let args = call.arguments as? [String: Any],
          let value = (args["value"] as? NSNumber)?.boolValue
        {
          model.setValueFromDart(value)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
        }
      case "setIsEnabled":
        if let args = call.arguments as? [String: Any],
          let enabled = (args["value"] as? NSNumber)?.boolValue
        {
          model.enabled = enabled
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
        }
      case "setTint":
        if let args = call.arguments as? [String: Any] {
          if let tintNum = args["value"] as? NSNumber {
            let ns = ColorUtils.colorFromARGB(tintNum.intValue)
            model.tintColor = Color(ns)
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setIsDark":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["value"] as? NSNumber)?.boolValue
        {
          self.hostingController.view.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setControlSize":
        if let args = call.arguments as? [String: Any], let sizeStr = args["value"] as? String {
          switch sizeStr {
          case "mini": controlSize = .mini
          case "small": controlSize = .small
          case "regular": controlSize = .regular
          case "large": controlSize = .large
          case "extraLarge": controlSize = .large
          default: controlSize = .regular
          }
          model.controlSize = controlSize
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil))
        }
      case "setLabel":
        if let args = call.arguments as? [String: Any] {
          if let label = args["value"] as? String {
            model.label = label
          } else {
            model.label = nil
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing label", details: nil))
        }
      case "setSystemImage":
        if let args = call.arguments as? [String: Any] {
          if let systemImage = args["value"] as? String {
            model.systemImage = systemImage
          } else {
            model.systemImage = nil
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing systemImage", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }
}

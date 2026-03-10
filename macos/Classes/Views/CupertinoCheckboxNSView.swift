import Cocoa
import FlutterMacOS

class CupertinoCheckboxNSView: NSView {
  private let channel: FlutterMethodChannel
  private let checkbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeCheckbox_\(viewId)", binaryMessenger: messenger)

    var allowsMixedState = false
    var title = ""
    var controlSize: NSControl.ControlSize = .regular
    var initialState: NSControl.StateValue = .off
    var bezelColor: NSColor? = nil
    var enabled: Bool = true
    var isDark: Bool = false

    if let dict = args as? [String: Any] {
      if let v = dict["state"] as? NSNumber { initialState = NSControl.StateValue(v.intValue) }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let v = dict["title"] as? String { title = v }
      if let v = dict["allowsMixedState"] as? NSNumber { allowsMixedState = v.boolValue }
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
        bezelColor = ColorUtils.colorFromARGB(v.intValue)
      }
    }


    super.init(frame: .zero)

    self.checkbox.wantsLayer = true
    self.checkbox.layer?.backgroundColor = NSColor.clear.cgColor
    self.checkbox.isEnabled = enabled
    self.checkbox.allowsMixedState = allowsMixedState
    self.checkbox.state = initialState
    self.checkbox.title = title
    self.checkbox.controlSize = controlSize

    self.checkbox.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    if let tint = bezelColor {
      self.checkbox.bezelColor = tint
    }

    self.checkbox.target = self
    self.checkbox.action = #selector(checkboxToggled)
    self.checkbox.setButtonType(.switch)

    addSubview(self.checkbox)

    self.checkbox.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.checkbox.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.checkbox.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.checkbox.topAnchor.constraint(equalTo: topAnchor),
      self.checkbox.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    self.channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getIntrinsicSize":
        let size = self.checkbox.intrinsicContentSize
        result(["width": size.width, "height": size.height])

      case "setState":
        if let args = call.arguments as? [String: Any],
          let value = (args["value"] as? NSNumber)?.intValue
        {
          self.checkbox.state = NSControl.StateValue(value)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing value", details: nil))
        }
      case "setIsEnabled":
        if let args = call.arguments as? [String: Any],
          let enabled = (args["value"] as? NSNumber)?.boolValue
        {
          self.checkbox.isEnabled = enabled
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil))
        }
      case "setTint":
        if let args = call.arguments as? [String: Any] {
          if let tintNum = args["value"] as? NSNumber {
            let ns = ColorUtils.colorFromARGB(tintNum.intValue)
            self.checkbox.bezelColor = ns
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setIsDark":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["value"] as? NSNumber)?.boolValue
        {
          self.checkbox.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setControlSize":
        if let args = call.arguments as? [String: Any], let sizeStr = args["value"] as? String {
          self.checkbox.controlSize = ControlSizeUtils.controlSizeFromString(sizeStr)
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil))
        }
      case "setTitle":
        if let args = call.arguments as? [String: Any] {
          if let title = args["value"] as? String {
            self.checkbox.title = title
          } else {
            self.checkbox.title = ""
          }
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing label", details: nil))
        }
      case "setAllowsMixedState":
        if let args = call.arguments as? [String: Any],
          let allowsMixedState = (args["value"] as? NSNumber)?.boolValue
        {
          self.checkbox.allowsMixedState = allowsMixedState
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing allowsMixedState", details: nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }

  @objc private func checkboxToggled() {
    let newValue = checkbox.state.rawValue
    channel.invokeMethod("stateChanged", arguments: ["value": newValue])
  }
}

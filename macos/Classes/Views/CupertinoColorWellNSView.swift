import Cocoa
import FlutterMacOS

class CupertinoColorWellNSView: NSView {
  private let channel: FlutterMethodChannel
  private var colorWell: NSColorWell?
  private var color: NSColor = NSColor.blue
  private var style: String = "regular"
  private var enabled: Bool = true
  private var isDark: Bool = false
  private var continuous: Bool = true
  private var supportsAlpha: Bool = true

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeColorWell_\(viewId)", binaryMessenger: messenger)
    self.colorWell = NSColorWell()
    super.init(frame: .zero)

    if let args = args as? [String: Any] {
      parseArgs(args)
    }
    setupColorWell()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func parseArgs(_ args: [String: Any]) {
    if let colorValue = args["color"] as? Int {
      color = ColorUtils.colorFromARGB(colorValue)
    }

    if let supportsAlphaValue = args["supportsAlpha"] as? Bool {
      supportsAlpha = supportsAlphaValue
    }

    if let styleValue = args["style"] as? String {
      style = styleValue
    }

    if let enabledValue = args["enabled"] as? Bool {
      enabled = enabledValue
    }

    if let isDarkValue = args["isDark"] as? Bool {
      isDark = isDarkValue
    }

    if let continuousValue = args["continuous"] as? Bool {
      continuous = continuousValue
    }
  }

  private func setupColorWell() {
    self.colorWell!.target = self
    self.colorWell!.action = #selector(colorWellChanged(_:))
    self.colorWell!.isContinuous = continuous
    self.colorWell!.supportsAlpha = supportsAlpha
    self.colorWell!.color = color
    self.colorWell!.isEnabled = enabled

    addSubview(self.colorWell!)
    self.colorWell!.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.colorWell!.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.colorWell!.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.colorWell!.topAnchor.constraint(equalTo: topAnchor),
      self.colorWell!.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])


    // Apply style
    self.colorWell!.colorWellStyle = Self.parseStyle(style)

    // Apply dark mode appearance
    if isDark {
      self.colorWell!.appearance = NSAppearance(named: .darkAqua)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "getIntrinsicSize":
        let s = self.colorWell!.intrinsicContentSize
        result(["width": Double(s.width), "height": Double(s.height)])
      case "setStyle":
        if let args = call.arguments as? [String: Any], let s = args["style"] as? String {
          self.colorWell!.colorWellStyle = Self.parseStyle(s)
          result(nil)
        } else {
          NSLog("setStyle called with invalid arguments: \(call.arguments)")
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setBrightness":
        if let args = call.arguments as? [String: Any],
          let isDark = (args["isDark"] as? NSNumber)?.boolValue
        {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else {
          NSLog("setBrightness called with invalid arguments: \(call.arguments)")
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setColor":
        if let args = call.arguments as? [String: Any], let c = args["color"] as? NSNumber {
          self.color = ColorUtils.colorFromARGB(c.intValue)
          self.colorWell!.color = self.color
          result(nil)
        } else {
          NSLog("setColor called with invalid arguments: \(call.arguments)")
          result(FlutterError(code: "bad_args", message: "Missing color", details: nil))
        }
      case "setSupportsAlpha":
        if let args = call.arguments as? [String: Any], let s = args["supportsAlpha"] as? Bool {
          self.supportsAlpha = s
          self.colorWell!.supportsAlpha = s
          result(nil)
        } else {
          NSLog("setSupportsAlpha called with invalid arguments: \(call.arguments)")
          result(FlutterError(code: "bad_args", message: "Missing supportsAlpha", details: nil))
        }
      default:
        NSLog("Unknown method: \(call.method)")
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @objc private func colorWellChanged(_ sender: NSColorWell) {
    let colorValue = ColorUtils.colorToArgb(sender.color)
    self.channel.invokeMethod("colorChanged", arguments: colorValue)
  }

  private static func parseStyle(_ style: String) -> NSColorWell.Style {
    switch style {
    case "minimal":
      return .minimal
    case "expanded":
      return .expanded
    default:
      return .default
    }
  }

  override func layout() {
    super.layout()
    self.colorWell!.frame = bounds
  }
}

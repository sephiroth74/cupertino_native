import FlutterMacOS
import Cocoa

class CupertinoSegmentedControlNSView: NSView {
  private let channel: FlutterMethodChannel
  private let control: NSSegmentedControl
  private var labels: [String] = []
  private var symbols: [String] = []
  private var perSymbolSizes: [CGFloat?] = []
  private var defaultIconSize: CGFloat? = nil
  private var perSymbolModes: [String?] = []
  private var perSymbolGradientEnabled: [NSNumber?] = []
  private var defaultIconRenderingMode: String? = nil
  private var defaultIconGradientEnabled: Bool = false
  private var defaultIconColor: NSColor? = nil
  private var perSymbolColors: [NSColor?] = []
  private var tintColor: NSColor? = nil

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeSegmentedControl_\(viewId)", binaryMessenger: messenger)
    self.control = NSSegmentedControl(labels: [], trackingMode: .selectOne, target: nil, action: nil)

    var labels: [String] = []
    var sfSymbols: [String] = []
    var selectedIndex: Int = -1
    var enabled: Bool = true
    var isDark: Bool = false

    if let dict = args as? [String: Any] {
      if let arr = dict["labels"] as? [String] { labels = arr }
      if let arr = dict["sfSymbols"] as? [String] { sfSymbols = arr }
      if let sizes = dict["sfSymbolSizes"] as? [NSNumber] { self.perSymbolSizes = sizes.map { CGFloat(truncating: $0) } }
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { self.perSymbolModes = modes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { self.perSymbolGradientEnabled = gradients }
      if let colors = dict["sfSymbolColors"] as? [NSNumber] { self.perSymbolColors = colors.map { NSColor(srgbRed: CGFloat(($0.intValue >> 16) & 0xFF) / 255.0, green: CGFloat(($0.intValue >> 8) & 0xFF) / 255.0, blue: CGFloat($0.intValue & 0xFF) / 255.0, alpha: CGFloat(($0.intValue >> 24) & 0xFF) / 255.0) } }
      if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any] {
        if let s = style["iconSize"] as? NSNumber { self.defaultIconSize = CGFloat(truncating: s) }
        if let mode = style["iconRenderingMode"] as? String { self.defaultIconRenderingMode = mode }
        if let g = style["iconGradientEnabled"] as? NSNumber { self.defaultIconGradientEnabled = g.boolValue }
        if let color = style["iconColor"] as? NSNumber {
          self.defaultIconColor = ColorUtils.colorFromARGB(color.intValue)
        }
        if let tint = style["tint"] as? NSNumber {
          self.tintColor = ColorUtils.colorFromARGB(tint.intValue)
        }
      }
    }

    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    self.labels = labels
    self.symbols = sfSymbols
    configureSegments()
    if selectedIndex >= 0 { control.selectedSegment = selectedIndex }
    control.isEnabled = enabled

    control.target = self
    control.action = #selector(onChanged(_:))
    
    // Add KVO observer to track segment changes
    control.addObserver(self, forKeyPath: "selectedSegment", options: .new, context: nil)

    addSubview(control)
    control.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      control.leadingAnchor.constraint(equalTo: leadingAnchor),
      control.trailingAnchor.constraint(equalTo: trailingAnchor),
      control.topAnchor.constraint(equalTo: topAnchor),
      control.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.control.intrinsicContentSize
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setSelectedIndex":
        if let args = call.arguments as? [String: Any], let idx = (args["index"] as? NSNumber)?.intValue {
          self.control.selectedSegment = idx
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing index", details: nil)) }
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let e = (args["enabled"] as? NSNumber)?.boolValue {
          self.control.isEnabled = e
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let s = args["iconSize"] as? NSNumber { self.defaultIconSize = CGFloat(truncating: s) }
          if let tint = args["tint"] as? NSNumber {
            self.tintColor = ColorUtils.colorFromARGB(tint.intValue)
          }
          self.configureSegments()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "selectedSegment" {
      configureSegments()
    }
  }

  deinit {
    control.removeObserver(self, forKeyPath: "selectedSegment")
  }

  private func configureSegments() {
    let count = max(labels.count, symbols.count)
    control.segmentCount = count
    for i in 0..<count {
      if i < symbols.count, #available(macOS 11.0, *), var image = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
        if let size = (i < perSymbolSizes.count ? perSymbolSizes[i] : nil) ?? defaultIconSize {
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration(pointSize: size, weight: .regular)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        }
        
        // Determine if this segment is selected
        let isSelected = (i == control.selectedSegment)
        
        // Use tint color for selected segment, otherwise use default icon color
        let iconColor = isSelected ? tintColor : ((i < perSymbolColors.count && perSymbolColors[i] != nil) ? perSymbolColors[i] : defaultIconColor)
        
        // Apply rendering mode
        let mode = (i < perSymbolModes.count ? perSymbolModes[i] : nil) ?? defaultIconRenderingMode
        if let mode = mode, #available(macOS 12.0, *) {
          switch mode {
          case "hierarchical":
            if let color = iconColor {
              let cfg = NSImage.SymbolConfiguration(hierarchicalColor: color)
              image = image.withSymbolConfiguration(cfg) ?? image
            }
          case "palette":
            let paletteColors = NSImage.SymbolConfiguration.preferringMulticolor()
            image = image.withSymbolConfiguration(paletteColors) ?? image
          case "multicolor":
            let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
            image = image.withSymbolConfiguration(cfg) ?? image
          default:
            if let color = iconColor {
              image = image.tinted(with: color) ?? image
            }
          }
        } else if let color = iconColor {
          image = image.tinted(with: color) ?? image
        }
        
        control.setImage(image, forSegment: i)
      } else if i < labels.count {
        control.setLabel(labels[i], forSegment: i)
      } else {
        control.setLabel("", forSegment: i)
      }
    }
  }

  @objc private func onChanged(_ sender: NSSegmentedControl) {
    channel.invokeMethod("valueChanged", arguments: ["index": sender.selectedSegment])
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

// MARK: - NSImage Extension for Tinting
extension NSImage {
  func tinted(with color: NSColor) -> NSImage? {
    let image = copy() as! NSImage
    image.lockFocus()
    color.set()
    let imageRect = NSRect(origin: .zero, size: image.size)
    imageRect.fill(using: .sourceAtop)
    image.unlockFocus()
    return image
  }
}

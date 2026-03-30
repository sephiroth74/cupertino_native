import FlutterMacOS
import Cocoa

class CupertinoImageNSView: NSView {
  private let channel: FlutterMethodChannel
  private let imageView: NSImageView

  private var systemSymbolName: String = ""
  private var symbolConfiguration: [String: Any]?

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativeImage_\(viewId)", binaryMessenger: messenger)
    self.imageView = NSImageView(frame: .zero)

    if let dict = args as? [String: Any] {
      if let s = dict["systemSymbolName"] as? String { self.systemSymbolName = s }
      if let config = dict["symbolConfiguration"] as? [String: Any] { self.symbolConfiguration = config }
    }

    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.imageScaling = .scaleProportionallyUpOrDown
    addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    rebuild()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "setImage":
        if let args = call.arguments as? [String: Any] {
          if let n = args["systemSymbolName"] as? String { self.systemSymbolName = n }
          if let config = args["symbolConfiguration"] as? [String: Any] { self.symbolConfiguration = config }
          self.rebuild()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing args", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  private func rebuild() {
    guard var image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil) else {
      imageView.image = nil
      return
    }

    if let cfg = symbolConfiguration {
      let type = cfg["type"] as? String

      if #available(macOS 12.0, *) {
        var nsConfig: NSImage.SymbolConfiguration?

        switch type {
        case "hierarchical":
          if let colorVal = cfg["color"] as? NSNumber {
            let c = ColorUtils.colorFromARGB(colorVal.intValue)
            nsConfig = NSImage.SymbolConfiguration(hierarchicalColor: c)
          }
        case "palette":
          if let colorsArray = cfg["colors"] as? [NSNumber] {
            let nsColors = colorsArray.map { ColorUtils.colorFromARGB($0.intValue) }
            nsConfig = NSImage.SymbolConfiguration(paletteColors: nsColors)
          }
        case "multicolor":
          nsConfig = NSImage.SymbolConfiguration.preferringMulticolor()
        default:
          break
        }

        if let validConfig = nsConfig {
          image = image.withSymbolConfiguration(validConfig) ?? image
        }
      }

      if type == "monochrome" {
        if let colorVal = cfg["color"] as? NSNumber {
          let c = ColorUtils.colorFromARGB(colorVal.intValue)
          image = image.tinted(with: c)
        } else {
          image = image.tinted(with: .black)
        }
      }
    }

    imageView.image = image
  }
}

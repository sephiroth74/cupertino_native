import FlutterMacOS
import SwiftUI
import Cocoa

class CupertinoPickerNSView: NSView {
  private let channel: FlutterMethodChannel
  private var hostingView: NSHostingView<PickerContent>?
  private var measuredSize: NSSize?
  private var selection: Int = 0
  private var items: [String] = []
  private var label: String? = nil
  private var sublabel: String? = nil
  private var symbols: [String] = []
  private var enabled: Bool = true
  private var isDark: Bool = false
  private var tintColor: NSColor? = nil
  private var defaultIconSize: CGFloat? = nil
  private var defaultIconColor: NSColor? = nil
  private var perSymbolColors: [NSColor?] = []
  private var perSymbolSizes: [CGFloat?] = []
  private var perSymbolModes: [String?] = []
  private var perSymbolGradientEnabled: [NSNumber?] = []
  private var defaultIconRenderingMode: String? = nil
  private var defaultIconGradientEnabled: Bool = false
  private var controlSize: String = "regular"
  private var pickerStyle: String = "segmented"

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePicker_\(viewId)", binaryMessenger: messenger)

    var selectedIndex: Int = 0

    if let dict = args as? [String: Any] {
      if let arr = dict["items"] as? [String] { items = arr }
      if let lbl = dict["label"] as? String { label = lbl }
      if let sublbl = dict["sublabel"] as? String { sublabel = sublbl }
      if let arr = dict["sfSymbols"] as? [String] { symbols = arr }
      if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
      if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let size = dict["controlSize"] as? String { controlSize = size }
      if let style = dict["pickerStyle"] as? String { pickerStyle = style }
      if let sizes = dict["sfSymbolSizes"] as? [NSNumber] { perSymbolSizes = sizes.map { CGFloat(truncating: $0) } }
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { perSymbolModes = modes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { perSymbolGradientEnabled = gradients }
      if let colors = dict["sfSymbolColors"] as? [NSNumber] {
        perSymbolColors = colors.map { NSColor(srgbRed: CGFloat(($0.intValue >> 16) & 0xFF) / 255.0, green: CGFloat(($0.intValue >> 8) & 0xFF) / 255.0, blue: CGFloat($0.intValue & 0xFF) / 255.0, alpha: CGFloat(($0.intValue >> 24) & 0xFF) / 255.0) }
      }
      if let style = dict["style"] as? [String: Any] {
        if let s = style["iconSize"] as? NSNumber { defaultIconSize = CGFloat(truncating: s) }
        if let mode = style["iconRenderingMode"] as? String { defaultIconRenderingMode = mode }
        if let g = style["iconGradientEnabled"] as? NSNumber { defaultIconGradientEnabled = g.boolValue }
        if let color = style["iconColor"] as? NSNumber {
          defaultIconColor = ColorUtils.colorFromARGB(color.intValue)
        }
        if let tint = style["tint"] as? NSNumber {
          tintColor = ColorUtils.colorFromARGB(tint.intValue)
        }
      }
    }

    selection = selectedIndex
    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    createPickerContent()

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.measuredSize
          ?? self.hostingView?.intrinsicContentSize
          ?? NSSize(width: NSView.noIntrinsicMetric, height: 32)

        result(["width": size.width, "height": size.height])

      case "setSelectedIndex":
        if let args = call.arguments as? [String: Any], let idx = (args["index"] as? NSNumber)?.intValue {
          self.selection = idx
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing index", details: nil)) }
      case "setEnabled":
        if let args = call.arguments as? [String: Any], let e = (args["enabled"] as? NSNumber)?.boolValue {
          self.enabled = e
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing enabled", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.isDark = isDark
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if let s = args["iconSize"] as? NSNumber { self.defaultIconSize = CGFloat(truncating: s) }
          if let tint = args["tint"] as? NSNumber {
            self.tintColor = ColorUtils.colorFromARGB(tint.intValue)
          }
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setControlSize":
        if let args = call.arguments as? [String: Any], let sizeName = args["controlSize"] as? String {
          self.controlSize = sizeName
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil)) }
      case "setPickerStyle":
        if let args = call.arguments as? [String: Any], let styleName = args["pickerStyle"] as? String {
          self.pickerStyle = styleName
          self.createPickerContent()
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pickerStyle", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  private func createPickerContent() {
    hostingView?.removeFromSuperview()

    let pickerModel = PickerModel(
      items: items,
      label: label,
      sublabel: sublabel,
      symbols: symbols,
      selectedIndex: selection,
      enabled: enabled,
      tintColor: tintColor,
      controlSize: SwiftUtils.controlSizeFromString(controlSize),
      pickerStyle: pickerStyle,
      defaultIconSize: defaultIconSize,
      defaultIconColor: defaultIconColor,
      perSymbolColors: perSymbolColors,
      perSymbolSizes: perSymbolSizes,
      perSymbolModes: perSymbolModes,
      perSymbolGradientEnabled: perSymbolGradientEnabled,
      defaultIconRenderingMode: defaultIconRenderingMode,
      defaultIconGradientEnabled: defaultIconGradientEnabled,
      onSelectionChange: { [weak self] newIndex in
        self?.selection = newIndex
        self?.channel.invokeMethod("valueChanged", arguments: ["index": newIndex])
      },
      onSizeChange: { [weak self] newSize in
        guard let self = self else { return }
        self.measuredSize = NSSize(width: newSize.width, height: newSize.height)
        self.channel.invokeMethod(
          "intrinsicSizeChanged",
          arguments: ["width": newSize.width, "height": newSize.height]
        )
      }
    )

    let content = PickerContent(model: pickerModel)
    let hosting = NSHostingView(rootView: content)
    hosting.translatesAutoresizingMaskIntoConstraints = false

    addSubview(hosting)
    NSLayoutConstraint.activate([
      hosting.leadingAnchor.constraint(equalTo: leadingAnchor),
      hosting.trailingAnchor.constraint(equalTo: trailingAnchor),
      hosting.topAnchor.constraint(equalTo: topAnchor),
      hosting.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    hostingView = hosting
  }

}

// MARK: - SwiftUI Components

struct PickerModel {
  let items: [String]
  let label: String?
  let sublabel: String?
  let symbols: [String]
  let selectedIndex: Int
  let enabled: Bool
  let tintColor: NSColor?
  let controlSize: ControlSize
  let pickerStyle: String
  let defaultIconSize: CGFloat?
  let defaultIconColor: NSColor?
  let perSymbolColors: [NSColor?]
  let perSymbolSizes: [CGFloat?]
  let perSymbolModes: [String?]
  let perSymbolGradientEnabled: [NSNumber?]
  let defaultIconRenderingMode: String?
  let defaultIconGradientEnabled: Bool
  let onSelectionChange: (Int) -> Void
  let onSizeChange: (CGSize) -> Void
}

struct PickerContent: View {
  @State var size: CGSize = .zero
  @State var selection: Int
  let model: PickerModel

  init(model: PickerModel) {
    self.model = model
    _selection = State(initialValue: model.selectedIndex)
  }

  var body: some View {
    Group {
      if model.pickerStyle == "segmented" {
        basePicker
          .pickerStyle(.segmented)
      } else if model.pickerStyle == "automatic" {
        basePicker
          .pickerStyle(.automatic)
      } else if model.pickerStyle == "inline" {
        basePicker
          .pickerStyle(.inline)
      } else if model.pickerStyle == "menu" {
        basePicker
          .pickerStyle(.menu)
      } else if model.pickerStyle == "palette" {
        basePicker
          .pickerStyle(.palette)
      } else if model.pickerStyle == "radioGroup" {
        basePicker
          .pickerStyle(.radioGroup)
      } else {
        basePicker
          .pickerStyle(.segmented)
      }
    }
  }

  private var basePicker: some View {
    let picker = Picker(selection: $selection) {
      ForEach(0..<max(model.items.count, model.symbols.count), id: \.self) { index in
        let hasSymbol = index < model.symbols.count && !model.symbols[index].isEmpty
        let hasLabel = index < model.items.count && !model.items[index].isEmpty

        if hasSymbol {
          Image(systemName: model.symbols[index])
            .tag(index)
        } else if hasLabel {
          Text(model.items[index])
            .tag(index)
        } else {
          Text("")
            .tag(index)
        }
      }
    } label: {
        if let label = model.label {
          Text(label)
        }
        if let sublabel = model.sublabel {
          Text(sublabel)
        }
    }
    .controlSize(model.controlSize)
    .disabled(!model.enabled)
    .onChange(of: selection) { newValue in
      model.onSelectionChange(newValue)
    }
    .onGeometryChange(for: CGSize.self) { proxy in
      proxy.size
    } action: { newValue in
      print("onGeometryChange: \(newValue)")
      size = newValue
      model.onSizeChange(newValue)
    }
    
    if model.label != nil {
      return AnyView(List {
        picker
      })
    } else {
      return AnyView(picker)
    }

  }
}

// MARK: - SwiftUI Components (end)

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoPickerNSView: NSView {
    private let channel: FlutterMethodChannel
    private var hostingView: NSHostingView<PickerContent>?
    private var measuredSize: NSSize?
    private var selection: Int = 0
    private var items: [[String: Any]] = []
    private var label: String?
    private var sublabel: String?
    private var enabled: Bool = true
    private var isDark: Bool = false
    private var tintColor: NSColor?
    private var controlSize: String = "regular"
    private var pickerStyle: String = "segmented"

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativePicker_\(viewId)", binaryMessenger: messenger)

        var selectedIndex = 0

        if let dict = args as? [String: Any] {
            if let arr = dict["items"] as? [[String: Any]] { items = arr }
            if let lbl = dict["label"] as? String { label = lbl }
            if let sublbl = dict["sublabel"] as? String { sublabel = sublbl }
            if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
            if let v = dict["enabled"] as? NSNumber { enabled = v.boolValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let size = dict["controlSize"] as? String { controlSize = size }
            if let style = dict["pickerStyle"] as? String { pickerStyle = style }
            if let style = dict["style"] as? [String: Any] {
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

    required init?(coder _: NSCoder) {
        return nil
    }

    private func createPickerContent() {
        hostingView?.removeFromSuperview()

        let pickerModel = PickerModel(
            items: items,
            label: label,
            sublabel: sublabel,
            selectedIndex: selection,
            enabled: enabled,
            tintColor: tintColor,
            controlSize: SwiftUtils.controlSizeFromString(controlSize),
            pickerStyle: pickerStyle,
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
            hosting.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        hostingView = hosting
    }
}

// MARK: - SwiftUI Components

struct PickerModel {
    let items: [[String: Any]]
    let label: String?
    let sublabel: String?
    let selectedIndex: Int
    let enabled: Bool
    let tintColor: NSColor?
    let controlSize: ControlSize
    let pickerStyle: String
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
            ForEach(model.items.indices, id: \.self) { index in
                let item = model.items[index]
                itemView(for: item)
                    .tag(index)
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
            size = newValue
            model.onSizeChange(newValue)
        }

        if let tintColor = model.tintColor {
            let tintedPicker = picker.tint(Color(nsColor: tintColor))
            if model.label != nil {
                return AnyView(List {
                    tintedPicker
                })
            } else {
                return AnyView(tintedPicker)
            }
        } else {
            if model.label != nil {
                return AnyView(List {
                    picker
                })
            } else {
                return AnyView(picker)
            }
        }
    }

    @ViewBuilder
    private func itemView(for item: [String: Any]) -> some View {
        let type = item["type"] as? String ?? "text"
        if type == "icon", let symbolName = item["symbolName"] as? String {
            AnyView(buildStyledImage(symbolName: symbolName, from: item))
        } else {
            Text(item["text"] as? String ?? "")
        }
    }

    private func buildStyledImage(symbolName: String, from item: [String: Any]) -> some View {
        var result: any View = Image(systemName: symbolName)

        // Apply font size if present
        if let sizeValue = item["symbolSize"] as? NSNumber {
            result = Image(systemName: symbolName)
                .font(.system(size: CGFloat(truncating: sizeValue)))
        }

        // Apply rendering mode if present
        if let renderingMode = symbolRenderingModeFromString(from: item["symbolRenderingMode"] as? String) {
            if let sizeValue = item["symbolSize"] as? NSNumber {
                result = Image(systemName: symbolName)
                    .font(.system(size: CGFloat(truncating: sizeValue)))
                    .symbolRenderingMode(renderingMode)
            } else {
                result = Image(systemName: symbolName)
                    .symbolRenderingMode(renderingMode)
            }
        }

        // Apply color styling
        if let colorValue = item["symbolColor"] as? NSNumber {
            let color = Color(nsColor: ColorUtils.colorFromARGB(colorValue.intValue))
            if let renderingMode = symbolRenderingModeFromString(from: item["symbolRenderingMode"] as? String) {
                if let sizeValue = item["symbolSize"] as? NSNumber {
                    result = Image(systemName: symbolName)
                        .font(.system(size: CGFloat(truncating: sizeValue)))
                        .symbolRenderingMode(renderingMode)
                        .foregroundColor(color)
                } else {
                    result = Image(systemName: symbolName)
                        .symbolRenderingMode(renderingMode)
                        .foregroundColor(color)
                }
            } else {
                if let sizeValue = item["symbolSize"] as? NSNumber {
                    result = Image(systemName: symbolName)
                        .font(.system(size: CGFloat(truncating: sizeValue)))
                        .foregroundColor(color)
                } else {
                    result = Image(systemName: symbolName)
                        .foregroundColor(color)
                }
            }
        } else if let paletteValues = item["symbolPaletteColors"] as? [NSNumber] {
            let paletteColors = paletteValues.map { Color(nsColor: ColorUtils.colorFromARGB($0.intValue)) }
            if let renderingMode = symbolRenderingModeFromString(from: item["symbolRenderingMode"] as? String) {
                if let sizeValue = item["symbolSize"] as? NSNumber {
                    result = Image(systemName: symbolName)
                        .font(.system(size: CGFloat(truncating: sizeValue)))
                        .symbolRenderingMode(renderingMode)
                        .foregroundColor(paletteColors.first ?? .black)
                } else {
                    result = Image(systemName: symbolName)
                        .symbolRenderingMode(renderingMode)
                        .foregroundColor(paletteColors.first ?? .black)
                }
            } else {
                if let sizeValue = item["symbolSize"] as? NSNumber {
                    result = Image(systemName: symbolName)
                        .font(.system(size: CGFloat(truncating: sizeValue)))
                        .foregroundColor(paletteColors.first ?? .black)
                } else {
                    result = Image(systemName: symbolName)
                        .foregroundColor(paletteColors.first ?? .black)
                }
            }
        }

        return AnyView(result)
    }

    private func symbolRenderingModeFromString(from raw: String?) -> SymbolRenderingMode? {
        switch raw {
        case "monochrome":
            return .monochrome
        case "hierarchical":
            return .hierarchical
        case "multicolor":
            return .multicolor
        case "palette":
            return .palette
        default:
            return nil
        }
    }
}

// MARK: - SwiftUI Components (end)

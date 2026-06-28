import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoLabelNSView: NSView {
    override var intrinsicContentSize: NSSize {
        if let measuredSize {
            return measuredSize
        }
        return hostingView?.intrinsicContentSize
            ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    private let channel: FlutterMethodChannel
    private var hostingView: NSHostingView<LabelContent>?
    private var measuredSize: NSSize?
    private var args: [String: Any]

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeLabel_\(viewId)",
            binaryMessenger: messenger
        )
        self.args = args as? [String: Any] ?? [:]
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        createHostingView()
        setupMethodCallHandler()
    }

    required init?(coder _: NSCoder) {
        return nil
    }

    private func createHostingView() {
        hostingView?.removeFromSuperview()
        let content = LabelContent(
            model: parseArguments(args),
            onSizeChanged: { [weak self] size in
                guard let self = self else { return }
                self.measuredSize = NSSize(width: size.width, height: size.height)
                self.invalidateIntrinsicContentSize()
                self.channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": size.width, "height": size.height]
                )
            }
        )
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

    private func setupMethodCallHandler() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(nil); return }
            switch call.method {
            case "getIntrinsicSize":
                let size = self.hostingView?.intrinsicContentSize ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
                result(["width": Double(size.width), "height": Double(size.height)])
            case "setText":
                if let args = call.arguments as? [String: Any] {
                    self.args["text"] = args["text"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing text", details: nil))
                }
            case "setIcon":
                if let args = call.arguments as? [String: Any] {
                    self.args["iconName"] = args["iconName"]
                    self.args["iconSize"] = args["iconSize"]
                    self.args["iconColor"] = args["iconColor"]
                    self.args["iconRenderingMode"] = args["iconRenderingMode"]
                    self.args["iconPaletteColors"] = args["iconPaletteColors"]
                    self.args["iconGradientEnabled"] = args["iconGradientEnabled"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing icon", details: nil))
                }
            case "setColor":
                if let args = call.arguments as? [String: Any] {
                    self.args["color"] = args["color"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing color", details: nil))
                }
            case "setFont":
                if let args = call.arguments as? [String: Any] {
                    self.args["font"] = args["font"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing font", details: nil))
                }
            case "setLabelStyle":
                if let args = call.arguments as? [String: Any] {
                    self.args["labelStyle"] = args["labelStyle"]
                    self.createHostingView()
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing labelStyle", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func parseArguments(_ args: [String: Any]) -> LabelModel {
        return LabelModel(
            text: args["text"] as? String ?? "",
            iconName: args["iconName"] as? String,
            iconSize: (args["iconSize"] as? NSNumber).map { CGFloat(truncating: $0) },
            iconColor: (args["iconColor"] as? NSNumber).map { ColorUtils.colorFromARGB($0.intValue) },
            iconRenderingMode: args["iconRenderingMode"] as? String,
            iconPaletteColors: (args["iconPaletteColors"] as? [NSNumber])?.map { ColorUtils.colorFromARGB($0.intValue) },
            iconGradientEnabled: (args["iconGradientEnabled"] as? NSNumber)?.boolValue,
            color: (args["color"] as? NSNumber).map { ColorUtils.colorFromARGB($0.intValue) },
            font: (args["font"] as? [String: Any]).flatMap { FontUtils.swiftUIFontFromDictionary($0) },
            labelStyle: args["labelStyle"] as? String
        )
    }
}

private struct LabelModel {
    let text: String
    let iconName: String?
    let iconSize: CGFloat?
    let iconColor: NSColor?
    let iconRenderingMode: String?
    let iconPaletteColors: [NSColor]?
    let iconGradientEnabled: Bool?
    let color: NSColor?
    let font: Font?
    let labelStyle: String?
}

private struct LabelContent: View {
    let model: LabelModel
    let onSizeChanged: (CGSize) -> Void
    @State private var measuredSize: CGSize = .zero

    var body: some View {
        styledLabel
            .padding(0)
    }

    private var styledLabel: some View {
        let base = labelView
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                onSizeChanged(newValue)
            }
            .font(model.font)
            .foregroundColor(model.color.map(Color.init))
            .symbolRenderingMode(symbolRenderingModeFromString(from: model.iconRenderingMode))

        switch model.labelStyle {
        case "titleOnly":
            return AnyView(base.labelStyle(TitleOnlyLabelStyle()))
        case "iconOnly":
            return AnyView(base.labelStyle(IconOnlyLabelStyle()))
        case "titleAndIcon":
            return AnyView(base.labelStyle(TitleAndIconLabelStyle()))
        default:
            return AnyView(base.labelStyle(DefaultLabelStyle()))
        }
    }

    @ViewBuilder
    private var labelView: some View {
        if let iconName = model.iconName, !iconName.isEmpty {
            Label(model.text, systemImage: iconName)
        } else {
            Text(model.text)
        }
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

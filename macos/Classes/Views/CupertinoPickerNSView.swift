import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoPickerNSView: NSView {
    private let channel: FlutterMethodChannel
    private var hostingView: NSHostingView<PickerContent>?
    private var measuredSize: NSSize?
    private var payload = CNPickerPayload()

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "CupertinoNativePicker_\(viewId)", binaryMessenger: messenger)
        super.init(frame: .zero)

        _ = CNPickerDeserializer.applyPatch(args, to: &payload)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        appearance = NSAppearance(named: payload.isDark ? .darkAqua : .aqua)

        createPickerContent()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "getIntrinsicSize":
                let size = measuredSize
                    ?? hostingView?.intrinsicContentSize
                    ?? NSSize(width: NSView.noIntrinsicMetric, height: 32)

                result(["width": size.width, "height": size.height])
            case "setPicker":
                if CNPickerDeserializer.applyPatch(call.arguments, to: &payload) {
                    createPickerContent()
                    result(nil)
                } else { result(FlutterError(code: "bad_args", message: "Missing picker payload", details: nil)) }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private func createPickerContent() {
        hostingView?.removeFromSuperview()

        let pickerModel = PickerModel(
            items: payload.items,
            labelChildren: payload.labelChildren,
            selectedIndex: payload.selectedIndex,
            pickerStyleName: payload.pickerStyleName,
            displayAsList: payload.asList,
            viewModifiers: payload.viewModifiers,
            onSelectionChange: { [weak self] newIndex in
                self?.payload.applyPatch(["selectedIndex": newIndex])
                self?.channel.invokeMethod("valueChanged", arguments: ["index": newIndex])
            },
            onSizeChange: { [weak self] newSize in
                guard let self else { return }
                measuredSize = NSSize(width: newSize.width, height: newSize.height)
                channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": newSize.width, "height": newSize.height],
                )
            },
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
    let labelChildren: [[String: Any]]
    let selectedIndex: Int
    let pickerStyleName: String
    let displayAsList: Bool
    let viewModifiers: CNViewModifiersPayload?
    let onSelectionChange: (Int) -> Void
    let onSizeChange: (CGSize) -> Void
}

struct PickerContent: View {
    @State var size: CGSize = .zero
    @State var selection: Int
    @State private var listBaselineSize: CGSize?
    let model: PickerModel

    init(model: PickerModel) {
        self.model = model
        _selection = State(initialValue: model.selectedIndex)
    }

    var body: some View {
        basePicker
    }

    private var basePicker: some View {
        let selectionBinding = Binding<Int>(
            get: { selection },
            set: { newValue in
                guard selection != newValue else {
                    selection = newValue
                    return
                }

                selection = newValue
                model.onSelectionChange(newValue)
            },
        )

        let hasLabelContent = !model.labelChildren.isEmpty

        let pickerBase = Picker(selection: selectionBinding) {
            ForEach(model.items.indices, id: \.self) { index in
                let item = model.items[index]
                let tag = CNPickerDeserializer.itemTag(for: item, fallback: index)
                itemView(for: item)
                    .tag(tag)
            }
        } label: {
            if !model.labelChildren.isEmpty {
                pickerLabelChildren(model.labelChildren)
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            reportMeasuredSize(newValue, fromListContainer: hasLabelContent)
        }

        var picker = applyPickerStyle(to: pickerBase)

        picker = CNViewModifiers.apply(model.viewModifiers, to: picker)

        let shouldUseListContainer = hasLabelContent && model.displayAsList

        func reportMeasuredSize(_ newValue: CGSize, fromListContainer: Bool) {
            let adjusted: CGSize

            if fromListContainer {
                // List can create a feedback loop with intrinsic sizing updates.
                // Keep a stable baseline and apply the compensation once.
                if let baseline = listBaselineSize {
                    let widthChanged = abs(newValue.width - baseline.width) > 0.5
                    let becameSmaller = newValue.height < baseline.height
                    if widthChanged || becameSmaller {
                        listBaselineSize = newValue
                    }
                } else {
                    listBaselineSize = newValue
                }

                let baseline = listBaselineSize ?? newValue
                adjusted = CGSize(
                    width: baseline.width,
                    height: baseline.height + 28.0,
                )
            } else {
                adjusted = newValue
            }

            // Avoid spamming Flutter with repeated identical values.
            if abs(size.width - adjusted.width) < 0.5, abs(size.height - adjusted.height) < 0.5 {
                return
            }

            size = adjusted
            model.onSizeChange(adjusted)
        }

        let plainPicker = picker
        if shouldUseListContainer {
            return AnyView(List {
                plainPicker
            })
        }

        return plainPicker
    }

    private func applyPickerStyle(to picker: some View) -> AnyView {
        switch model.pickerStyleName {
        case "segmented":
            AnyView(picker.pickerStyle(.segmented))
        case "inline":
            AnyView(picker.pickerStyle(.inline))
        case "menu":
            AnyView(picker.pickerStyle(.menu))
        case "palette":
            AnyView(picker.pickerStyle(.palette))
        case "radioGroup":
            AnyView(picker.pickerStyle(.radioGroup))
        default:
            AnyView(picker.pickerStyle(.automatic))
        }
    }

    @ViewBuilder
    private func itemView(for item: [String: Any]) -> some View {
        if let children = item["children"] as? [[String: Any]], !children.isEmpty {
            pickerOptionChildren(children)
        } else {
            let hasText = item["text"] as? String != nil
            let hasIcon = item["symbolName"] as? String != nil

            if hasIcon, hasText {
                HStack {
                    buildStyledImage(symbolName: item["symbolName"] as! String, from: item)
                    Text(item["text"] as? String ?? "")
                }
            } else if hasIcon, let symbolName = item["symbolName"] as? String {
                buildStyledImage(symbolName: symbolName, from: item)
            } else {
                Text(item["text"] as? String ?? "")
            }
        }
    }

    @ViewBuilder
    private func pickerLabelChildren(_ children: [[String: Any]]) -> some View {
        if children.count == 1 {
            deserializeButtonChild(children[0])
        } else {
            Group {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    deserializeButtonChild(child)
                }
            }
        }
    }

    @ViewBuilder
    private func pickerOptionChildren(_ children: [[String: Any]]) -> some View {
        if children.count == 1 {
            deserializeButtonChild(children[0])
        } else {
            Group {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    deserializeButtonChild(child)
                }
            }
        }
    }

    private func deserializeButtonChild(_ child: [String: Any]) -> AnyView {
        guard let type = child["type"] as? String,
              let payload = child["payload"] as? [String: Any]
        else {
            return AnyView(EmptyView())
        }

        switch type {
        case "image":
            return CNImage.deserialize(payload) ?? AnyView(EmptyView())
        case "label":
            return CNLabel.deserialize(payload) ?? AnyView(EmptyView())
        case "text":
            return CNText.deserialize(payload) ?? AnyView(EmptyView())
        case "progressView":
            return CNProgressViewDeserializer.deserialize(payload) ?? AnyView(EmptyView())
        default:
            return AnyView(EmptyView())
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
            .monochrome
        case "hierarchical":
            .hierarchical
        case "multicolor":
            .multicolor
        case "palette":
            .palette
        default:
            nil
        }
    }
}

// MARK: - SwiftUI Components (end)

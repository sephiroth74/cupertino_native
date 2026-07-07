import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoPickerNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNPickerViewModel
    private var measuredSize: CGSize?
    private var payload: CNPickerPayload
    private var viewId: Int64

    private var logPrefix: String {
        let debugId = payload.debugWidgetId ?? "unknown"
        return "[CNPicker][\(debugId)][Swift_\(viewId)]"
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.viewId = viewId
        channel = FlutterMethodChannel(name: "CupertinoNativePicker_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))
        payload = CNPickerDeserializer.decode(args) ?? Self.defaultPayload()
        model = CNPickerViewModel(payload: payload)
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        installRootView()
        updateAppearance()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }

            switch call.method {
            case "getIntrinsicSize":
                NSLog("\(logPrefix) method call received: \(call.method)")
                var size = currentIntrinsicSize()
                if isTransientIntrinsicSize(size) {
                    size = .zero
                }

                result(["width": size.width, "height": size.height])
            case "setData":
                NSLog("\(logPrefix) method call received: \(call.method) with args: \(String(describing: call.arguments))")
                if let parsed = CNPickerDeserializer.decode(call.arguments) {
                    measuredSize = nil
                    payload = parsed
                    model.replace(with: parsed)
                    updateAppearance()
                    schedulePostLayoutIntrinsicRefresh(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing picker payload", details: nil))
                }
            case "applyPatch":
                NSLog("\(logPrefix) method call received: \(call.method) with args: \(String(describing: call.arguments))")
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    measuredSize = nil
                    payload.applyPatch(patch)
                    model.applyPatch(patch)
                    updateAppearance()
                    schedulePostLayoutIntrinsicRefresh(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing picker payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private static func defaultPayload() -> CNPickerPayload {
        CNPickerPayload(channel: [:])!
    }

    private func installRootView() {
        hostingView.rootView = AnyView(PickerContent(
            model: model,
            onSelectionChange: { [weak self] newIndex in
                self?.payload.applyPatch(["selectedIndex": newIndex])
                self?.model.updateSelection(newIndex)
                self?.channel.invokeMethod("valueChanged", arguments: ["index": newIndex])
            },
            onSizeChange: { [weak self] newSize in
                guard let self else { return }
                if isTransientIntrinsicSize(newSize) {
                    NSLog("\(logPrefix) ignoring transient intrinsic size: width=\(newSize.width), height=\(newSize.height)")
                    return
                }

                measuredSize = currentIntrinsicSize()
                NSLog("\(logPrefix) onSizeChange. newSize: \(newSize), currentSize: \(measuredSize!)")

                channel.invokeMethod(
                    "intrinsicSizeChanged",
                    arguments: ["width": measuredSize!.width, "height": measuredSize!.height],
                )
            },
        ))

        schedulePostLayoutIntrinsicRefresh(force: true)
    }

    private func updateAppearance() {
        appearance = NSAppearance(named: payload.isDark ? .darkAqua : .aqua)
    }

    private func currentIntrinsicSize() -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

        if let measuredSize, measuredSize.width > 0, measuredSize.height > 0 {
            return measuredSize
        }

        let intrinsic = hostingView.intrinsicContentSize
        let fitting = hostingView.fittingSize

        let width = max(
            intrinsic.width == NSView.noIntrinsicMetric ? 0 : intrinsic.width,
            fitting.width,
        )
        let height = max(
            intrinsic.height == NSView.noIntrinsicMetric ? 0 : intrinsic.height,
            fitting.height,
        )

        return CGSize(width: width, height: height)
    }

    private func notifyIntrinsicSizeChanged(force: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let size = currentIntrinsicSize()
            if isTransientIntrinsicSize(size) {
                return
            }

            guard size.width > 0, size.height > 0 else {
                return
            }

            if !force,
               let measuredSize,
               abs(measuredSize.width - size.width) < 0.5,
               abs(measuredSize.height - size.height) < 0.5
            {
                return
            }

            measuredSize = NSSize(width: size.width, height: size.height)
            channel.invokeMethod(
                "intrinsicSizeChanged",
                arguments: ["width": size.width, "height": size.height],
            )
        }
    }

    private func schedulePostLayoutIntrinsicRefresh(force: Bool = false) {
        notifyIntrinsicSizeChanged(force: force)

        let retries: [Double] = [0.05, 0.15]
        for delay in retries {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.notifyIntrinsicSizeChanged(force: force)
            }
        }
    }

    private func isTransientIntrinsicSize(_ size: CGSize) -> Bool {
        guard size.width > 0, size.height > 0 else {
            return true
        }

        let hasExplicitTightWidth: Bool = {
            guard let constraints = payload.viewModifiers.constraints,
                  let minWidth = constraints.minWidth,
                  let maxWidth = constraints.maxWidth,
                  minWidth.isFinite,
                  maxWidth.isFinite
            else {
                return false
            }

            return abs(minWidth - maxWidth) < 0.5
        }()

        if !hasExplicitTightWidth, size.width <= 12.0 {
            return true
        }

        return false
    }
}

// MARK: - SwiftUI Components

final class CNPickerViewModel: ObservableObject {
    @Published private(set) var payload: CNPickerPayload

    init(payload: CNPickerPayload) {
        self.payload = payload
    }

    func replace(with payload: CNPickerPayload) {
        self.payload = payload
    }

    func applyPatch(_ patch: [String: Any]) {
        var next = payload
        next.applyPatch(patch)
        payload = next
    }

    func updateSelection(_ selectedIndex: Int) {
        guard payload.selectedIndex != selectedIndex else {
            return
        }

        var next = payload
        next.selectedIndex = selectedIndex
        payload = next
    }
}

struct PickerContent: View {
    @ObservedObject var model: CNPickerViewModel
    let onSelectionChange: (Int) -> Void
    let onSizeChange: (CGSize) -> Void
    @State var size: CGSize = .zero
    @State private var listBaselineSize: CGSize?

    var body: some View {
        basePicker.id(identityKey(for: model.payload))
    }

    private func identityKey(for payload: CNPickerPayload) -> String {
        [
            String(describing: payload.items),
            String(describing: payload.labelChildren),
            payload.pickerStyleName,
            String(payload.asList),
            String(payload.isDark),
            payload.viewModifiers.identityKey(),
        ].joined(separator: "|")
    }

    private var basePicker: some View {
        let payload = model.payload
        let selectionBinding = Binding<Int>(
            get: { model.payload.selectedIndex },
            set: { newValue in
                guard model.payload.selectedIndex != newValue else {
                    return
                }

                model.updateSelection(newValue)
                onSelectionChange(newValue)
            },
        )

        let hasLabelContent = !payload.labelChildren.isEmpty

        let pickerBase = Picker(selection: selectionBinding) {
            ForEach(payload.items.indices, id: \.self) { index in
                let item = payload.items[index]
                let tag = CNPickerDeserializer.itemTag(for: item, fallback: index)
                itemView(for: item)
                    .tag(tag)
            }
        } label: {
            if !payload.labelChildren.isEmpty {
                pickerLabelChildren(payload.labelChildren)
            }
        }

        var picker = applyPickerStyle(to: pickerBase)

        picker = CNViewModifiers.apply(payload.viewModifiers, to: picker)

        let shouldUseListContainer = hasLabelContent && payload.asList

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
            onSizeChange(adjusted)
        }

        func measuredView(_ view: AnyView, fromListContainer: Bool) -> AnyView {
            AnyView(
                view.onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    reportMeasuredSize(newValue, fromListContainer: fromListContainer)
                },
            )
        }

        let plainPicker = measuredView(picker, fromListContainer: false)
        if shouldUseListContainer {
            return measuredView(
                AnyView(List {
                    plainPicker
                }),
                fromListContainer: true,
            )
        }

        return plainPicker
    }

    private func applyPickerStyle(to picker: some View) -> AnyView {
        switch model.payload.pickerStyleName {
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

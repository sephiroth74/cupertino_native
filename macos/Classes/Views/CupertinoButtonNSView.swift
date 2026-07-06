import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoButtonNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private let model: CNButtonViewModel
    private var payload: CNButtonPayload
    private var lastReportedIntrinsicSize: CGSize?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))
        channel = FlutterMethodChannel(
            name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger,
        )
        payload = CNButton.decode(args) ?? Self.defaultPayload()
        model = CNButtonViewModel(payload: payload)
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        installRootView()
        updateAppearance()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let s = currentIntrinsicSize()
                NSLog("[CNButton][Swift] getIntrinsicSize -> width=\(s.width), height=\(s.height)")
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setData", "setButton":
                if let parsed: CNButtonPayload = CNChannelSerialization.decode(call.arguments) {
                    NSLog("[CNButton][Swift] setData <- \(parsed.toChannel())")
                    payload = parsed
                    model.replace(with: payload)
                    updateAppearance()
                    notifyIntrinsicSizeChanged(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid button payload", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    NSLog("[CNButton][Swift] applyPatch <- \(patch)")
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    updateAppearance()
                    notifyIntrinsicSizeChanged(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid button patch payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private static func defaultPayload() -> CNButtonPayload {
        CNButtonPayload(channel: [:])!
    }

    private func installRootView() {
        hostingView.rootView = CNButton.deserialize(
            model: model,
            onPressed: { [weak self] in
                self?.channel.invokeMethod("pressed", arguments: nil)
            },
            onSizeChanged: { [weak self] newSize in
                NSLog("[CNButton][Swift] onSizeChanged -> width=\(newSize.width), height=\(newSize.height)")
                self?.notifyIntrinsicSizeChanged()
            },
        )
    }

    private func updateAppearance() {
        if let isDark = payload.isDark {
            hostingView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            hostingView.appearance = nil
        }
    }

    private func currentIntrinsicSize() -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

        let natural = naturalContentSize()

        let intrinsic = hostingView.intrinsicContentSize
        let intrinsicWidth = intrinsic.width
        let intrinsicHeight = intrinsic.height

        let hasValidIntrinsic =
            intrinsicWidth > 0 &&
            intrinsicHeight > 0 &&
            intrinsicWidth != NSView.noIntrinsicMetric &&
            intrinsicHeight != NSView.noIntrinsicMetric

        if hasValidIntrinsic {
            return CGSize(
                width: max(natural.width, intrinsicWidth),
                height: max(natural.height, intrinsicHeight),
            )
        }

        let fitting = hostingView.fittingSize
        return CGSize(
            width: max(natural.width, fitting.width),
            height: max(natural.height, fitting.height),
        )
    }

    private func naturalContentSize() -> CGSize {
        let rootView = CNButton.deserialize(payload.toChannel()) ?? AnyView(EmptyView())
        let measuringView = NSHostingView(rootView: rootView)
        measuringView.appearance = hostingView.appearance
        measuringView.layoutSubtreeIfNeeded()

        let measuredIntrinsic = measuringView.intrinsicContentSize
        let measuredFitting = measuringView.fittingSize

        return CGSize(
            width: max(0, measuredIntrinsic.width, measuredFitting.width),
            height: max(0, measuredIntrinsic.height, measuredFitting.height),
        )
    }

    private func notifyIntrinsicSizeChanged(force: Bool = false) {
        let size = currentIntrinsicSize()
        guard size.width > 0, size.height > 0 else {
            return
        }

        if !force, lastReportedIntrinsicSize == size {
            return
        }

        lastReportedIntrinsicSize = size
        NSLog("[CNButton][Swift] intrinsicSizeChanged -> width=\(size.width), height=\(size.height)")
        channel.invokeMethod(
            "intrinsicSizeChanged",
            arguments: ["width": size.width, "height": size.height],
        )
    }
}

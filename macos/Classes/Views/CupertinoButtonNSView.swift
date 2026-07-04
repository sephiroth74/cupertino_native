import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoButtonNSView: NSView {
    private let channel: FlutterMethodChannel
    private let hostingView: NSHostingView<AnyView>
    private var payload: CNButtonPayload?
    private var lastReportedIntrinsicSize: CGSize?

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))
        channel = FlutterMethodChannel(
            name: "CupertinoNativeButton_\(viewId)", binaryMessenger: messenger,
        )
        payload = CNButton.decode(args)
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

        rebuild()

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "getIntrinsicSize":
                let s = currentIntrinsicSize()
                result(["width": Double(s.width), "height": Double(s.height)])
            case "setButton":
                if let parsed: CNButtonPayload = CNChannelSerialization.decode(call.arguments) {
                    payload = parsed
                    rebuild()
                    notifyIntrinsicSizeChanged(force: true)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Invalid button payload", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    private func rebuild() {
        guard let payload else {
            hostingView.rootView = AnyView(EmptyView())
            return
        }

        if let isDark = payload.isDark {
            hostingView.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
        } else {
            hostingView.appearance = nil
        }

        hostingView.rootView = CNButton.deserialize(
            payload.toChannel(),
            onPressed: { [weak self] in
                self?.channel.invokeMethod("pressed", arguments: nil)
            },
            onSizeChanged: { [weak self] _ in
                self?.notifyIntrinsicSizeChanged()
            },
        ) ?? AnyView(EmptyView())

        // A second pass on the next runloop avoids reporting a transient
        // geometry value before SwiftUI finishes laying out the button label.
        DispatchQueue.main.async { [weak self] in
            self?.notifyIntrinsicSizeChanged()
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
        guard let payload else {
            return .zero
        }

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
        channel.invokeMethod(
            "intrinsicSizeChanged",
            arguments: ["width": size.width, "height": size.height],
        )
    }
}

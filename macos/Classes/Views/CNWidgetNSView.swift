import Cocoa
import FlutterMacOS
import SwiftUI

/// Generic base NSView for SwiftUI-backed CN widgets.
///
/// Handles the entire platform view lifecycle:
/// - Channel setup with `setData` / `applyPatch` dispatch
/// - NSHostingView + AutoLayout
/// - Intrinsic size measurement and notification
///
/// Subclasses only need to provide:
/// - `channelName`: the channel prefix (e.g. `"CupertinoNativeImage2"`)
/// - `defaultPayload(viewId:)`: fallback payload when creation args are invalid
/// - `makeRootView(model:onSizeChanged:)`: the SwiftUI view bound to the model
class CNWidgetNSView<P: CNChannelDeserializable>: NSView {
    let channel: FlutterMethodChannel
    let hostingView: NSHostingView<AnyView>
    let model: CNViewModel<P>
    var payload: P
    private var measuredSize: CGSize?

    var logPrefix: String {
        "[\(type(of: self))][\(payload.viewDebugId)][Swift]"
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        let channelName = Self.channelName
        channel = FlutterMethodChannel(name: "\(channelName)_\(viewId)", binaryMessenger: messenger)
        hostingView = NSHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelDeserialization.decode(args, viewId: viewId) ?? Self.defaultPayload(viewId)
        model = CNViewModel<P>(payload: payload)

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
        configureMethodChannel(viewId: viewId)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Subclass requirements

    /// The method channel name prefix. Override in subclasses.
    class var channelName: String {
        fatalError("Subclasses must override channelName")
    }

    /// Provides a fallback payload when creation args cannot be decoded.
    class func defaultPayload(_: Int64) -> P {
        fatalError("Subclasses must override defaultPayload(_:)")
    }

    /// Creates the SwiftUI root view bound to the view model.
    /// Override in subclasses to provide the widget-specific SwiftUI body.
    func makeRootView(model _: CNViewModel<P>, onSizeChanged _: @escaping (CGSize) -> Void) -> AnyView {
        fatalError("Subclasses must override makeRootView(model:onSizeChanged:)")
    }

    /// Override to handle additional method calls beyond `setData`, `applyPatch`, `getIntrinsicSize`.
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("\(logPrefix) Unhandled method call: \(call.method)")
        result(FlutterMethodNotImplemented)
    }

    // MARK: - Private

    private func installRootView() {
        hostingView.rootView = makeRootView(model: model) { [weak self] _ in
            guard let self else { return }
            measuredSize = currentIntrinsicSize()
            channel.invokeMethod(
                "intrinsicSizeChanged",
                arguments: ["width": measuredSize!.width, "height": measuredSize!.height],
            )
        }
    }

    private func configureMethodChannel(viewId: Int64) {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { result(nil); return }
            switch call.method {
            case "setData":
                if let args = CNChannelDeserialization.asDict(call.arguments) {
                    guard let decoded = P(channel: args, viewId: viewId) else {
                        result(FlutterError(code: "bad_args", message: "Failed to decode payload", details: nil))
                        return
                    }
                    payload = decoded
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelDeserialization.asDict(call.arguments) {
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            case "getIntrinsicSize":
                let size = currentIntrinsicSize()
                result(["width": size.width, "height": size.height])
            default:
                handleMethodCall(call, result: result)
            }
        }
    }

    func currentIntrinsicSize() -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

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
}

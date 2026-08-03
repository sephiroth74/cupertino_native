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
/// - `makeRootView(model:)`: the SwiftUI view bound to the model
class CNWidgetNSView<P: CNChannelDeserializable>: NSView {
    let channel: FlutterMethodChannel
    let hostingView: CNMeasuringHostingView<AnyView>
    let model: CNViewModel<P>
    var payload: P

    /// The last intrinsic size pushed to (or pulled by) Flutter.
    /// Used to avoid redundant `intrinsicSizeChanged` notifications and to
    /// detect when a deferred re-measurement produced a corrected size.
    private var lastReportedSize: CGSize?

    /// Coalesces multiple size-report requests within a single runloop turn.
    private var reportPending = false

    var logPrefix: String {
        "[\(type(of: self))][\(payload.viewDebugId)][Swift]"
    }

    /// Logs a message only when the payload's `debugLog` flag is enabled.
    func log(_ message: String) {
        guard let shared = payload as? any CNSharedPayloadFields, shared.debugLog else { return }
        NSLog("\(logPrefix) \(message)")
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        let channelName = Self.channelName
        channel = FlutterMethodChannel(name: "\(channelName)_\(viewId)", binaryMessenger: messenger)
        hostingView = CNMeasuringHostingView(rootView: AnyView(EmptyView()))

        payload = CNChannelDeserialization.decode(args, viewId: viewId) ?? Self.defaultPayload(viewId)
        model = CNViewModel<P>(payload: payload)

        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)

        // Flutter owns all safe-area layout; the platform view is placed exactly
        // where Flutter decides. Left at its default, an NSHostingView inherits the
        // window's safe-area insets — most visibly the titlebar's top inset when the
        // control sits in a full-size-content-view region (e.g. a toolbar) — which
        // pushes the SwiftUI content down inside the hosting view's bounds and breaks
        // vertical centering. Clearing the safe-area regions makes SwiftUI fill the
        // hosting view's bounds directly. A no-op for controls outside any inset.
        if #available(macOS 13.3, *) {
            hostingView.safeAreaRegions = []
        }

        // SwiftUI recomputes the hosting view's ideal size asynchronously (e.g. once
        // text metrics for a Label settle). When that happens the hosting view
        // invalidates its intrinsic content size; re-measure on the next runloop turn
        // and push any corrected size to Flutter. This fixes shrink-mode widgets that
        // report a too-small size on their very first (pre-layout) measurement.
        hostingView.onIntrinsicSizeInvalidated = { [weak self] in
            self?.scheduleIntrinsicSizeReport()
        }

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        log("init: viewId=\(viewId), args=\(String(describing: args)), payload=\(payload)")

        installRootView()
        configureMethodChannel(viewId: viewId)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // Once attached to a window, SwiftUI has an environment to resolve fonts and
        // symbols; re-measure so shrink-mode widgets pick up their settled size even
        // if the intrinsic-size invalidation fired before the callback was wired.
        if window != nil {
            scheduleIntrinsicSizeReport()
        }
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
    func makeRootView(model _: CNViewModel<P>, onSizeChanged _: ((CGSize) -> Void)?) -> AnyView {
        fatalError("Subclasses must override makeRootView(model:onSizeChanged:)")
    }

    /// Override to handle additional method calls beyond `setData`, `applyPatch`, `getIntrinsicSize`.
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        NSLog("\(logPrefix) Unhandled method call: \(call.method)")
        result(FlutterMethodNotImplemented)
    }

    private func installRootView() {
        hostingView.rootView = makeRootView(model: model, onSizeChanged: { [weak self] _ in
            // The SwiftUI content geometry changed. Re-measure and push a corrected
            // size if it differs from what Flutter last saw. Routed through the
            // coalesced reporter so it can't race with intrinsic-size invalidations.
            self?.scheduleIntrinsicSizeReport()
        })
    }

    /// Schedules a coalesced intrinsic-size measurement on the next runloop turn and,
    /// if the measured size differs from the last one Flutter saw, notifies Flutter.
    ///
    /// Deferring to the next turn lets SwiftUI finish the layout pass that triggered
    /// the invalidation (text metrics, symbol sizing, …) before we measure, so the
    /// first report already carries the settled size rather than a pre-layout one.
    private func scheduleIntrinsicSizeReport() {
        guard !reportPending else { return }
        reportPending = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            reportPending = false
            reportIntrinsicSizeIfChanged()
        }
    }

    private func reportIntrinsicSizeIfChanged() {
        let size = currentIntrinsicSize(originalSize: nil)
        guard size.width > 0, size.height > 0 else { return }
        guard size != lastReportedSize else { return }
        log("reportIntrinsicSizeIfChanged: \(lastReportedSize.map(String.init(describing:)) ?? "nil") -> \(size)")
        lastReportedSize = size
        channel.invokeMethod("intrinsicSizeChanged", arguments: ["width": size.width, "height": size.height])
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
                    log("setData keys=\(Array(args.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelDeserialization.asDict(call.arguments) {
                    payload.applyPatch(patch)
                    model.replace(with: payload)
                    log("applyPatch keys=\(Array(patch.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            case "getIntrinsicSize":
                let size = currentIntrinsicSize(originalSize: nil)
                lastReportedSize = size
                log("getIntrinsicSize -> \(size)")
                result(["width": size.width, "height": size.height])
            default:
                handleMethodCall(call, result: result)
            }
        }
    }

    func currentIntrinsicSize(originalSize: CGSize?) -> CGSize {
        layoutSubtreeIfNeeded()
        hostingView.layoutSubtreeIfNeeded()

        let intrinsic = hostingView.intrinsicContentSize
        let intrinsicWidth = intrinsic.width == NSView.noIntrinsicMetric ? 0 : intrinsic.width
        let intrinsicHeight = intrinsic.height == NSView.noIntrinsicMetric ? 0 : intrinsic.height

        // A fixed-size control (SwiftUI `.fixedSize()`) draws at its natural size and
        // must be measured from `intrinsicContentSize` alone. The hosting view is
        // pinned to this view's four edges, so `fittingSize` echoes whatever frame
        // Flutter imposed; maxing with it would feed a runaway loop (frame grows →
        // fittingSize grows → Flutter grows the frame …). Report the natural size so
        // the report stays stable and the parent can center the control in its band.
        if let fixedSizable = payload as? CNFixedSizablePayload, fixedSizable.fixedSize,
           intrinsicWidth > 0, intrinsicHeight > 0
        {
            return CGSize(width: intrinsicWidth, height: intrinsicHeight)
        }

        let fitting = hostingView.fittingSize
        let original = originalSize ?? .zero

        let width = max(intrinsicWidth, fitting.width, original.width)
        let height = max(intrinsicHeight, fitting.height, original.height)

        return CGSize(width: width, height: height)
    }
}

/// An `NSHostingView` that reports when SwiftUI invalidates its intrinsic content size.
///
/// SwiftUI recomputes a hosting view's ideal size asynchronously — for example once a
/// `Label`'s text metrics or an `Image`'s symbol dimensions settle after the first
/// layout pass. Each such recomputation calls `invalidateIntrinsicContentSize()`.
/// `onGeometryChange` alone can't detect this: once Flutter pins the platform view to
/// the (too-small) first measurement, the SwiftUI frame stops changing, so no further
/// geometry callbacks fire. Hooking the invalidation gives us a reliable signal to
/// re-measure and push the corrected size back to Flutter.
final class CNMeasuringHostingView<Content: View>: NSHostingView<Content> {
    var onIntrinsicSizeInvalidated: (() -> Void)?

    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        onIntrinsicSizeInvalidated?()
    }
}

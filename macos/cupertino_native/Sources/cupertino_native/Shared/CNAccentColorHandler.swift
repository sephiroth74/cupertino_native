import Cocoa
import FlutterMacOS

final class CNAccentColorHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var observer: NSObjectProtocol?

    func register(with registrar: FlutterPluginRegistrar) {
        let eventChannel = FlutterEventChannel(
            name: "cupertino_native/accent_color",
            binaryMessenger: registrar.messenger,
        )
        eventChannel.setStreamHandler(self)
    }

    // MARK: - FlutterStreamHandler

    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events

        // Send current value immediately
        events(currentAccentColorPayload())

        // Listen for system color changes
        observer = NotificationCenter.default.addObserver(
            forName: NSColor.systemColorsDidChangeNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            self?.eventSink?(self?.currentAccentColorPayload())
        }

        return nil
    }

    func onCancel(withArguments _: Any?) -> FlutterError? {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        eventSink = nil
        return nil
    }

    /// Returns the current accent color payload (for method channel fallback).
    func getCurrentAccentColor() -> [String: Any] {
        currentAccentColorPayload()
    }

    // MARK: - Private

    private func currentAccentColorPayload() -> [String: Any] {
        let color = NSColor.controlAccentColor
        let rgb = color.usingColorSpace(.sRGB) ?? color
        let argb = ColorUtils.colorToArgb(rgb)
        let name = resolveAccentColorName(color)
        return [
            "color": argb,
            "name": name,
        ]
    }

    private func resolveAccentColorName(_ color: NSColor) -> String {
        guard let rgb = color.usingColorSpace(.sRGB) else { return "blue" }
        let hue = rgb.hueComponent

        // macOS accent color hue values (sRGB)
        let mapping: [(range: ClosedRange<Double>, name: String)] = [
            (0.57 ... 0.64, "blue"),
            (0.76 ... 0.84, "purple"),
            (0.88 ... 0.94, "pink"),
            (0.95 ... 1.0, "red"),
            (0.0 ... 0.04, "red"),
            (0.04 ... 0.09, "orange"),
            (0.09 ... 0.18, "yellow"),
            (0.25 ... 0.40, "green"),
        ]

        for entry in mapping {
            if entry.range.contains(hue) {
                return entry.name
            }
        }

        // Graphite has very low saturation
        if rgb.saturationComponent < 0.01 {
            return "graphite"
        }

        return "blue"
    }
}

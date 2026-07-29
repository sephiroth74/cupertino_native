import Cocoa
import FlutterMacOS

class CupertinoSegmentedControlNSView: NSView {
    private let channel: FlutterMethodChannel
    private let segmentedControl = NSSegmentedControl(frame: .zero)
    private var isUpdatingFromDart = false
    private var debugLog = false
    private var trackingMode: NSSegmentedControl.SwitchTracking = .selectOne

    private func log(_ message: String) {
        guard debugLog else { return }
        NSLog("[CupertinoSegmentedControlNSView] \(message)")
    }

    init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "CupertinoNativeSegmentedControl_\(viewId)",
            binaryMessenger: messenger,
        )
        super.init(frame: .zero)

        setupControl()
        applyArgs(args)
        configureChannel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupControl() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        segmentedControl.target = self
        segmentedControl.action = #selector(segmentChanged(_:))

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Action

    @objc private func segmentChanged(_ sender: NSSegmentedControl) {
        guard !isUpdatingFromDart else { return }

        if trackingMode == .selectAny {
            var selected: [Int] = []
            for i in 0 ..< sender.segmentCount {
                if sender.isSelected(forSegment: i) {
                    selected.append(i)
                }
            }
            log("selectAnyChanged: \(selected)")
            channel.invokeMethod("selectAnyChanged", arguments: selected)
        } else {
            let index = sender.selectedSegment
            log("selectionChanged: \(index)")
            channel.invokeMethod("selectionChanged", arguments: index)
        }
    }

    // MARK: - Payload handling

    private func applyArgs(_ rawArgs: Any?) {
        guard let args = rawArgs as? [String: Any] else { return }
        applyPayload(args)
    }

    private func applyPayload(_ args: [String: Any]) {
        if let value = args["debugLog"] as? Bool {
            debugLog = value
        }

        if let segments = args["segments"] as? [[String: Any]] {
            rebuildSegments(segments)
        }

        if let styleName = args["segmentStyle"] as? String {
            segmentedControl.segmentStyle = segmentStyleFromString(styleName)
        }

        if let modeName = args["trackingMode"] as? String {
            let mode = trackingModeFromString(modeName)
            trackingMode = mode
            segmentedControl.trackingMode = mode
        }

        if let distName = args["segmentDistribution"] as? String {
            segmentedControl.segmentDistribution = segmentDistributionFromString(distName)
        }

        if let controlSize = args["controlSize"] as? String {
            segmentedControl.controlSize = ControlSizeUtils.controlSizeFromString(controlSize)
        }

        if let enabled = args["enabled"] as? Bool {
            segmentedControl.isEnabled = enabled
        }

        if let tint = args["tint"] as? Int {
            segmentedControl.selectedSegmentBezelColor = ColorUtils.colorFromARGB(tint)
        }

        if trackingMode == .selectAny {
            if let indices = args["selectedIndices"] as? [Int] {
                isUpdatingFromDart = true
                for i in 0 ..< segmentedControl.segmentCount {
                    segmentedControl.setSelected(indices.contains(i), forSegment: i)
                }
                isUpdatingFromDart = false
            }
        } else {
            if let index = args["selectedIndex"] as? Int {
                isUpdatingFromDart = true
                if index >= 0, index < segmentedControl.segmentCount {
                    segmentedControl.selectedSegment = index
                }
                isUpdatingFromDart = false
            }
        }

        if args.keys.contains("help") {
            segmentedControl.toolTip = args["help"] as? String
        }
    }

    private func rebuildSegments(_ segments: [[String: Any]]) {
        segmentedControl.segmentCount = segments.count

        for (i, segment) in segments.enumerated() {
            let label = segment["label"] as? String
            let systemImage = segment["systemImage"] as? String
            let enabled = segment["enabled"] as? Bool ?? true

            if let label {
                segmentedControl.setLabel(label, forSegment: i)
            } else {
                segmentedControl.setLabel("", forSegment: i)
            }

            if let systemImage {
                if let image = NSImage(systemSymbolName: systemImage, accessibilityDescription: label) {
                    segmentedControl.setImage(image, forSegment: i)
                    if label == nil {
                        segmentedControl.setImageScaling(.scaleProportionallyDown, forSegment: i)
                    }
                }
            }

            segmentedControl.setEnabled(enabled, forSegment: i)
        }
    }

    // MARK: - Channel

    private func configureChannel() {
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(nil)
                return
            }

            switch call.method {
            case "setData":
                if let args = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(args)
                    log("setData keys=\(Array(args.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing args", details: nil))
                }
            case "applyPatch":
                if let patch = CNChannelSerialization.asDict(call.arguments) {
                    applyPayload(patch)
                    log("applyPatch keys=\(Array(patch.keys))")
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing patch args", details: nil))
                }
            case "getIntrinsicSize":
                let size = segmentedControl.intrinsicContentSize
                log("getIntrinsicSize -> \(size)")
                result(["width": Double(size.width), "height": Double(size.height)])
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - Enum Conversion

    private func segmentStyleFromString(_ style: String) -> NSSegmentedControl.Style {
        switch style {
        case "rounded":
            .rounded
        case "texturedRounded":
            .texturedRounded
        case "capsule":
            .capsule
        case "texturedSquare":
            .texturedSquare
        case "separated":
            .separated
        default:
            .automatic
        }
    }

    private func trackingModeFromString(_ mode: String) -> NSSegmentedControl.SwitchTracking {
        switch mode {
        case "selectAny":
            .selectAny
        case "momentary":
            .momentary
        default:
            .selectOne
        }
    }

    private func segmentDistributionFromString(_ dist: String) -> NSSegmentedControl.Distribution {
        switch dist {
        case "fill":
            .fill
        case "fillEqually":
            .fillEqually
        case "fillProportionally":
            .fillProportionally
        default:
            .fit
        }
    }
}

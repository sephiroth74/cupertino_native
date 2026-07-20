import Cocoa
import FlutterMacOS

class CNAlert2Handler {
    private weak var registrar: FlutterPluginRegistrar?

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    // MARK: - Modal Alert (runModal)

    func showAlert(args: [String: Any], result: @escaping FlutterResult) {
        let alert = buildAlert(from: args)
        let actions = parseActions(args["actions"])

        DispatchQueue.main.async {
            let response = alert.runModal()
            result(self.buildResult(response: response, alert: alert, actions: actions))
        }
    }

    // MARK: - Sheet Alert (beginSheetModal)

    func showSheet(args: [String: Any], result: @escaping FlutterResult) {
        let alert = buildAlert(from: args)
        let actions = parseActions(args["actions"])

        DispatchQueue.main.async { [weak self] in
            guard let self, let window = registrar?.view?.window else {
                result(FlutterError(code: "window_unavailable", message: "No window available for sheet", details: nil))
                return
            }

            alert.beginSheetModal(for: window) { response in
                result(self.buildResult(response: response, alert: alert, actions: actions))
            }
        }
    }

    // MARK: - Shared

    private func buildAlert(from args: [String: Any]) -> NSAlert {
        let title = (args["title"] as? String) ?? ""
        let message = (args["message"] as? String) ?? ""
        let styleRaw = (args["style"] as? String) ?? "informational"
        let actions = parseActions(args["actions"])
        let suppressionButtonLabel = args["suppressionButtonLabel"] as? String
        let suppressionInitiallySelected = (args["suppressionInitiallySelected"] as? Bool) == true

        let alert = NSAlert()
        alert.messageText = title.isEmpty ? "Alert" : title
        alert.informativeText = message

        switch styleRaw {
        case "warning":
            alert.alertStyle = .warning
        case "critical":
            alert.alertStyle = .critical
        default:
            alert.alertStyle = .informational
        }

        if let suppressionButtonLabel, !suppressionButtonLabel.isEmpty {
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = suppressionButtonLabel
            alert.suppressionButton?.state = suppressionInitiallySelected ? .on : .off
        }

        for action in actions {
            let button = alert.addButton(withTitle: action.title)

            if #available(macOS 11.0, *) {
                button.hasDestructiveAction = action.role == "destructive"
            }

            if action.role == "cancel" {
                button.keyEquivalent = "\u{1b}"
            }
        }

        if !actions.isEmpty, !alert.buttons.isEmpty {
            alert.buttons[0].keyEquivalent = "\r"
        }

        return alert
    }

    private func buildResult(response: NSApplication.ModalResponse, alert: NSAlert, actions: [AlertAction]) -> [String: Any] {
        let firstRaw = NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
        let selectedIndex = max(Int(response.rawValue - firstRaw), 0)

        let selectedTag: String? = if selectedIndex < actions.count {
            actions[selectedIndex].tag
        } else {
            nil
        }

        let suppressionSelected = alert.suppressionButton?.state == .on

        return [
            "selectedIndex": selectedIndex,
            "selectedTag": selectedTag as Any,
            "suppressionSelected": suppressionSelected,
        ]
    }

    // MARK: - Parsing

    private struct AlertAction {
        let title: String
        let role: String?
        let tag: String?
        let enabled: Bool
    }

    private func parseActions(_ raw: Any?) -> [AlertAction] {
        guard let list = raw as? [[String: Any]], !list.isEmpty else {
            return [AlertAction(title: "OK", role: nil, tag: nil, enabled: true)]
        }

        return list.map { dict in
            let title = (dict["title"] as? String) ?? "OK"
            let role = dict["role"] as? String
            let tag = dict["tag"] as? String
            let enabled = (dict["enabled"] as? Bool) ?? true
            return AlertAction(title: title, role: role, tag: tag, enabled: enabled)
        }
    }
}

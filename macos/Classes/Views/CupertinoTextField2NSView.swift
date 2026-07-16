import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoTextField2NSView: CNWidgetNSView<CNTextField2Payload> {
    private var isUpdatingFromDart = false

    override class var channelName: String {
        "CupertinoNativeTextField2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNTextField2Payload {
        CNTextField2Payload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNTextField2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNTextField2Deserializer.makeRootView(
            model: model,
            onTextChanged: { [weak self] newText in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("textChanged", arguments: newText)
            },
            onSubmitted: { [weak self] text in
                self?.channel.invokeMethod("submitted", arguments: text)
            },
            onSizeChanged: onSizeChanged,
        )
    }

    override func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setText":
            if let args = CNChannelDeserialization.asDict(call.arguments),
               let value = args["value"] as? String
            {
                isUpdatingFromDart = true
                payload.text = value
                model.replace(with: payload)
                isUpdatingFromDart = false
                result(nil)
            } else {
                result(FlutterError(code: "bad_args", message: "Missing text value", details: nil))
            }
        case "setSelection":
            if let args = CNChannelDeserialization.asDict(call.arguments),
               let base = args["base"] as? Int,
               let extent = args["extent"] as? Int
            {
                isUpdatingFromDart = true
                channel.invokeMethod("selectionChanged", arguments: ["base": base, "extent": extent])
                isUpdatingFromDart = false
                result(nil)
            } else {
                result(FlutterError(code: "bad_args", message: "Missing selection values", details: nil))
            }
        default:
            super.handleMethodCall(call, result: result)
        }
    }
}

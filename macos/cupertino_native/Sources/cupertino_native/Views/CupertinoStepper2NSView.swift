import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoStepper2NSView: CNWidgetNSView<CNStepper2Payload> {
    override class var channelName: String {
        "CupertinoNativeStepper2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNStepper2Payload {
        CNStepper2Payload(channel: ["value": 0.0, "min": 0.0, "max": 100.0, "step": 1.0], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNStepper2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNStepper2Deserializer.makeRootView(
            model: model,
            onValueChanged: { [weak self] newValue in
                self?.channel.invokeMethod("valueChanged", arguments: ["value": newValue])
            },
            onEditingChanged: { [weak self] editing in
                self?.channel.invokeMethod("editingChanged", arguments: ["editing": editing])
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

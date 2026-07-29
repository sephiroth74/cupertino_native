import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoSlider2NSView: CNWidgetNSView<CNSlider2Payload> {
    override class var channelName: String {
        "CupertinoNativeSlider2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNSlider2Payload {
        CNSlider2Payload(channel: ["value": 0.0, "min": 0.0, "max": 1.0], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNSlider2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNSlider2Deserializer.makeRootView(
            model: model,
            onValueChanged: { [weak self] newValue in
                self?.payload.value = newValue
                self?.channel.invokeMethod("valueChanged", arguments: ["value": newValue])
            },
            onEditingChanged: { [weak self] editing in
                self?.channel.invokeMethod("editingChanged", arguments: ["editing": editing])
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

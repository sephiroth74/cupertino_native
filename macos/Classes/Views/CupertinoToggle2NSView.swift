import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoToggle2NSView: CNWidgetNSView<CNToggle2Payload> {
    override class var channelName: String {
        "CupertinoNativeToggle2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNToggle2Payload {
        CNToggle2Payload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNToggle2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNToggle2Deserializer.makeRootView(
            model: model,
            onValueChanged: { [weak self] newValue in
                self?.channel.invokeMethod("valueChanged", arguments: ["value": newValue])
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

import FlutterMacOS
import SwiftUI

class CupertinoButton2NSView: CNWidgetNSView<CNButton2Payload> {
    override class var channelName: String {
        "CupertinoNativeButton2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNButton2Payload {
        CNButton2Payload(viewId: viewId)
    }

    override func makeRootView(
        model: CNViewModel<CNButton2Payload>,
        onSizeChanged: ((CGSize) -> Void)?,
    ) -> AnyView {
        CNButton2Deserializer.makeRootView(
            model: model,
            onPressed: { [weak self] in
                self?.channel.invokeMethod("pressed", arguments: nil)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

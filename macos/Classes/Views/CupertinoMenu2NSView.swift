import FlutterMacOS
import SwiftUI

class CupertinoMenu2NSView: CNWidgetNSView<CNMenu2Payload> {
    override class var channelName: String {
        "CupertinoNativeMenu2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNMenu2Payload {
        CNMenu2Payload(viewId: viewId)
    }

    override func makeRootView(
        model: CNViewModel<CNMenu2Payload>,
        onSizeChanged: ((CGSize) -> Void)?,
    ) -> AnyView {
        CNMenu2Deserializer.makeRootView(
            model: model,
            onItemPressed: { [weak self] id in
                self?.channel.invokeMethod("itemPressed", arguments: id)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

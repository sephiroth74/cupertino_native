import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoProgressView2NSView: CNWidgetNSView<CNProgressView2Payload> {
    override class var channelName: String {
        "CupertinoNativeProgressView2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNProgressView2Payload {
        CNProgressView2Payload(channel: ["style": "linear", "total": 1.0], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNProgressView2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNProgressView2Deserializer.makeRootView(model: model, onSizeChanged: onSizeChanged)
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoText2NSView: CNWidgetNSView<CNText2Payload> {
    override class var channelName: String {
        "CupertinoNativeText2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNText2Payload {
        CNText2Payload(channel: ["text": ""], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNText2Payload>) -> AnyView {
        CNText2Deserializer.makeRootView(model: model)
    }
}

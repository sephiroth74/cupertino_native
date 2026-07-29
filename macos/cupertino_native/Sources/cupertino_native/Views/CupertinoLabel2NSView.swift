import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoLabel2NSView: CNWidgetNSView<CNLabel2Payload> {
    override class var channelName: String {
        "CupertinoNativeLabel2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNLabel2Payload {
        CNLabel2Payload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNLabel2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNLabel2Deserializer.makeRootView(model: model, onSizeChanged: onSizeChanged)
    }
}

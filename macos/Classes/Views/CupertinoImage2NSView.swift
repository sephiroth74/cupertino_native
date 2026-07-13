import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoImage2NSView: CNWidgetNSView<CNImage2Payload> {
    override class var channelName: String {
        "CupertinoNativeImage2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNImage2Payload {
        CNImage2Payload(channel: ["systemSymbolName": "questionmark.circle"], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNImage2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNImage2Deserializer.makeRootView(model: model, onSizeChanged: onSizeChanged)
    }
}

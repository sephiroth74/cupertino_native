import FlutterMacOS
import SwiftUI

class CupertinoGauge2NSView: CNWidgetNSView<CNGauge2Payload> {
    override class var channelName: String {
        "CupertinoNativeGauge2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNGauge2Payload {
        CNGauge2Payload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNGauge2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNGauge2Deserializer.makeRootView(model: model, onSizeChanged: onSizeChanged)
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoDatePicker2NSView: CNWidgetNSView<CNDatePicker2Payload> {
    override class var channelName: String {
        "CupertinoNativeDatePicker2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNDatePicker2Payload {
        CNDatePicker2Payload(channel: ["selection": Date().timeIntervalSince1970 * 1000], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNDatePicker2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNDatePicker2Deserializer.makeRootView(
            model: model,
            onDateChanged: { [weak self] newDate in
                let timestamp = newDate.timeIntervalSince1970 * 1000
                self?.channel.invokeMethod("dateChanged", arguments: ["timestamp": timestamp])
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

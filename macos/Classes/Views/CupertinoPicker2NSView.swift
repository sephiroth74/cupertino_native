import FlutterMacOS
import SwiftUI

class CupertinoPicker2NSView: CNWidgetNSView<CNPicker2Payload> {
    override class var channelName: String {
        "CupertinoNativePicker2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNPicker2Payload {
        CNPicker2Payload(viewId: viewId)
    }

    override func makeRootView(
        model: CNViewModel<CNPicker2Payload>,
        onSizeChanged: ((CGSize) -> Void)?,
    ) -> AnyView {
        CNPicker2Deserializer.makeRootView(
            model: model,
            onSelectionChanged: { [weak self] tag in
                self?.channel.invokeMethod("valueChanged", arguments: tag)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoTextField2NSView: CNWidgetNSView<CNTextField2Payload> {
    private var isUpdatingFromDart = false

    override class var channelName: String {
        "CupertinoNativeTextField2"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNTextField2Payload {
        CNTextField2Payload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNTextField2Payload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNTextField2Deserializer.makeRootView(
            model: model,
            onTextChanged: { [weak self] newText in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("textChanged", arguments: newText)
            },
            onSelectionChanged: { [weak self] base, extent in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("selectionChanged", arguments: ["base": base, "extent": extent])
            },
            onSubmitted: { [weak self] text in
                self?.channel.invokeMethod("submitted", arguments: text)
            },
            onFocusChanged: { [weak self] focused in
                self?.channel.invokeMethod("focusChanged", arguments: focused)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

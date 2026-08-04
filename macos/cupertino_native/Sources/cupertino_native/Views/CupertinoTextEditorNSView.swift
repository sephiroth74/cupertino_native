import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoTextEditorNSView: CNWidgetNSView<CNTextEditorPayload> {
    private var isUpdatingFromDart = false

    override class var channelName: String {
        "CupertinoNativeTextEditor"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNTextEditorPayload {
        CNTextEditorPayload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNTextEditorPayload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNTextEditorDeserializer.makeRootView(
            model: model,
            onTextChanged: { [weak self] newText in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("textChanged", arguments: newText)
            },
            onSelectionChanged: { [weak self] base, extent in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("selectionChanged", arguments: ["base": base, "extent": extent])
            },
            onFocusChanged: { [weak self] focused in
                self?.channel.invokeMethod("focusChanged", arguments: focused)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

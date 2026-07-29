import FlutterMacOS
import SwiftUI

class CupertinoSecureFieldNSView: CNWidgetNSView<CNSecureFieldPayload> {
    private var isUpdatingFromDart = false

    override class var channelName: String {
        "CupertinoNativeSecureField"
    }

    override class func defaultPayload(_ viewId: Int64) -> CNSecureFieldPayload {
        CNSecureFieldPayload(channel: [:], viewId: viewId)!
    }

    override func makeRootView(model: CNViewModel<CNSecureFieldPayload>, onSizeChanged: ((CGSize) -> Void)?) -> AnyView {
        CNSecureFieldDeserializer.makeRootView(
            model: model,
            onTextChanged: { [weak self] newText in
                guard let self, !isUpdatingFromDart else { return }
                channel.invokeMethod("textChanged", arguments: newText)
            },
            onSubmitted: { [weak self] text in
                self?.channel.invokeMethod("submitted", arguments: text)
            },
            onSizeChanged: onSizeChanged,
        )
    }
}

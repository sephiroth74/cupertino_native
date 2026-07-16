import Cocoa
import FlutterMacOS

class CupertinoTextField2Factory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        CupertinoTextField2NSView(viewId: viewId, args: args, messenger: messenger)
    }
}

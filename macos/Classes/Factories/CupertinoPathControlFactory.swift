import Cocoa
import FlutterMacOS

class CupertinoPathControlViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withViewIdentifier viewId: Int64, arguments args: Any?) -> NSView {
        CupertinoPathControlNSView(viewId: viewId, args: args, registrar: registrar)
    }
}

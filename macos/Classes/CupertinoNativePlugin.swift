import Cocoa
import FlutterMacOS

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var contextMenuHandler: CNContextMenuHandler?
    static var alert2Handler: CNAlert2Handler?
    static var popover2Handler: CNPopover2Handler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        CupertinoNativePlugin.registrar = registrar
        CupertinoNativePlugin.contextMenuHandler = CNContextMenuHandler(registrar: registrar)
        CupertinoNativePlugin.alert2Handler = CNAlert2Handler(registrar: registrar)
        CupertinoNativePlugin.popover2Handler = CNPopover2Handler(registrar: registrar)

        let channel = FlutterMethodChannel(
            name: "cupertino_native", binaryMessenger: registrar.messenger,
        )
        let instance = CupertinoNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // New architecture widgets
        let image2Factory = CupertinoImage2ViewFactory(messenger: registrar.messenger)
        registrar.register(image2Factory, withId: "CupertinoNativeImage2")

        let text2Factory = CupertinoText2ViewFactory(messenger: registrar.messenger)
        registrar.register(text2Factory, withId: "CupertinoNativeText2")

        let progressView2Factory = CupertinoProgressView2Factory(messenger: registrar.messenger)
        registrar.register(progressView2Factory, withId: "CupertinoNativeProgressView2")

        let slider2Factory = CupertinoSlider2Factory(messenger: registrar.messenger)
        registrar.register(slider2Factory, withId: "CupertinoNativeSlider2")

        let colorWell2Factory = CupertinoColorWell2Factory(messenger: registrar.messenger)
        registrar.register(colorWell2Factory, withId: "CupertinoNativeColorWell2")

        let datePicker2Factory = CupertinoDatePicker2Factory(messenger: registrar.messenger)
        registrar.register(datePicker2Factory, withId: "CupertinoNativeDatePicker2")

        let stepper2Factory = CupertinoStepper2Factory(messenger: registrar.messenger)
        registrar.register(stepper2Factory, withId: "CupertinoNativeStepper2")

        let textField2Factory = CupertinoTextField2Factory(messenger: registrar.messenger)
        registrar.register(textField2Factory, withId: "CupertinoNativeTextField2")

        let toggle2Factory = CupertinoToggle2Factory(messenger: registrar.messenger)
        registrar.register(toggle2Factory, withId: "CupertinoNativeToggle2")

        let searchField2Factory = CupertinoSearchField2Factory(messenger: registrar.messenger)
        registrar.register(searchField2Factory, withId: "CupertinoNativeSearchField2")

        let label2Factory = CupertinoLabel2Factory(messenger: registrar.messenger)
        registrar.register(label2Factory, withId: "CupertinoNativeLabel2")

        let button2Factory = CupertinoButton2Factory(messenger: registrar.messenger)
        registrar.register(button2Factory, withId: "CupertinoNativeButton2")

        let menu2Factory = CupertinoMenu2Factory(messenger: registrar.messenger)
        registrar.register(menu2Factory, withId: "CupertinoNativeMenu2")

        let picker2Factory = CupertinoPicker2Factory(messenger: registrar.messenger)
        registrar.register(picker2Factory, withId: "CupertinoNativePicker2")

        let secureFieldFactory = CupertinoSecureFieldFactory(messenger: registrar.messenger)
        registrar.register(secureFieldFactory, withId: "CupertinoNativeSecureField")

        let gauge2Factory = CupertinoGauge2Factory(messenger: registrar.messenger)
        registrar.register(gauge2Factory, withId: "CupertinoNativeGauge2")

        let pathControl2Factory = CupertinoPathControl2Factory(messenger: registrar.messenger)
        registrar.register(pathControl2Factory, withId: "CupertinoNativePathControl2")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        case "showAlert2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(FlutterError(code: "invalid_args", message: "showAlert2 expects a map of arguments", details: nil))
                return
            }
            guard let handler = CupertinoNativePlugin.alert2Handler else {
                result(FlutterError(code: "handler_unavailable", message: "Alert2 handler is not initialized", details: nil))
                return
            }
            handler.showAlert(args: args, result: result)
        case "showSheet2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(FlutterError(code: "invalid_args", message: "showSheet2 expects a map of arguments", details: nil))
                return
            }
            guard let handler = CupertinoNativePlugin.alert2Handler else {
                result(FlutterError(code: "handler_unavailable", message: "Alert2 handler is not initialized", details: nil))
                return
            }
            handler.showSheet(args: args, result: result)
        case "showPopover2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(FlutterError(code: "invalid_args", message: "showPopover2 expects a map of arguments", details: nil))
                return
            }
            guard let handler = CupertinoNativePlugin.popover2Handler else {
                result(FlutterError(code: "handler_unavailable", message: "Popover2 handler is not initialized", details: nil))
                return
            }
            handler.showPopover(args: args, result: result)
        case "showContextMenu2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(FlutterError(code: "invalid_args", message: "showContextMenu2 expects a map of arguments", details: nil))
                return
            }
            guard let handler = CupertinoNativePlugin.contextMenuHandler else {
                result(FlutterError(code: "handler_unavailable", message: "Context menu handler is not initialized", details: nil))
                return
            }
            handler.showContextMenu2(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FlutterPluginRegistrar {
    func getFlutterWindow() -> NSWindow? {
        view?.window
    }
}

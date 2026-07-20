import Cocoa
import FlutterMacOS

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
    static var registrar: FlutterPluginRegistrar?
    static var contextMenuHandler: CupertinoContextMenuHandler?
    static var toolbarManager: CNToolbarManager?
    static var alert2Handler: CNAlert2Handler?
    static var popover2Handler: CNPopover2Handler?

    public static func register(with registrar: FlutterPluginRegistrar) {
        CupertinoNativePlugin.registrar = registrar
        CupertinoNativePlugin.contextMenuHandler = CupertinoContextMenuHandler(registrar: registrar)
        CupertinoNativePlugin.toolbarManager = CNToolbarManager(messenger: registrar.messenger)
        CupertinoNativePlugin.alert2Handler = CNAlert2Handler(registrar: registrar)
        CupertinoNativePlugin.popover2Handler = CNPopover2Handler(registrar: registrar)
        let channel = FlutterMethodChannel(
            name: "cupertino_native", binaryMessenger: registrar.messenger,
        )
        let instance = CupertinoNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let toggleFactory = CupertinoToggleViewFactory(messenger: registrar.messenger)
        registrar.register(toggleFactory, withId: "cupertino_native/toggle")

        let segmentedFactory = CupertinoSegmentedControlViewFactory(messenger: registrar.messenger)
        registrar.register(segmentedFactory, withId: "CupertinoNativeSegmentedControl")

        let pickerFactory = CupertinoPickerViewFactory(messenger: registrar.messenger)
        registrar.register(pickerFactory, withId: "CupertinoNativePicker")

        let labelFactory = CupertinoLabelViewFactory(messenger: registrar.messenger)
        registrar.register(labelFactory, withId: "CupertinoNativeLabel")

        let tabBarFactory = CupertinoTabBarViewFactory(messenger: registrar.messenger)
        registrar.register(tabBarFactory, withId: "CupertinoNativeTabBar")

        let popupMenuFactory = CupertinoPopupMenuButtonViewFactory(messenger: registrar.messenger)
        registrar.register(popupMenuFactory, withId: "CupertinoNativePopupMenuButton")

        let menuFactory = CupertinoMenuViewFactory(messenger: registrar.messenger)
        registrar.register(menuFactory, withId: "CupertinoNativeMenu")

        let buttonFactory = CupertinoButtonViewFactory(messenger: registrar.messenger)
        registrar.register(buttonFactory, withId: "CupertinoNativeButton")

        let textViewFactory = CupertinoTextViewFactory(messenger: registrar.messenger)
        registrar.register(textViewFactory, withId: "CupertinoNativeTextView")

        let textFactory = CupertinoTextFactory(messenger: registrar.messenger)
        registrar.register(textFactory, withId: "CupertinoNativeText")

        let imageFactory = CupertinoImageFactory(messenger: registrar.messenger)
        registrar.register(imageFactory, withId: "CupertinoNativeImage")

        let testFactory = CupertinoImage2ViewFactory(messenger: registrar.messenger)
        registrar.register(testFactory, withId: "CupertinoNativeImage2")

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
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "showAlert2 expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            guard let handler = CupertinoNativePlugin.alert2Handler else {
                result(
                    FlutterError(
                        code: "handler_unavailable",
                        message: "Alert2 handler is not initialized",
                        details: nil,
                    ),
                )
                return
            }
            handler.showAlert(args: args, result: result)
        case "showSheet2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "showSheet2 expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            guard let handler = CupertinoNativePlugin.alert2Handler else {
                result(
                    FlutterError(
                        code: "handler_unavailable",
                        message: "Alert2 handler is not initialized",
                        details: nil,
                    ),
                )
                return
            }
            handler.showSheet(args: args, result: result)
        case "showPopover2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "showPopover2 expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            guard let handler = CupertinoNativePlugin.popover2Handler else {
                result(
                    FlutterError(
                        code: "handler_unavailable",
                        message: "Popover2 handler is not initialized",
                        details: nil,
                    ),
                )
                return
            }
            handler.showPopover(args: args, result: result)
        case "showContextMenu2":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "showContextMenu2 expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            guard let handler = CupertinoNativePlugin.contextMenuHandler else {
                result(
                    FlutterError(
                        code: "handler_unavailable",
                        message: "Context menu handler is not initialized",
                        details: nil,
                    ),
                )
                return
            }
            handler.showContextMenu2(args: args, result: result)
        case "makeToolbar":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "makeToolbar expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            makeToolbar(args: args, result: result)
        case "clearToolbar":
            clearToolbar(result: result)
        case "setToolbarColor":
            guard let args = CNChannelSerialization.asDict(call.arguments) else {
                result(
                    FlutterError(
                        code: "invalid_args",
                        message: "setToolbarColor expects a map of arguments",
                        details: nil,
                    ),
                )
                return
            }
            setToolbarColor(args: args, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func makeToolbar(args: [String: Any], result: @escaping FlutterResult) {
        guard let window = CupertinoNativePlugin.registrar?.view?.window else {
            result(
                FlutterError(
                    code: "window_unavailable",
                    message: "Unable to find host window for toolbar configuration",
                    details: nil,
                ),
            )
            return
        }

        guard let manager = CupertinoNativePlugin.toolbarManager else {
            result(
                FlutterError(
                    code: "toolbar_manager_unavailable",
                    message: "Toolbar manager is not initialized",
                    details: nil,
                ),
            )
            return
        }

        manager.makeToolbar(window: window, args: args, result: result)
    }

    private func setToolbarColor(args: [String: Any], result: @escaping FlutterResult) {
        guard let window = CupertinoNativePlugin.registrar?.view?.window else {
            result(
                FlutterError(
                    code: "window_unavailable",
                    message: "Unable to find host window for toolbar configuration",
                    details: nil,
                ),
            )
            return
        }

        guard let manager = CupertinoNativePlugin.toolbarManager else {
            result(
                FlutterError(
                    code: "toolbar_manager_unavailable",
                    message: "Toolbar manager is not initialized",
                    details: nil,
                ),
            )
            return
        }

        manager.setToolbarColor(window: window, args: args, result: result)
    }

    private func clearToolbar(result: @escaping FlutterResult) {
        guard let window = CupertinoNativePlugin.registrar?.view?.window else {
            result(
                FlutterError(
                    code: "window_unavailable",
                    message: "Unable to find host window for toolbar configuration",
                    details: nil,
                ),
            )
            return
        }

        guard let manager = CupertinoNativePlugin.toolbarManager else {
            result(
                FlutterError(
                    code: "toolbar_manager_unavailable",
                    message: "Toolbar manager is not initialized",
                    details: nil,
                ),
            )
            return
        }

        manager.clearToolbar(window: window, result: result)
    }
}

extension FlutterPluginRegistrar {
    func getFlutterWindow() -> NSWindow? {
        view?.window
    }
}

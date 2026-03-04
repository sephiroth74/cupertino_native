import Cocoa
import FlutterMacOS

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  static var registrar: FlutterPluginRegistrar?

  public static func register(with registrar: FlutterPluginRegistrar) {
    CupertinoNativePlugin.registrar = registrar
    let channel = FlutterMethodChannel(name: "cupertino_native", binaryMessenger: registrar.messenger)
    let instance = CupertinoNativePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let sliderFactory = CupertinoSliderViewFactory(messenger: registrar.messenger)
    registrar.register(sliderFactory, withId: "CupertinoNativeSlider")

    let switchFactory = CupertinoSwitchViewFactory(messenger: registrar.messenger)
    registrar.register(switchFactory, withId: "CupertinoNativeSwitch")

    let segmentedFactory = CupertinoSegmentedControlViewFactory(messenger: registrar.messenger)
    registrar.register(segmentedFactory, withId: "CupertinoNativeSegmentedControl")

    let iconFactory = CupertinoIconViewFactory(messenger: registrar.messenger)
    registrar.register(iconFactory, withId: "CupertinoNativeIcon")

    let tabBarFactory = CupertinoTabBarViewFactory(messenger: registrar.messenger)
    registrar.register(tabBarFactory, withId: "CupertinoNativeTabBar")

    let popupMenuFactory = CupertinoPopupMenuButtonViewFactory(messenger: registrar.messenger)
    registrar.register(popupMenuFactory, withId: "CupertinoNativePopupMenuButton")

    let buttonFactory = CupertinoButtonViewFactory(messenger: registrar.messenger)
    registrar.register(buttonFactory, withId: "CupertinoNativeButton")

    let colorWellFactory = CupertinoColorWellViewFactory(messenger: registrar.messenger)
    registrar.register(colorWellFactory, withId: "CupertinoNativeColorWell")

    let pathControlFactory = CupertinoPathControlViewFactory(registrar: registrar)
    registrar.register(pathControlFactory, withId: "CupertinoNativePathControl")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public static func getFlutterWindow() -> NSWindow? {
    return registrar?.view?.window
  }
}

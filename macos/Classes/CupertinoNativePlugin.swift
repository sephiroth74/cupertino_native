import Cocoa
import FlutterMacOS

public class CupertinoNativePlugin: NSObject, FlutterPlugin {
  static var registrar: FlutterPluginRegistrar?

  public static func register(with registrar: FlutterPluginRegistrar) {
    CupertinoNativePlugin.registrar = registrar
    let channel = FlutterMethodChannel(
      name: "cupertino_native", binaryMessenger: registrar.messenger)
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

    let progressIndicatorFactory = CupertinoProgressIndicatorViewFactory(
      messenger: registrar.messenger)
    registrar.register(progressIndicatorFactory, withId: "CupertinoNativeProgressIndicator")

    let levelIndicatorFactory = CupertinoLevelIndicatorViewFactory(messenger: registrar.messenger)
    registrar.register(levelIndicatorFactory, withId: "CupertinoNativeLevelIndicator")

    let stepperFactory = CupertinoStepperViewFactory(messenger: registrar.messenger)
    registrar.register(stepperFactory, withId: "CupertinoNativeStepper")

    let checkboxFactory = CupertinoCheckboxViewFactory(messenger: registrar.messenger)
    registrar.register(checkboxFactory, withId: "CupertinoNativeCheckbox")

    let comboButtonFactory = CupertinoComboButtonViewFactory(messenger: registrar.messenger)
    registrar.register(comboButtonFactory, withId: "CupertinoNativeComboButton")

    let datePickerFactory = CupertinoDatePickerViewFactory(messenger: registrar.messenger)
    registrar.register(datePickerFactory, withId: "CupertinoNativeDatePicker")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "showAlert":
      guard let args = call.arguments as? [String: Any] else {
        result(
          FlutterError(
            code: "invalid_args",
            message: "showAlert expects a map of arguments",
            details: nil))
        return
      }
      showAlert(args: args, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func showAlert(args: [String: Any], result: @escaping FlutterResult) {
    let title = (args["title"] as? String) ?? ""
    let message = (args["message"] as? String) ?? ""
    let styleRaw = (args["style"] as? String) ?? "informational"
    let rawActions = parseAlertActions(args["actions"])
    let suppressionButtonLabel = args["suppressionButtonLabel"] as? String
    let suppressionInitiallySelected = (args["suppressionInitiallySelected"] as? Bool) == true

    DispatchQueue.main.async {
      let alert = NSAlert()
      alert.messageText = title.isEmpty ? "Alert" : title
      alert.informativeText = message

      switch styleRaw {
      case "warning":
        alert.alertStyle = .warning
      case "critical":
        alert.alertStyle = .critical
      default:
        alert.alertStyle = .informational
      }

      if let suppressionButtonLabel, !suppressionButtonLabel.isEmpty {
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = suppressionButtonLabel
        alert.suppressionButton?.state = suppressionInitiallySelected ? .on : .off
      }

      for action in rawActions {
        let actionTitle = (action["title"] as? String) ?? "OK"
        let button = alert.addButton(withTitle: actionTitle)
        if #available(macOS 11.0, *) {
          button.hasDestructiveAction = (action["isDestructive"] as? Bool) == true
        }
        if actionTitle.lowercased() == "cancel" {
          button.keyEquivalent = "\u{1b}"
        }
      }

      for (index, action) in rawActions.enumerated() {
        if (action["isDefault"] as? Bool) == true, index < alert.buttons.count {
          alert.buttons[index].keyEquivalent = "\r"
          break
        }
      }

      let response = alert.runModal()
      let firstRaw = NSApplication.ModalResponse.alertFirstButtonReturn.rawValue
      let selectedIndex = Int(response.rawValue - firstRaw)
      let suppressionSelected = alert.suppressionButton?.state == .on
      result([
        "selectedIndex": max(selectedIndex, 0),
        "suppressionSelected": suppressionSelected,
      ])
    }
  }

  private func parseAlertActions(_ raw: Any?) -> [[String: Any]] {
    guard let list = raw as? [Any], !list.isEmpty else {
      return [["title": "OK", "isDefault": true]]
    }

    var parsed = [[String: Any]]()
    parsed.reserveCapacity(list.count)

    for item in list {
      if let dict = item as? [String: Any] {
        parsed.append(dict)
      } else if let dict = item as? [AnyHashable: Any] {
        var normalized = [String: Any]()
        for (key, value) in dict {
          if let stringKey = key as? String {
            normalized[stringKey] = value
          }
        }
        if !normalized.isEmpty {
          parsed.append(normalized)
        }
      }
    }

    return parsed.isEmpty ? [["title": "OK", "isDefault": true]] : parsed
  }
}

extension FlutterPluginRegistrar {
  func getFlutterWindow() -> NSWindow? {
    return view?.window
  }
}

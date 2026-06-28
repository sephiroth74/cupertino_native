import Cocoa
import FlutterMacOS
import SwiftUI

class CupertinoMenuButtonNSView: NSView {
  override var intrinsicContentSize: NSSize {
    if let measuredSize {
      return measuredSize
    }
    return hostingView?.intrinsicContentSize
      ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
  }

  private let channel: FlutterMethodChannel
  private var hostingView: NSHostingView<MenuButtonContent>?
  private var measuredSize: NSSize?
  private var args: [String: Any]

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "CupertinoNativeMenuButton_\(viewId)",
      binaryMessenger: messenger)
    self.args = args as? [String: Any] ?? [:]
    super.init(frame: .zero)

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    createHostingView()
    setupMethodCallHandler()
  }

  private func parseMenuItems(_ menuDict: [String: Any]) -> [MenuItemModel] {
    guard let items = menuDict["items"] as? [[String: Any]] else {
      return []
    }
    return items.compactMap { itemDict in
      let separator = itemDict["separator"] as? Bool ?? false
      let title = itemDict["title"] as? String ?? ""
      let subtitle = itemDict["subtitle"] as? String
      let systemImageName = itemDict["systemImageName"] as? String
      let tag = itemDict["tag"] as? Int
      let identifier = itemDict["identifier"] as? String ?? UUID().uuidString
      let enabled = itemDict["enabled"] as? Bool ?? true
      let state = itemDict["state"] as? String ?? "off"
      let image: NSImage?
      if let imageDict = itemDict["image"] as? [String: Any] {
        image = CupertinoImageDeserializer.deserialize(dict: imageDict)
      } else {
        image = nil
      }
      let submenuDict = itemDict["submenu"] as? [String: Any]
      let submenu = submenuDict != nil ? parseMenuItems(submenuDict!) : nil
      return MenuItemModel(
        separator: separator,
        title: title,
        subtitle: subtitle,
        systemImageName: systemImageName,
        image: image,
        tag: tag,
        identifier: identifier,
        enabled: enabled,
        state: state,
        submenu: submenu,
      )
    }
  }

  required init?(coder: NSCoder) {
    return nil
  }

  private func createHostingView() {
    hostingView?.removeFromSuperview()
    let content = MenuButtonContent(
      model: parseArguments(args),
      onSelection: { [weak self] identifier in
        self?.channel.invokeMethod("itemSelected", arguments: ["identifier": identifier])
      },
      onSizeChanged: { [weak self] size in
        guard let self else { return }
        self.measuredSize = NSSize(width: size.width, height: size.height)
        self.invalidateIntrinsicContentSize()
      }
    )
    let hosting = NSHostingView(rootView: content)
    hosting.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hosting)
    NSLayoutConstraint.activate([
      hosting.leadingAnchor.constraint(equalTo: leadingAnchor),
      hosting.trailingAnchor.constraint(equalTo: trailingAnchor),
      hosting.topAnchor.constraint(equalTo: topAnchor),
      hosting.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
    hostingView = hosting
  }

  private func setupMethodCallHandler() {
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let size = self.hostingView?.intrinsicContentSize ?? NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
        result(["width": Double(size.width), "height": Double(size.height)])
      case "setMenu":
        if let args = call.arguments as? [String: Any] {
          self.args["menu"] = args["menu"]
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing menu", details: nil))
        }
      case "setIsDark":
        if let args = call.arguments as? [String: Any], let isDark = (args["value"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
        }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any] {
          self.args["buttonTitle"] = args["buttonTitle"]
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing buttonTitle", details: nil))
        }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          self.args["buttonIconName"] = args["buttonIconName"]
          self.args["buttonIconSize"] = args["buttonIconSize"]
          self.args["buttonIconColor"] = args["buttonIconColor"]
          self.args["buttonIconRenderingMode"] = args["buttonIconRenderingMode"]
          self.args["buttonIconPaletteColors"] = args["buttonIconPaletteColors"]
          self.args["buttonIconGradientEnabled"] = args["buttonIconGradientEnabled"]
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing buttonIcon", details: nil))
        }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          self.args["buttonStyle"] = args["buttonStyle"]
          self.args["tint"] = args["tint"]
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
        }
      case "setControlSize":
        if let args = call.arguments as? [String: Any] {
          self.args["controlSize"] = args["controlSize"]
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing controlSize", details: nil))
        }
      case "setFocusable":
        if let args = call.arguments as? [String: Any], let focusable = (args["focusable"] as? NSNumber)?.boolValue {
          self.args["focusable"] = focusable
          self.createHostingView()
          result(nil)
        } else {
          result(FlutterError(code: "bad_args", message: "Missing focusable", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func parseArguments(_ args: [String: Any]) -> MenuButtonModel {
    let menuDict = args["menu"] as? [String: Any] ?? [:]
    return MenuButtonModel(
      items: parseMenuItems(menuDict),
      buttonTitle: args["buttonTitle"] as? String,
      buttonIconName: args["buttonIconName"] as? String,
      buttonIconSize: (args["buttonIconSize"] as? NSNumber).map { CGFloat(truncating: $0) },
      buttonIconColor: (args["buttonIconColor"] as? NSNumber).map { ColorUtils.colorFromARGB($0.intValue) },
      menuStyle: args["menuStyle"] as? String ?? "automatic",
      controlSize: args["controlSize"] as? String ?? "regular",
      focusable: (args["focusable"] as? NSNumber)?.boolValue ?? false,
      tintColor: (args["style"] as? [String: Any]).flatMap { style in
        if let tint = style["tint"] as? NSNumber {
          return ColorUtils.colorFromARGB(tint.intValue)
        }
        return nil
      }
    )
  }
}

private struct MenuButtonModel {
  let items: [MenuItemModel]
  let buttonTitle: String?
  let buttonIconName: String?
  let buttonIconSize: CGFloat?
  let buttonIconColor: NSColor?
  let menuStyle: String
  let controlSize: String
  let focusable: Bool
  let tintColor: NSColor?
}

private struct MenuItemModel {
  let separator: Bool
  let title: String
  let subtitle: String?
  let systemImageName: String?
  let image: NSImage?
  let tag: Int?
  let identifier: String
  let enabled: Bool
  let state: String
  let submenu: [MenuItemModel]?
}

private struct MenuButtonContent: View {
  let model: MenuButtonModel
  let onSelection: (String) -> Void
  let onSizeChanged: (CGSize) -> Void
  @State private var measuredSize: CGSize = .zero

  var body: some View {
    menuView
      .controlSize(SwiftUtils.controlSizeFromString(model.controlSize))
      .modifier(ConditionalMenuStyle(name: model.menuStyle))
      .focusable(model.focusable)
      .padding(0)
      .background(SizeReader(size: $measuredSize))
      .onChange(of: measuredSize) { newSize in
        onSizeChanged(newSize)
      }
  }

  private var menuView: some View {
    Menu {
      menuItems(model.items)
    } label: {
      buttonLabelView
    }
  }



  @ViewBuilder
  private var buttonLabelView: some View {
    if let iconName = model.buttonIconName, !iconName.isEmpty,
       let title = model.buttonTitle, !title.isEmpty {
      Label(title, systemImage: iconName)
    } else if let iconName = model.buttonIconName, !iconName.isEmpty {
      Image(systemName: iconName)
    } else if let title = model.buttonTitle {
      Text(title)
    } else {
      Text("Menu")
    }
  }

  @ViewBuilder
  private func rowView(for item: MenuItemModel) -> some View {
    if let systemImageName = item.systemImageName, !systemImageName.isEmpty {
        Label(item.title, systemImage: systemImageName)
    } else if let image = item.image {
        Image(nsImage: image)
        Text(item.title)
    } else {
        Text(item.title)
    }

    if let subtitle = item.subtitle, !subtitle.isEmpty {
        Text(subtitle)
    }
  }

  @ViewBuilder
  private func iconView(for item: MenuItemModel) -> some View {
    if let image = item.image {
      Image(nsImage: image)
    } else if let systemImage = item.systemImageName {
      Image(systemName: systemImage)
    }
  }

  // Apply a menu style conditionally using a type-erased ViewModifier
  private struct ConditionalMenuStyle: ViewModifier {
    let name: String
    func body(content: Content) -> some View {
      switch name {
      case "button":
        content.menuStyle(ButtonMenuStyle())
      case "borderlessButton":
        content.menuStyle(BorderlessButtonMenuStyle())
      case "borderedButton":
        content.menuStyle(BorderedButtonMenuStyle())
      default:
        content.menuStyle(DefaultMenuStyle())
      }
    }
  }

  // Helper that returns an erased AnyView for recursive menu building
  private func menuItems(_ items: [MenuItemModel]) -> AnyView {
    AnyView(
      ForEach(items, id: \ .identifier) { item in
        if item.separator {
          Divider()
        } else if let submenu = item.submenu {
          Menu(item.title) {
            menuItems(submenu)
          }
          .disabled(!item.enabled)
        } else {
          Button(action: { onSelection(item.identifier) }) {
            rowView(for: item)
          }
          .disabled(!item.enabled)
        }
      }
    )
  }
}

private struct SizeReader: View {
  @Binding var size: CGSize

  var body: some View {
    GeometryReader { proxy in
      Color.clear
        .preference(key: SizePreferenceKey.self, value: proxy.size)
    }
    .onPreferenceChange(SizePreferenceKey.self) { newSize in
      size = newSize
    }
  }
}

private struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

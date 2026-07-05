import SwiftUI

struct CNMenuItemModel {
    let separator: Bool
    let title: String
    let subtitle: String?
    let image: [String: Any]?
    let tag: Int?
    let identifier: String
    let enabled: Bool
    let state: String
    let submenu: [CNMenuItemModel]?
}

extension CNMenuItemModel: CNChannelSerializable {
    init?(channel: [String: Any]) {
        let separator = (channel["separator"] as? Bool) ?? false
        let title = (channel["title"] as? String) ?? ""
        let subtitle = channel["subtitle"] as? String
        let image = channel["image"] as? [String: Any]
        let tag = channel["tag"] as? Int
        let identifier = (channel["identifier"] as? String) ?? UUID().uuidString
        let enabled = (channel["enabled"] as? Bool) ?? true
        let state = (channel["state"] as? String) ?? "off"
        let submenu: [CNMenuItemModel]?
        let decodedSubmenu: [CNMenuItemModel] = CNChannelSerialization.decodeArray(channel["submenu"])
        submenu = decodedSubmenu.isEmpty ? nil : decodedSubmenu

        self.init(
            separator: separator,
            title: title,
            subtitle: subtitle,
            image: image,
            tag: tag,
            identifier: identifier,
            enabled: enabled,
            state: state,
            submenu: submenu,
        )
    }

    func toChannel() -> [String: Any] {
        var channel: [String: Any] = [
            "separator": separator,
            "title": title,
            "identifier": identifier,
            "enabled": enabled,
            "state": state,
        ]
        channel["subtitle"] = subtitle
        channel["image"] = image
        channel["tag"] = tag
        channel["submenu"] = submenu.map(CNChannelSerialization.encodeArray)
        return channel
    }
}

func parseCNMenuItems(_ rawMenu: Any?) -> [CNMenuItemModel] {
    guard let menuDict = CNChannelSerialization.asDict(rawMenu) else {
        return []
    }
    return CNChannelSerialization.decodeArray(menuDict["items"])
}

struct CNMenuEntriesView: View {
    let items: [CNMenuItemModel]
    let onSelection: (String) -> Void

    var body: some View {
        menuItems(items)
    }

    @ViewBuilder
    private func rowView(for item: CNMenuItemModel) -> some View {
        let hasTitle = !item.title.isEmpty
        let hasImage = item.image != nil

        if hasTitle, hasImage {
            Group {
                if let image = item.image,
                   let swiftImage = CNImage.deserialize(image)
                {
                    swiftImage
                }
                Text(item.title)
            }
        } else if hasTitle {
            Text(item.title)
        } else if hasImage {
            if let image = item.image,
               let swiftImage = CNImage.deserialize(image)
            {
                swiftImage
            }
        }
    }

    private func menuItems(_ items: [CNMenuItemModel]) -> AnyView {
        AnyView(
            ForEach(items, id: \.identifier) { item in
                if item.separator {
                    Divider()
                } else if let submenu = item.submenu {
                    Menu {
                        menuItems(submenu)
                    } label: {
                        rowView(for: item)
                    }
                    .disabled(!item.enabled)
                } else {
                    Button(action: { onSelection(item.identifier) }) {
                        rowView(for: item)
                    }
                    .disabled(!item.enabled)
                }
            },
        )
    }
}

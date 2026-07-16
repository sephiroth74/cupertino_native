import SwiftUI

enum CNChildViewBuilder {
    /// Builds a single child view from a dictionary payload.
    @ViewBuilder
    static func buildChild(_ dict: [String: Any]) -> some View {
        let type = dict["type"] as? String ?? ""
        switch type {
        case "text":
            buildText(dict)
        case "image":
            buildImage(dict)
        case "vstack":
            buildVStack(dict)
        case "hstack":
            buildHStack(dict)
        case "group":
            buildGroup(dict)
        case "label":
            buildLabel(dict)
        default:
            EmptyView()
        }
    }

    /// Builds multiple children into a single AnyView (using Group + ForEach pattern).
    static func buildChildren(_ list: [[String: Any]]) -> AnyView {
        AnyView(
            ForEach(Array(list.enumerated()), id: \.offset) { _, child in
                buildChild(child)
            },
        )
    }

    // MARK: - Leaf builders

    private static func buildText(_ dict: [String: Any]) -> some View {
        let text = dict["text"] as? String ?? ""
        var view = AnyView(Text(text))
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        if let lineLimit = dict["lineLimit"] as? Int {
            view = AnyView(view.lineLimit(lineLimit))
        }
        return view
    }

    private static func buildImage(_ dict: [String: Any]) -> some View {
        let name = dict["systemSymbolName"] as? String ?? "questionmark"
        var view = AnyView(Image(systemName: name))
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        return view
    }

    private static func buildLabel(_ dict: [String: Any]) -> some View {
        let title = dict["title"] as? String ?? ""
        let systemImage = dict["systemImage"] as? String

        var view = if let systemImage, !systemImage.isEmpty {
            AnyView(Label(title, systemImage: systemImage))
        } else {
            AnyView(Text(title))
        }
        view = CNViewModifierApplicator.applyFont(dict["font"] as? [String: Any], to: view)
        view = CNViewModifierApplicator.applyForegroundColor(dict["foregroundColor"] as? Int, to: view)
        return view
    }

    // MARK: - Container builders

    private static func buildVStack(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        let alignment = resolveHorizontalAlignment(dict["alignment"] as? String)
        let spacing = dict["spacing"] as? CGFloat

        return AnyView(
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    private static func buildHStack(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        let alignment = resolveVerticalAlignment(dict["alignment"] as? String)
        let spacing = dict["spacing"] as? CGFloat

        return AnyView(
            HStack(alignment: alignment, spacing: spacing) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    private static func buildGroup(_ dict: [String: Any]) -> some View {
        let children = dict["children"] as? [[String: Any]] ?? []
        return AnyView(
            Group {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in
                    buildChild(child)
                }
            },
        )
    }

    // MARK: - Alignment helpers

    private static func resolveHorizontalAlignment(_ value: String?) -> HorizontalAlignment {
        switch value {
        case "leading": .leading
        case "trailing": .trailing
        default: .center
        }
    }

    private static func resolveVerticalAlignment(_ value: String?) -> VerticalAlignment {
        switch value {
        case "top": .top
        case "bottom": .bottom
        default: .center
        }
    }
}

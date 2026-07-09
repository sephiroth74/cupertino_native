import SwiftUI

enum CNImage2Deserializer {
    static func deserialize(model: CNImage2ViewModel, onSizeChanged: ((CGSize) -> Void)? = nil) -> AnyView {
        AnyView(_CNBoundImage2View(model: model, onSizeChanged: onSizeChanged))
    }

    static func identityKey(for payload: CNImage2Payload) -> String {
        payload.identityKey()
    }

    private struct _CNBoundImage2View: View {
        @ObservedObject var model: CNImage2ViewModel
        let onSizeChanged: ((CGSize) -> Void)?

        var body: some View {
            let payload = model.payload
            var view = AnyView(Image(systemName: payload.systemSymbolName))
            view = applyConstraints(constraints: payload.constraints, shrink: payload.shrink, to: view)
            view = applyFont(payload.font, to: view)
            view = applyForegroundColor(payload.foregroundColor, to: view)
            view = applyTint(payload.tint, to: view)
            view = applyColorRenderingMode(to: view, payload: payload)
            view = applyRenderingMode(to: view, payload: payload)
            view = applyPaddings(payload.paddings, to: view)

            if let onSizeChanged {
                view = AnyView(
                    view.onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newSize in
                        onSizeChanged(newSize)
                    },
                )
            }

            return AnyView(view.id(identityKey(for: payload)))
        }
    }

    static func applyPaddings(_ paddings: CNPaddingsPayload?, to view: AnyView) -> AnyView {
        guard let paddings else {
            return view
        }

        return AnyView(
            view.padding(
                EdgeInsets(
                    top: paddings.top,
                    leading: paddings.leading,
                    bottom: paddings.bottom,
                    trailing: paddings.trailing,
                ),
            ),
        )
    }

    static func applyConstraints(constraints: CNBoxConstraintsPayload?, shrink: Bool, to view: AnyView) -> AnyView {
        guard let constraints, shrink == false else {
            return view
        }

        let minWidth = constraints.minWidth.map { CGFloat($0) }
        let idealWidth = constraints.tightWidth.map { CGFloat($0) }
        let maxWidth = constraints.maxWidth.map { CGFloat($0) }
        let minHeight = constraints.minHeight.map { CGFloat($0) }
        let idealHeight = constraints.tightHeight.map { CGFloat($0) }
        let maxHeight = constraints.maxHeight.map { CGFloat($0) }

        let framed = view.frame(
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
        )

        return AnyView(framed)
    }

    static func applyFont(_ fontDict: [String: Any]?, to view: AnyView) -> AnyView {
        guard let fontDict else {
            return view
        }

        if let symbolFont = FontUtils.swiftUIFontFromDictionary(fontDict) {
            return AnyView(view.font(symbolFont))
        }

        return view
    }

    static func applyForegroundColor(_ foregroundColor: Int?, to view: AnyView) -> AnyView {
        guard let foregroundColor else {
            return view
        }

        return AnyView(view.foregroundColor(ColorUtils.swiftUIColorFromARGB(foregroundColor)))
    }

    static func applyTint(_ tint: Int?, to view: AnyView) -> AnyView {
        guard let tint else {
            return view
        }

        return AnyView(view.tint(ColorUtils.swiftUIColorFromARGB(tint)))
    }

    @available(macOS 15.0, *)
    static func applyColorRenderingMode(to view: AnyView, payload: CNImage2Payload) -> AnyView {
        switch payload.symbolColorRenderingMode {
        case "flat":
            AnyView(view.symbolColorRenderingMode(.flat))
        case "gradient":
            AnyView(view.symbolColorRenderingMode(.gradient))
        default:
            view
        }
    }

    @available(macOS 12.0, *)
    static func applyRenderingMode(to view: AnyView, payload: CNImage2Payload) -> AnyView {
        switch payload.symbolRenderingMode {
        case "hierarchical":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.hierarchical))
        case "monochrome":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.monochrome))
        case "palette":
            let palette = payload.foregroundStyleColors.map(ColorUtils.swiftUIColorFromARGB)
            guard !palette.isEmpty else {
                return AnyView(view.symbolRenderingMode(.palette))
            }
            if palette.count == 1 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0]),
                )
            }
            if palette.count == 2 {
                return AnyView(
                    view
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(palette[0], palette[1]),
                )
            }
            return AnyView(
                view
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(palette[0], palette[1], palette[2]),
            )
        case "multicolor":
            if let first = payload.foregroundStyleColors.first {
                return AnyView(
                    view
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(ColorUtils.swiftUIColorFromARGB(first)),
                )
            }
            return AnyView(view.symbolRenderingMode(.multicolor))
        default:
            return view
        }
    }
}

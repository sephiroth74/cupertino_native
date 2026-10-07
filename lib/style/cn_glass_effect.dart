import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/style/cn_shape.dart';
import 'package:flutter/widgets.dart';

/// The material of a [CNGlassEffect].
///
/// Mirrors SwiftUI `Glass`.
enum CNGlassVariant {
  /// The standard Liquid Glass material (`Glass.regular`).
  regular,

  /// A more transparent glass, meant for media-rich content behind it
  /// (`Glass.clear`).
  clear,

  /// No glass at all (`Glass.identity`): the content renders as if the effect
  /// were absent, without changing the native view's structure — handy to
  /// toggle the effect off without rebuilding the view.
  identity,
}

/// A Liquid Glass layer drawn behind a CN widget via SwiftUI
/// `.glassEffect(_:in:)` (macOS 26+; ignored on earlier systems).
///
/// Unlike the glass *button styles* ([CNButtonStyle.glass]), which only apply
/// to buttons, the effect works on any SwiftUI-backed widget — pickers, menus,
/// labels, text, sliders… — and on [CNSearchField], through AppKit's
/// `NSGlassEffectView`.
///
/// The glass hugs the control. Two insets control the spacing around it:
/// - [padding] is applied *inside* the glass, between the content and the glass
///   edge;
/// - the widget's own `paddings` is applied *outside* the glass, and gives the
///   native view room to render the glass's outer edge without clipping it.
///
/// The glass replaces the control's own bezel: when the control's style is left
/// at its default, its opaque native chrome is dropped so it doesn't show
/// inside the glass — buttons and menu pickers render borderless, menus as
/// [CNMenuStyle.borderlessButton], text fields as [CNTextFieldStyle.plain],
/// search fields as [CNTextFieldBezelStyle.none], and a text editor hides its
/// text background. Set an explicit style (e.g. [CNButtonStyle.bordered],
/// [CNMenuStyle.borderedButton], [CNTextFieldStyle.roundedBorder]) to keep the
/// native bezel inside the glass.
///
/// Example — a glass capsule around a menu picker:
///
/// ```dart
/// CNPicker(
///   glassEffect: const CNGlassEffect(interactive: true),
///   paddings: const EdgeInsets.all(2),
///   selection: value,
///   children: const [...],
/// )
/// ```
class CNGlassEffect {
  /// Creates a glass effect.
  const CNGlassEffect({
    this.variant = CNGlassVariant.regular,
    this.tint,
    this.interactive = false,
    this.shape,
    this.padding,
  });

  /// Whether the glass reacts to pointer interaction (hover and press), like
  /// the glass button styles do (`Glass.interactive()`).
  ///
  /// Off by default: inside a Flutter platform view the interactive animation
  /// can look odd and stutter.
  final bool interactive;

  /// Inset between the widget's content and the glass edge.
  ///
  /// Applied natively inside the effect. Use the widget's `paddings` for space
  /// outside the glass instead.
  final EdgeInsetsGeometry? padding;

  /// The shape of the glass. Defaults to a capsule (SwiftUI
  /// `DefaultGlassEffectShape`) when null.
  final CNShape? shape;

  /// Optional color tinting the glass (`Glass.tint(_:)`).
  final Color? tint;

  /// The glass material.
  final CNGlassVariant variant;

  /// Serializes this effect to a payload map for the native side.
  Map<String, dynamic> toMap(BuildContext context) {
    final map = <String, dynamic>{
      'variant': variant.name,
      'interactive': interactive,
    };
    if (tint != null) {
      map['tint'] = resolveColorToArgb(tint, context);
    }
    if (shape != null) {
      map['shape'] = shape!.toMap();
    }
    if (padding != null) {
      final resolved = padding!.resolve(Directionality.of(context));
      map['padding'] = {
        'top': resolved.top,
        'leading': resolved.left,
        'bottom': resolved.bottom,
        'trailing': resolved.right,
      };
    }
    return map;
  }
}

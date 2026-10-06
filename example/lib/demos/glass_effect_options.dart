import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

/// Colorful backdrop that makes the glass visible (glass over a flat fill
/// looks like a faint shadow only).
const kGlassBackdropGradient = LinearGradient(
  colors: [CNColors.orange, CNColors.purple, CNColors.blue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Shapes offered for the glass in the demos.
enum GlassShapeKind { capsule, roundedRectangle, rectangle, circle }

/// Demo state of the glass effect options shown in the right-side panel.
///
/// Add one to a demo page state, list its controls with
/// [glassEffectOptionEntries], then pass [effect] / [paddings] to the widget
/// and wrap it in a [GlassBackdrop].
@immutable
class GlassEffectOptions {
  const GlassEffectOptions({
    this.enabled = false,
    this.variant = CNGlassVariant.regular,
    this.shape = GlassShapeKind.capsule,
    this.tint,
    this.interactive = false,
    this.cornerRadius = 8,
    this.padding = 4,
    this.outerPadding = 2,
    this.backdrop = true,
  });

  /// Whether a gradient is painted behind the widget (see [GlassBackdrop]).
  final bool backdrop;

  final double cornerRadius;
  final bool enabled;
  final bool interactive;
  /// Room left outside the glass so its outer edge is not clipped.
  final double outerPadding;

  /// Inset between the widget content and the glass edge.
  final double padding;

  final GlassShapeKind shape;
  final Color? tint;
  final CNGlassVariant variant;

  /// The effect to pass to the widget, or null when disabled.
  ///
  /// [minPadding] keeps content without a bezel of its own (text, sliders…)
  /// off the glass edge.
  CNGlassEffect? effect({double minPadding = 0}) {
    if (!enabled) return null;
    return CNGlassEffect(
      variant: variant,
      tint: tint,
      interactive: interactive,
      shape: switch (shape) {
        GlassShapeKind.capsule => null,
        GlassShapeKind.roundedRectangle => CNRoundedRectangle(
          cornerRadius: cornerRadius,
          style: CNRoundedCornerStyle.continuous,
        ),
        GlassShapeKind.rectangle => const CNRectangle(),
        GlassShapeKind.circle => const CNCircle(),
      },
      padding: EdgeInsets.all(padding < minPadding ? minPadding : padding),
    );
  }

  /// The widget's own [base] paddings, plus the glass [outerPadding] when the
  /// effect is enabled.
  EdgeInsetsGeometry? paddings([EdgeInsetsGeometry? base]) {
    if (!enabled || outerPadding == 0) return base;
    final outer = EdgeInsets.all(outerPadding);
    return base == null ? outer : base.add(outer);
  }

  GlassEffectOptions copyWith({
    bool? backdrop,
    double? cornerRadius,
    bool? enabled,
    bool? interactive,
    double? outerPadding,
    double? padding,
    GlassShapeKind? shape,
    Color? Function()? tint,
    CNGlassVariant? variant,
  }) {
    return GlassEffectOptions(
      backdrop: backdrop ?? this.backdrop,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      enabled: enabled ?? this.enabled,
      interactive: interactive ?? this.interactive,
      outerPadding: outerPadding ?? this.outerPadding,
      padding: padding ?? this.padding,
      shape: shape ?? this.shape,
      tint: tint != null ? tint() : this.tint,
      variant: variant ?? this.variant,
    );
  }
}

/// The right-side panel entries controlling [value]. The detail options only
/// show while the effect is enabled.
Map<String, Widget> glassEffectOptionEntries(
  GlassEffectOptions value,
  ValueChanged<GlassEffectOptions> onChanged,
) {
  return {
    'Glass Effect': CNToggle(
      isOn: value.enabled,
      onChanged: (v) => onChanged(value.copyWith(enabled: v)),
    ),
    if (value.enabled) ...{
      'Glass Variant': CNPicker(
        selection: value.variant.name,
        children: CNGlassVariant.values
            .map((v) => CNChildText(v.name, tag: v.name))
            .toList(),
        onChanged: (tag) => onChanged(
          value.copyWith(variant: CNGlassVariant.values.byName(tag)),
        ),
        pickerStyle: CNPickerStyle.menu,
      ),
      'Glass Shape': CNPicker(
        selection: value.shape.name,
        children: GlassShapeKind.values
            .map((s) => CNChildText(s.name, tag: s.name))
            .toList(),
        onChanged: (tag) =>
            onChanged(value.copyWith(shape: GlassShapeKind.values.byName(tag))),
        pickerStyle: CNPickerStyle.menu,
      ),
      if (value.shape == GlassShapeKind.roundedRectangle)
        'Glass Corner Radius': SizeSliderPicker(
          value: value.cornerRadius,
          min: 0,
          max: 20,
          onChanged: (v) => onChanged(value.copyWith(cornerRadius: v)),
        ),
      'Glass Tint': ColorPicker(
        colors: kSystemColors,
        value: value.tint,
        onChanged: (c) => onChanged(value.copyWith(tint: () => c)),
      ),
      'Glass Interactive': CNToggle(
        isOn: value.interactive,
        onChanged: (v) => onChanged(value.copyWith(interactive: v)),
      ),
      'Glass Padding': SizeSliderPicker(
        value: value.padding,
        min: 0,
        max: 16,
        onChanged: (v) => onChanged(value.copyWith(padding: v)),
      ),
      'Glass Outer Padding': SizeSliderPicker(
        value: value.outerPadding,
        min: 0,
        max: 8,
        onChanged: (v) => onChanged(value.copyWith(outerPadding: v)),
      ),
      'Glass Backdrop': CNToggle(
        isOn: value.backdrop,
        onChanged: (v) => onChanged(value.copyWith(backdrop: v)),
      ),
    },
  };
}

/// Paints [kGlassBackdropGradient] behind [child] while the glass effect and
/// its backdrop are enabled in [options]; otherwise returns [child] untouched.
class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.options, required this.child});

  final Widget child;
  final GlassEffectOptions options;

  @override
  Widget build(BuildContext context) {
    if (!options.enabled || !options.backdrop) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: kGlassBackdropGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

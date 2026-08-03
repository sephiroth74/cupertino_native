import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates the shared SwiftUI `.overlay(alignment:content:)` support:
/// a [CNShape] painted on top of any SwiftUI-backed CN widget (and any
/// `CNChild`), as a stroked border, an inset border, or a fill.
class OverlayDemoPage extends StatefulWidget {
  const OverlayDemoPage({super.key});

  @override
  State<OverlayDemoPage> createState() => _OverlayDemoPageState();
}

enum _ShapeKind { roundedRectangle, rectangle, capsule, circle, ellipse, uneven }

enum _PaintKind { stroke, strokeBorder, fill }

class _OverlayDemoPageState extends State<OverlayDemoPage> {
  double cornerRadius = 8;
  double inset = 0;
  double lineWidth = 2;
  double paddings = 0;
  _PaintKind paint = _PaintKind.strokeBorder;
  _ShapeKind shape = _ShapeKind.roundedRectangle;
  Color tint = CNColors.blue;
  bool useGradient = false;

  CNShape get _shape => switch (shape) {
    _ShapeKind.roundedRectangle => CNRoundedRectangle(
      cornerRadius: cornerRadius,
      style: CNRoundedCornerStyle.continuous,
      inset: inset,
    ),
    _ShapeKind.rectangle => CNRectangle(inset: inset),
    _ShapeKind.capsule => CNCapsule(inset: inset),
    _ShapeKind.circle => CNCircle(inset: inset),
    _ShapeKind.ellipse => CNEllipse(inset: inset),
    _ShapeKind.uneven => CNUnevenRoundedRectangle(
      topLeading: cornerRadius * 2,
      bottomTrailing: cornerRadius * 2,
      style: CNRoundedCornerStyle.continuous,
      inset: inset,
    ),
  };

  CNShapeStyle? get _gradient => useGradient
      ? CNShapeStyle.linearGradient(
          [CNGradientStop(CNColors.blue, 0), CNGradientStop(CNColors.purple, 1)],
          startPoint: CNUnitPoint.topLeading,
          endPoint: CNUnitPoint.bottomTrailing,
        )
      : null;

  CNOverlay get _overlay => switch (paint) {
    _PaintKind.stroke => CNOverlay.stroke(_shape, color: useGradient ? null : tint, shapeStyle: _gradient, lineWidth: lineWidth),
    _PaintKind.strokeBorder => CNOverlay.strokeBorder(
      _shape,
      color: useGradient ? null : tint,
      shapeStyle: _gradient,
      lineWidth: lineWidth,
    ),
    _PaintKind.fill => CNOverlay.fill(_shape, color: useGradient ? null : tint.withAlpha(60), shapeStyle: _gradient),
  };

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNContentArea(
      builder: (context, scrollController) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Text('Live preview', style: theme.typography.title2),
                  const SizedBox(height: 4),
                  Text(
                    'The same overlay is applied to a native button, text field and image. '
                    'It is drawn by SwiftUI on the native view — not by Flutter.',
                    style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: CNButton(
                      onPressed: () {},
                      buttonStyle: CNButtonStyle.automatic,
                      overlay: _overlay,
                      paddings: EdgeInsets.all(paddings),
                      children: const [CNChildText('Overlaid button')],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: 260,
                    child: CNTextField(placeholder: 'Overlaid text field', overlay: _overlay, paddings: EdgeInsets.all(paddings)),
                  ),
                  const SizedBox(height: 24),

                  CNImage(
                    constraints: const BoxConstraints(maxWidth: 64, maxHeight: 64),
                    systemSymbolName: 'photo',
                    foregroundColor: theme.accentColor,
                    overlay: _overlay,
                    paddings: EdgeInsets.all(paddings),
                  ),
                  const SizedBox(height: 32),

                  Text('On a CNChild (menu label)', style: theme.typography.title2),
                  const SizedBox(height: 12),
                  // The overlay also works on CNChild* content, here the label
                  // inside a native menu button.
                  CNMenu(
                    onItemPressed: (value) {
                      debugPrint('Menu item pressed: $value');
                    },
                    label: [
                      CNChildLabel(
                        'Menu with overlaid label',
                        systemImage: 'ellipsis.circle',
                        paddings: EdgeInsets.all(paddings),
                        overlay: CNOverlay.stroke(const CNCapsule(), color: tint, lineWidth: lineWidth),
                      ),
                    ],
                    items: const [
                      CNChildButton(tag: 'a', title: 'First'),
                      CNChildButton(tag: 'b', title: 'Second'),
                    ],
                  ),
                ],
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Shape': CNPicker(
                  selection: shape.name,
                  children: _ShapeKind.values.map((s) => CNChildText(s.name, tag: s.name)).toList(),
                  onChanged: (tag) => setState(() => shape = _ShapeKind.values.byName(tag)),
                  pickerStyle: CNPickerStyle.menu,
                ),
                'Paint': CNPicker(
                  selection: paint.name,
                  children: _PaintKind.values.map((p) => CNChildText(p.name, tag: p.name)).toList(),
                  onChanged: (tag) => setState(() => paint = _PaintKind.values.byName(tag)),
                  pickerStyle: CNPickerStyle.menu,
                ),
                'Gradient': CNToggle(isOn: useGradient, onChanged: (v) => setState(() => useGradient = v)),
                'Color': ColorPicker(
                  colors: kNonNullColors,
                  value: tint,
                  enabled: !useGradient,
                  onChanged: (c) => setState(() => tint = c ?? CNColors.blue),
                ),
                'Line width': SizeSliderPicker(
                  value: lineWidth,
                  min: 0.5,
                  max: 12,
                  onChanged: (v) => setState(() => lineWidth = v),
                ),
                'Corner radius': SizeSliderPicker(
                  value: cornerRadius,
                  min: 0,
                  max: 40,
                  onChanged: (v) => setState(() => cornerRadius = v),
                ),
                // Negative inset expands the shape outside the control's
                // bounds — e.g. a border drawn just outside a text field.
                'Inset': SizeSliderPicker(value: inset, min: -8, max: 8, onChanged: (v) => setState(() => inset = v)),
                'Paddings': SizeSliderPicker(value: paddings, min: 0, max: 10, onChanged: (v) => setState(() => paddings = v)),
              },
            ),
          ],
        );
      },
    );
  }
}

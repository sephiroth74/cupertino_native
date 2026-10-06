import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/glass_effect_options.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class LabelDemoPage extends StatefulWidget {
  const LabelDemoPage({super.key});

  @override
  State<LabelDemoPage> createState() => _LabelDemoPageState();
}

class _LabelDemoPageState extends State<LabelDemoPage> {
  CNFont? font;
  double fontSize = 20;
  Color? foregroundColor;
  GlassEffectOptions glass = const GlassEffectOptions();
  double labelIconToTitleSpacing = 0;
  Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 12),

                GlassBackdrop(
                  options: glass,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CNLabel.simple(
                        'Simple Label Only',
                        glassEffect: glass.effect(minPadding: 6),
                        paddings: glass.paddings(),
                        foregroundColor: foregroundColor,
                        tint: tintColor,
                        font: font,
                        labelIconToTitleSpacing: labelIconToTitleSpacing,
                      ),
                      const SizedBox(height: 12),

                      CNLabel.simple(
                        'Simple Label and Icon',
                        glassEffect: glass.effect(minPadding: 6),
                        paddings: glass.paddings(),
                        systemImage: 'microphone.fill',
                        foregroundColor: foregroundColor,
                        tint: tintColor,
                        font: font,
                      ),
                      const SizedBox(height: 12),

                      CNLabel(
                        debugLog: _kDebugLog,
                        glassEffect: glass.effect(minPadding: 6),
                        paddings: glass.paddings(),
                        title: CNChildText(
                          'Custom Label',
                          font: font,
                          foregroundColor: foregroundColor,
                        ),
                        image: CNChildImage(
                          'sparkle.text.clipboard.fill',
                          symbolRenderingMode: CNSymbolRenderingMode.palette,
                          foregroundStyleColors: [
                            CNColors.cyan,
                            foregroundColor ?? CNColors.black,
                          ],
                        ),
                        labelIconToTitleSpacing: labelIconToTitleSpacing,
                        labelStyle: CNLabelStyle.automatic,
                        font: font,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          RightSideOptionContainer(
            options: {
              'Font': FontPicker(
                fonts: kAvailableFonts,
                value: font,
                onChanged: (value) => setState(() {
                  font = value?.copyWith(size: CNFontSize.points(fontSize));
                }),
              ),
              'Text Color': ColorPicker(
                colors: kSystemColors,
                value: foregroundColor,
                onChanged: (color) => setState(() => foregroundColor = color),
              ),
              'Spacing': SizeSliderPicker(
                min: 0,
                max: 48,
                value: labelIconToTitleSpacing,
                onChanged: (value) =>
                    setState(() => labelIconToTitleSpacing = value),
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                onChanged: font != null
                    ? (value) => setState(() {
                        fontSize = value;
                        if (font != null) {
                          font = font!.copyWith(
                            size: CNFontSize.points(fontSize),
                          );
                        }
                      })
                    : null,
              ),
              ...glassEffectOptionEntries(
                glass,
                (v) => setState(() => glass = v),
              ),
            },
          ),
        ],
      ),
    );
  }
}

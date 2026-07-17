import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class LabelDemoPage extends StatefulWidget {
  const LabelDemoPage({super.key});

  @override
  State<LabelDemoPage> createState() => _LabelDemoPageState();
}

class _LabelDemoPageState extends State<LabelDemoPage> {
  CNFont? font;
  double fontSize = 20;
  Color? foregroundIconColor;
  Color? foregroundSecondaryTextColor;
  Color? foregroundTextColor;
  double labelIconToTitleSpacing = 0;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Label')),
      child: SafeArea(
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
                  PixelPerfectProbe(
                    adjustPosition: true,
                    child: CNLabel(
                      labelIconToTitleSpacing: labelIconToTitleSpacing,
                      CNText(
                        'Alessandro',
                        font: font ?? CNFont.system(CNFontSize.points(fontSize)),
                        modifiers: CNViewModifiers(foregroundColor: foregroundTextColor ?? CupertinoColors.label),
                      ),
                      secondaryText: CNText(
                        'Crugnola',
                        font: font ?? CNFont.system(CNFontSize.points(fontSize), weight: CNFontWeight.regular),
                        modifiers: CNViewModifiers(foregroundColor: foregroundSecondaryTextColor ?? CupertinoColors.secondaryLabel),
                      ),
                      icon: CNImage(
                        font: font ?? CNFont.system(CNFontSize.points(fontSize)),
                        systemSymbolName: 'microphone.fill',
                        modifiers: CNViewModifiers(foregroundColor: foregroundIconColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Font': CNPicker(
                  selectedIndex: kAvailableFonts.indexWhere((f) => f?.name == font?.name),
                  onValueChanged: (index) =>
                      setState(() => font = kAvailableFonts[index]?.copyWith(size: CNFontSize.points(fontSize))),
                  items: kAvailableFonts.map((font) => CNText(font != null ? (font.name ?? font.kind.name) : 'None')).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Primary Text Color': ColorPicker(
                  colors: kSystemColors,
                  value: foregroundTextColor,
                  onChanged: (color) => setState(() => foregroundTextColor = color),
                ),
                'Secondary Text Color': ColorPicker(
                  colors: kSystemColors,
                  value: foregroundSecondaryTextColor,
                  onChanged: (color) => setState(() => foregroundSecondaryTextColor = color),
                ),
                'Icon Foreground Color': ColorPicker(
                  colors: kSystemColors,
                  value: foregroundIconColor,
                  onChanged: (color) => setState(() => foregroundIconColor = color),
                ),
                'Icon to Title Spacing': CNSlider(
                  value: labelIconToTitleSpacing,
                  min: 0,
                  max: 32,
                  onChanged: (value) => setState(() => labelIconToTitleSpacing = value),
                ),
                'Font Size': CNSlider(
                  value: fontSize,
                  min: 8,
                  max: 48,
                  onChanged: (value) => setState(() {
                    fontSize = value;
                    if (font != null) {
                      font = font!.copyWith(size: CNFontSize.points(fontSize));
                    }
                  }),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class TextDemoPage extends StatefulWidget {
  const TextDemoPage({super.key});

  @override
  State<TextDemoPage> createState() => _TextDemoPageState();
}

class _TextDemoPageState extends State<TextDemoPage> {
  CNFont? font = CNFont.boldSystem(CNFontSize.points(32));
  Color? foregroundColor;
  double fontSize = 32;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('CNText')),
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
                  Text(
                    'CNText is the reusable SwiftUI text bridge used by future widgets.',
                    style: theme.typography.body.copyWith(color: theme.labelColor),
                  ),
                  const SizedBox(height: 24),
                  PixelPerfectProbe(
                    adjustPosition: true,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: CNText2(
                        'The quick brown fox jumps over the lazy dog.',
                        font: font,
                        foregroundColor: foregroundColor,
                        debugLog: true,
                        shrink: true,
                        paddings: EdgeInsets.symmetric(horizontal: 2, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Font': CNPicker(
                  selectedIndex: availableFonts.indexWhere((font) {
                    // first check if the font name matches, otherwise check if the font kind matches
                    if (font == null && this.font == null) return true;
                    if (font == null || this.font == null) return false;
                    return font.name == this.font!.name || font.kind == this.font!.kind;
                  }),
                  onValueChanged: (index) =>
                      setState(() => font = availableFonts[index]?.copyWith(size: CNFontSize.points(fontSize))),
                  items: availableFonts.map((font) => CNText(font != null ? (font.name ?? font.kind.name) : 'None')).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: foregroundColor,
                  onValueChanged: (index) => setState(() => foregroundColor = kSystemColors.values.elementAt(index)),
                ),
                'Font Size': CNSlider(
                  value: fontSize,
                  min: 8,
                  max: 64,
                  step: 1,
                  onChanged: (value) => setState(() {
                    fontSize = value;
                    font = font?.copyWith(size: CNFontSize.points(fontSize));
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

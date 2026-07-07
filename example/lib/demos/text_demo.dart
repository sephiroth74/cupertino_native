import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:flutter/cupertino.dart';

class TextDemoPage extends StatefulWidget {
  const TextDemoPage({super.key});

  @override
  State<TextDemoPage> createState() => _TextDemoPageState();
}

class _TextDemoPageState extends State<TextDemoPage> {
  CNFont? font;
  Color? foregroundColor;

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
                  const Text('Default rendering', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  PixelPerfectProbe(
                    adjustPosition: true,
                    onGeometryChanged: null,
                    child: CNText(
                      'The quick brown fox jumps over the lazy dog.',
                      font: font,
                      modifiers: CNViewModifiers(foregroundColor: foregroundColor),
                    ),
                  ),
                ],
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Font': CNPicker(
                  selectedIndex: availableFonts.indexOf(font ?? CNFont.system(defaultFontSize)),
                  onValueChanged: (index) => setState(() => font = availableFonts[index]),
                  items: availableFonts.map((font) => CNText(font.name ?? font.kind.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: foregroundColor,
                  onValueChanged: (index) => setState(() => foregroundColor = kSystemColors.values.elementAt(index)),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

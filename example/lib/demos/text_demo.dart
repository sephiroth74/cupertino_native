import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/pixel_perfect_probe.dart';
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
                    enforcePixelPerfectPosition: true,
                    onGeometryChanged: null,
                    child: CNText(
                      'The quick brown fox jumps over the lazy dog.',
                      font: font,
                      modifiers: CNViewModifiers(foregroundColor: foregroundColor),
                    ),
                  ),
                  // const SizedBox(height: 24),
                  // const Text('Custom font and color', style: TextStyle(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 12),
                  // const CNText(
                  //   'Monospaced title with a stronger accent color.',
                  //   font: CNFont.monospacedSystem(CNFontSize.points(20), weight: CNFontWeight.semibold),
                  //   modifiers: CNViewModifiers(foregroundColor: CupertinoColors.systemBlue),
                  // ),
                  // const SizedBox(height: 24),
                  // const Text('Line limit and truncation', style: TextStyle(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 12),
                  // const SizedBox(
                  //   width: 120,
                  //   child: CNText(
                  //     'This sentence is intentionally long so the demo can show how a line limit and truncation behave when the available width is constrained.',
                  //     lineLimit: 2,
                  //     truncationMode: CNTextTruncationMode.tail,
                  //     modifiers: CNViewModifiers(width: 120),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),
                  // const Text('Reserved space', style: TextStyle(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 12),
                  // const SizedBox(
                  //   width: 320,
                  //   child: CNText(
                  //     'The widget can reserve space for multiple lines even when the content is short.',
                  //     lineLimit: 2,
                  //     lineLimitReservesSpace: true,
                  //   ),
                  // ),
                  // const SizedBox(height: 24),
                  // const Text('Text scale variants', style: TextStyle(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 12),
                  // const CNText('Default scale', textScale: CNTextScale.defaultScale),
                  // const SizedBox(height: 8),
                  // const CNText('Secondary scale', textScale: CNTextScale.secondary),
                  // const SizedBox(height: 24),
                  // const Text('Reusable inside layout', style: TextStyle(fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 12),
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: theme.groupedBackgroundColor,
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(color: theme.separatorColor),
                  //   ),
                  //   child: const CNText(
                  //     'This same widget can be embedded in future controls without coupling the payload model to the view wrapper.',
                  //     modifiers: CNViewModifiers(width: 360),
                  //   ),
                  // ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 350,
                decoration: BoxDecoration(
                  color: CNTheme.of(context).fillPrimaryColor,
                  border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: const Text('Font')),
                        CNPicker(
                          selectedIndex: availableFonts.indexOf(font ?? CNFont.system(defaultFontSize)),
                          onValueChanged: (index) => setState(() => font = availableFonts[index]),
                          items: availableFonts.map((font) => CNText(font.name ?? font.kind.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            foregroundColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == foregroundColor).key,
                          ),
                          onValueChanged: (index) => setState(() => foregroundColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys
                              .map(
                                (colorName) => CNLabel(
                                  CNText(colorName),
                                  icon: CNImage(
                                    systemSymbolName: 'circle.fill',
                                    modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                                  ),
                                ),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

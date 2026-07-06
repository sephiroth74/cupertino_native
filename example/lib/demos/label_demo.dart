import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/pixel_perfect_probe.dart';
import 'package:flutter/cupertino.dart';

class LabelDemoPage extends StatefulWidget {
  const LabelDemoPage({super.key});

  @override
  State<LabelDemoPage> createState() => _LabelDemoPageState();
}

class _LabelDemoPageState extends State<LabelDemoPage> {
  CNFont? font;
  Color? foregroundIconColor;
  Color? foregroundSecondaryTextColor;
  Color? foregroundTextColor;

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
                  // const CNLabel(CNText('First'), icon: CNImage(systemSymbolName: 'bolt.fill')),
                  // const SizedBox(height: 12),
                  // const CNLabel(CNText('Second'), icon: CNImage(systemSymbolName: 'bolt.fill')),
                  // const SizedBox(height: 12),
                  // const Text('Two inner Text + optional Image'),
                  const SizedBox(height: 12),
                  PixelPerfectProbe(
                    enforcePixelPerfectPosition: true,
                    child: Container(
                      color: CupertinoColors.activeOrange.withAlpha(51),
                      child: CNLabel(
                        CNText(
                          'Alessandro',
                          font: font ?? CNFont.system(defaultFontSize),
                          modifiers: CNViewModifiers(foregroundColor: foregroundTextColor ?? CupertinoColors.label),
                        ),
                        secondaryText: CNText(
                          'Crugnola',
                          font: font ?? CNFont.system(CNFontSize.preset(CNFontSizePreset.smallSystem), weight: CNFontWeight.regular),
                          modifiers: CNViewModifiers(foregroundColor: foregroundSecondaryTextColor ?? CupertinoColors.secondaryLabel),
                        ),
                        icon: CNImage(
                          systemSymbolName: 'microphone.fill',
                          modifiers: CNViewModifiers(foregroundColor: foregroundIconColor),
                        ),
                      ),
                    ),
                  ),
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
                        Expanded(child: const Text('Primary Text Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            foregroundTextColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == foregroundTextColor).key,
                          ),
                          onValueChanged: (index) => setState(() => foregroundTextColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys.map((colorName) {
                            // return CNLabel(
                            //   CNText(colorName),
                            //   icon: CNImage(
                            //     systemSymbolName: 'circle.fill',
                            //     modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                            //   ),
                            // );
                            return CNText(colorName);
                          }).toList(),
                          pickerStyle: CNPickerStyle.menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const Text('Secondary Text Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            foregroundSecondaryTextColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == foregroundSecondaryTextColor).key,
                          ),
                          onValueChanged: (index) => setState(() => foregroundSecondaryTextColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys.map((colorName) {
                            // return CNLabel(
                            //   CNText(colorName),
                            //   icon: CNImage(
                            //     systemSymbolName: 'circle.fill',
                            //     modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                            //   ),
                            // );
                            return CNText(colorName);
                          }).toList(),
                          pickerStyle: CNPickerStyle.menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Icon Foreground Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            foregroundIconColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == foregroundIconColor).key,
                          ),
                          onValueChanged: (index) => setState(() => foregroundIconColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys.map((colorName) {
                            // return CNLabel(
                            //   CNText(colorName),
                            //   icon: CNImage(
                            //     systemSymbolName: 'circle.fill',
                            //     modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                            //   ),
                            // );
                            return CNText(colorName);
                          }).toList(),
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

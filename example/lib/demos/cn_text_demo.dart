import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kShrink = true;
const _kDebugLog = false;
const _kFontSize = 32.0;

const _kTextScales = {'default': CNTextScale.defaultScale, 'secondary': CNTextScale.secondary};

class TextDemoPage extends StatefulWidget {
  const TextDemoPage({super.key});

  @override
  State<TextDemoPage> createState() => _TextDemoPageState();
}

class _TextDemoPageState extends State<TextDemoPage> {
  CNFont? font = CNFont.boldSystem(CNFontSize.points(_kFontSize));
  double fontSize = _kFontSize;
  Color? foregroundColor;
  int lineLimit = 1;
  CNTextScale textScale = CNTextScale.defaultScale;
  CNTextTruncationMode truncationMode = CNTextTruncationMode.tail;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('CNText')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: CNText2(
                          'Hello World.',
                          lineLimit: lineLimit,
                          lineLimitReservesSpace: true,
                          textScale: textScale,
                          truncationMode: truncationMode,
                          font: font,
                          foregroundColor: foregroundColor,
                          debugLog: _kDebugLog,
                          shrink: _kShrink,
                        ),
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
                'Font Size': Row(
                  children: [
                    SizedBox(width: 50, child: Text('$fontSize')),
                    Expanded(
                      child: CNStepper(
                        value: fontSize,
                        min: 8.0,
                        max: 64.0,
                        onChanged: (value) {
                          setState(() {
                            fontSize = value;
                            font = font?.copyWith(size: CNFontSize.points(fontSize));
                          });
                        },
                      ),
                    ),
                  ],
                ),
                'Line Limit': Row(
                  children: [
                    SizedBox(width: 50, child: Text(lineLimit.toString())),
                    Expanded(
                      child: CNStepper(
                        value: lineLimit.toDouble(),
                        min: 1,
                        max: 10,
                        onChanged: (value) {
                          setState(() {
                            lineLimit = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                'Text Scale': CNPicker(
                  selectedIndex: _kTextScales.values.toList().indexOf(textScale),
                  onValueChanged: (index) => setState(() => textScale = _kTextScales.values.elementAt(index)),
                  items: _kTextScales.keys.map((key) => CNText(key)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Truncation Mode': CNPicker(
                  selectedIndex: CNTextTruncationMode.values.indexOf(truncationMode),
                  onValueChanged: (index) => setState(() => truncationMode = CNTextTruncationMode.values[index]),
                  items: CNTextTruncationMode.values.map((mode) => CNText(mode.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

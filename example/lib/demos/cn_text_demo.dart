import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;
const _kFontSize = 32.0;
const _kShrink = true;

const _kTextScales = {
  'default': CNTextScale.defaultScale,
  'secondary': CNTextScale.secondary,
};

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
    return SafeArea(
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: CNText(
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
                ),
              ],
            ),
          ),

          RightSideOptionContainer(
            options: {
              'Font': FontPicker(
                value: font,
                fonts: kAvailableFonts,
                onChanged: (newFont) => setState(() {
                  debugPrint(
                    'Font changed: ${newFont?.name ?? newFont?.kind.name}',
                  );
                  font = newFont?.copyWith(size: CNFontSize.points(fontSize));
                }),
              ),
              'Color': ColorPicker(
                colors: kSystemColors,
                value: foregroundColor,
                onChanged: (color) => setState(() => foregroundColor = color),
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                onChanged: font != null
                    ? (newSize) => setState(() {
                        fontSize = newSize;
                        font = font?.copyWith(
                          size: CNFontSize.points(fontSize),
                        );
                      })
                    : null,
              ),
              'Line Limit': SizeSliderPicker(
                value: lineLimit.toDouble(),
                min: 1,
                max: 10,
                onChanged: (newValue) =>
                    setState(() => lineLimit = newValue.toInt()),
              ),
              'Text Scale': CNPicker(
                selection: textScale.name,
                children: _kTextScales.entries
                    .map(
                      (entry) => CNChildLabel(entry.key, tag: entry.value.name),
                    )
                    .toList(),
                onChanged: (tag) => setState(
                  () => textScale = _kTextScales.entries
                      .firstWhere((entry) => entry.value.name == tag)
                      .value,
                ),
              ),
              'Truncation Mode': CNPicker(
                selection: truncationMode.name,
                children: CNTextTruncationMode.values
                    .map((mode) => CNChildLabel(mode.name, tag: mode.name))
                    .toList(),
                onChanged: (tag) => setState(
                  () => truncationMode = CNTextTruncationMode.values.firstWhere(
                    (mode) => mode.name == tag,
                  ),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}

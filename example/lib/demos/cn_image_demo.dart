import 'dart:math';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/icon_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const _kBackgroundColors = {
  'Default': null,
  'Light': CNColors.white,
  'Dark': CNColors.black,
};

const _kDebugLog = false;
final _kMaxImages = kSFSymbolNames.length;
const _kShrink = true;

class CNImage2DemoPage extends StatefulWidget {
  const CNImage2DemoPage({super.key});

  @override
  State<CNImage2DemoPage> createState() => _CNImage2DemoPageState();
}

class _CNImage2DemoPageState extends State<CNImage2DemoPage> {
  Color? backgroundColor;
  CupertinoDynamicColor? color1;
  CupertinoDynamicColor? color2;
  CupertinoDynamicColor? color3;
  CNSymbolColorRenderingMode colorMode = CNSymbolColorRenderingMode.flat;
  List<Color> colors = [];
  CNFont font = CNFont.system(
    CNFontSize.points(32),
    weight: CNFontWeight.regular,
  );
  double fontSize = 32;
  Color? foregroundColor;
  bool isDark = false;
  CNSymbolRenderingMode renderingMode = CNSymbolRenderingMode.monochrome;
  Color? selectedBackgroundColor;

  @override
  initState() {
    super.initState();
  }

  Widget _symbolRow({
    required String systemSymbolName,
    required bool shrink,
    required CNFont font,
    required CNSymbolRenderingMode symbolRenderingMode,
    required CNSymbolColorRenderingMode symbolColorRenderingMode,
    required List<Color> foregroundStyleColors,
    required Color? foregroundColor,
    required Color? backgroundColor,
    required bool isDark,
  }) {
    final theme = CNTheme.of(context);
    final labelStyle = theme.typography.caption1;
    final containerSize = (font.size.points ?? 24) * 4;
    final imageSize = (font.size.points ?? 24) * 3;

    final realForegroundColor =
        isDark && foregroundColor is CupertinoDynamicColor
        ? foregroundColor.darkColor
        : foregroundColor;
    final realForegroundStyleColors = foregroundStyleColors.map((color) {
      if (isDark && color is CupertinoDynamicColor) {
        return color.darkColor;
      }
      return color;
    }).toList();

    final widget = GestureDetector(
      onTap: () {
        // copy the symbol name to the clipboard
        Clipboard.setData(ClipboardData(text: systemSymbolName));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: foregroundColor ?? theme.separatorColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              color: backgroundColor,
            ),
            padding: shrink
                ? const EdgeInsets.all(16)
                : const EdgeInsets.all(0),
            child: CNImage(
              debugLog: _kDebugLog,
              systemSymbolName: systemSymbolName,
              shrink: shrink,
              font: font,
              symbolRenderingMode: symbolRenderingMode,
              symbolColorRenderingMode: symbolColorRenderingMode,
              foregroundStyleColors: realForegroundStyleColors,
              foregroundColor: realForegroundColor,
              constraints: shrink
                  ? null
                  : BoxConstraints.tightFor(
                      width: imageSize,
                      height: imageSize,
                    ),
              paddings: EdgeInsets.all(8.0),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: containerSize,
            child: Text(
              systemSymbolName,
              style: labelStyle,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (!shrink) {
      return SizedBox(width: containerSize, child: widget);
    } else {
      return widget;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paletteColors = renderingMode == CNSymbolRenderingMode.palette;
    final theme = CNTheme.of(context);

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                clipBehavior: Clip.hardEdge,
                alignment: WrapAlignment.start,
                spacing: 16.0,
                runSpacing: 16.0,
                children: kSFSymbolNames
                    .getRange(0, min(_kMaxImages, kSFSymbolNames.length))
                    .map((name) {
                      return _symbolRow(
                        systemSymbolName: name,
                        shrink: _kShrink,
                        font: font,
                        symbolRenderingMode: renderingMode,
                        symbolColorRenderingMode: colorMode,
                        foregroundStyleColors: colors,
                        foregroundColor: foregroundColor,
                        backgroundColor: backgroundColor,
                        isDark: isDark,
                      );
                    })
                    .toList(),
              ),
            ),
          ),
          RightSideOptionContainer(
            title: 'Options',
            options: {
              'Rendering Mode': CNPicker(
                selection: renderingMode.name,
                onChanged: (value) {
                  setState(() {
                    renderingMode = CNSymbolRenderingMode.values.firstWhere(
                      (e) => e.name == value,
                    );
                    if (renderingMode == CNSymbolRenderingMode.palette) {
                      color1 = color1 ?? kNonNullColors.values.elementAt(0);
                      color2 = color2 ?? kNonNullColors.values.elementAt(1);
                      color3 = color3 ?? kNonNullColors.values.elementAt(2);
                      colors = [color1!, color2!, color3!];
                    } else {
                      color2 = null;
                      color3 = null;
                      colors = color1 != null ? [color1!] : [];
                    }
                  });
                },
                children: CNSymbolRenderingMode.values
                    .map((mode) => CNChildText(mode.name, tag: mode.name))
                    .toList(),
                pickerStyle: CNPickerStyle.automatic,
              ),
              'Gradient': CNToggle(
                toggleStyle: CNToggleStyle.switchStyle,
                isOn: colorMode == CNSymbolColorRenderingMode.gradient,
                onChanged: (value) {
                  setState(() {
                    colorMode = value
                        ? CNSymbolColorRenderingMode.gradient
                        : CNSymbolColorRenderingMode.flat;
                  });
                },
              ),
              'Colors': Column(
                children: [
                  ColorPicker(
                    colors: kSystemColors,
                    value: color1,
                    onChanged: (color) => setState(() {
                      color1 = color;
                      colors = [?color1, ?color2, ?color3];
                    }),
                  ),
                  const SizedBox(height: 8),
                  ColorPicker(
                    colors: kSystemColors,
                    value: color2,
                    enabled: paletteColors,
                    onChanged: (color) => setState(() {
                      if (paletteColors) {
                        color2 = color;
                        colors = [?color1, ?color2, ?color3];
                      }
                    }),
                  ),
                  const SizedBox(height: 8),
                  ColorPicker(
                    colors: kSystemColors,
                    value: color3,
                    enabled: paletteColors,
                    onChanged: (color) => setState(() {
                      if (paletteColors) {
                        color3 = color;
                        colors = [?color1, ?color2, ?color3];
                      }
                    }),
                  ),
                ],
              ),
              'Foreground': ColorPicker(
                colors: kSystemColors,
                value: foregroundColor,
                onChanged: (color) => setState(() {
                  foregroundColor = color;
                }),
              ),
              'Background': ColorPicker(
                colors: _kBackgroundColors,
                value: selectedBackgroundColor,
                onChanged: (c) => setState(() {
                  selectedBackgroundColor = c;
                  final key = _kBackgroundColors.entries
                      .firstWhere((entry) => entry.value == c)
                      .key;

                  switch (key) {
                    case 'Default':
                      backgroundColor = theme.canvasColor;
                      isDark = theme.brightness == Brightness.dark;
                      break;
                    case 'Light':
                      backgroundColor = CupertinoColors.systemBackground.color;
                      isDark = false;
                      break;
                    case 'Dark':
                      backgroundColor =
                          CupertinoColors.systemBackground.darkColor;
                      isDark = true;
                      break;
                    default:
                      backgroundColor = null;
                  }
                }),
              ),
              'Font Weight': CNPicker(
                selection: font.weight?.name ?? CNFontWeight.regular.name,
                onChanged: (value) {
                  setState(() {
                    font = font.copyWith(
                      weight: CNFontWeight.values.firstWhere(
                        (e) => e.name == value,
                      ),
                      size: CNFontSize.points(fontSize),
                    );
                  });
                },
                children: CNFontWeight.values
                    .map((weight) => CNChildText(weight.name, tag: weight.name))
                    .toList(),
                pickerStyle: CNPickerStyle.automatic,
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                onChanged: (value) => setState(() {
                  fontSize = value;
                  font = font.copyWith(size: CNFontSize.points(fontSize));
                }),
              ),
            },
          ),
        ],
      ),
    );
  }
}

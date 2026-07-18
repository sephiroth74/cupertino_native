import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

enum ButtonType { titleOnly, titleAndIcon, titleAndProgressCircle, titleAndProgressLinear }

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  CNButtonStyle buttonStyle = CNButtonStyle.automatic;
  CNControlSize controlSize = CNControlSize.large;
  CNFont? font;
  double fontSize = kFontSizeDefault;
  bool isEnabled = true;
  double labelIconToTitleSpacing = 8;
  double labelReservedIconWidth = 0;
  CNProgressViewStyle progressViewStyle = CNProgressViewStyle.linear;
  Color? tintColor;
  bool withIcon = false;
  bool withProgress = true;

  // ignore: unused_field
  String _last = 'None';

  void _set(String what) {
    setState(() {
      debugPrint('Button pressed: $what');
      _last = what;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      PixelPerfectProbe(
                        adjustPosition: true,
                        child: CNButton2(
                          onPressed: isEnabled ? () => _set('Default') : null,
                          buttonStyle: buttonStyle,
                          controlSize: controlSize,
                          tint: tintColor,
                          debugLog: _kDebugLog,
                          font: font,
                          children: [CNChildText('Text Only', font: font)],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PixelPerfectProbe(
                        adjustPosition: true,
                        child: CNButton2(
                          onPressed: isEnabled ? () => _set('Default.2') : null,
                          buttonStyle: buttonStyle,
                          controlSize: controlSize,
                          tint: tintColor,
                          debugLog: false,
                          children: [
                            CNChildImage(
                              'square.and.arrow.up',
                              font: font,
                              symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
                              paddings: EdgeInsets.symmetric(horizontal: labelReservedIconWidth),
                            ),
                            CNChildText(
                              'Icon and Text',
                              paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                              font: font,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PixelPerfectProbe(
                        adjustPosition: true,
                        child: CNButton2(
                          onPressed: isEnabled ? () => _set('Default.3') : null,
                          buttonStyle: buttonStyle,
                          controlSize: controlSize,
                          tint: tintColor,
                          debugLog: false,
                          children: [
                            const CNChildProgressView(style: CNProgressViewStyle.circular, controlSize: CNControlSize.small),
                            CNChildImage(
                              'square.and.arrow.down.badge.checkmark.fill',
                              font: font,
                              symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
                              paddings: EdgeInsets.symmetric(horizontal: labelReservedIconWidth),
                            ),
                            CNChildText(
                              'Icon and Text',
                              paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                              font: font,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PixelPerfectProbe(
                        adjustPosition: true,
                        child: CNButton2(
                          onPressed: isEnabled ? () => _set('Default.4') : null,
                          buttonStyle: buttonStyle,
                          controlSize: controlSize,
                          tint: tintColor,
                          debugLog: false,
                          children: [
                            const CNChildProgressView(
                              style: CNProgressViewStyle.linear,
                              controlSize: CNControlSize.small,
                              constraints: BoxConstraints.tightFor(width: 100),
                            ),
                            CNChildImage(
                              'square.and.arrow.down.badge.checkmark.fill',
                              font: font,
                              symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
                              paddings: EdgeInsets.symmetric(horizontal: labelReservedIconWidth),
                            ),
                            CNChildText(
                              'Icon and Text',
                              font: font,
                              paddings: EdgeInsets.only(left: labelIconToTitleSpacing),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
                'Button Style': CNPicker(
                  selectedIndex: CNButtonStyle.values.indexOf(buttonStyle),
                  onValueChanged: (index) => setState(() => buttonStyle = CNButtonStyle.values[index]),
                  items: CNButtonStyle.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  value: tintColor,
                  onChanged: (color) => setState(() => tintColor = color),
                ),
                'Enabled': CNToggle2(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value)),
                'Font': FontPicker(
                  fonts: kAvailableFonts,
                  value: font,
                  onChanged: (font) => setState(() => this.font = font?.copyWith(size: CNFontSize.points(fontSize))),
                ),
                'Font Size': SizeSliderPicker(
                  min: kFontSizeMin,
                  max: kFontSizeMax,
                  value: fontSize,
                  onChanged: font != null
                      ? (value) => setState(() {
                          fontSize = value;
                          font = font?.copyWith(size: CNFontSize.points(fontSize));
                        })
                      : null,
                ),
                'Icon Width': SizeSliderPicker(
                  min: 0,
                  max: 64,
                  value: labelReservedIconWidth,
                  onChanged: (value) => setState(() => labelReservedIconWidth = value),
                ),
                'Icon Spacing': SizeSliderPicker(
                  min: 0,
                  max: 8,
                  value: labelIconToTitleSpacing,
                  onChanged: (value) => setState(() => labelIconToTitleSpacing = value),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;
const _kFontSize = 24.0;

class TextFieldDemoPage extends StatefulWidget {
  const TextFieldDemoPage({super.key});

  @override
  State<TextFieldDemoPage> createState() => _TextFieldDemoPageState();
}

class _TextFieldDemoPageState extends State<TextFieldDemoPage> {
  Color? borderColor;
  double? borderWidth;
  CNControlSize controlSize = CNControlSize.regular;
  final TextEditingController controller = TextEditingController(text: '');
  CNFont? font = CNFont.system(CNFontSize.points(_kFontSize));
  double fontSize = _kFontSize;
  Color? foregroundColor;
  String selectionInfo = '';
  CNTextFieldStyle textFieldStyle = CNTextFieldStyle.automatic;
  Color? tintColor;

  @override
  void dispose() {
    controller.removeListener(_updateSelectionInfo);
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_updateSelectionInfo);
    _updateSelectionInfo();
  }

  void _updateSelectionInfo() {
    final selection = controller.selection;
    debugPrint(
      'Selection changed: valid: ${selection.isValid}, start: ${selection.start}, end: ${selection.end}, text: ${controller.text}',
    );
    if (selection.isValid && mounted) {
      setState(() {
        selectionInfo =
            'Selection: [${selection.baseOffset}, ${selection.extentOffset}]\nText: "${controller.text.substring(selection.start, selection.end)}"';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Text Field')),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CNTextField2(
                      paddings: EdgeInsets.all(1.0),
                      controlSize: controlSize,
                      debugLog: _kDebugLog,
                      textFieldStyle: textFieldStyle,
                      controller: controller,
                      borderColor: borderColor,
                      borderWidth: borderWidth,
                      foregroundColor: foregroundColor,
                      font: font,
                      tint: tintColor,
                      placeholder: 'Enter something...',
                      onChanged: (value) {
                        debugPrint('onChanged: $value');
                      },
                      onSubmitted: (value) {
                        debugPrint('onSubmitted: $value');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(selectionInfo),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            RightSideOptionContainer(
              title: 'Options',
              options: {
                'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
                'Style': CNPicker(
                  selectedIndex: CNTextFieldStyle.values.indexOf(textFieldStyle),
                  onValueChanged: (index) => setState(() => textFieldStyle = CNTextFieldStyle.values[index]),
                  items: CNTextFieldStyle.values.map((style) => CNText(style.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Font': FontPicker(value: font, fonts: availableFonts, onChanged: (newFont) => setState(() => font = newFont)),
                'Font Size': Row(
                  children: [
                    Expanded(child: Text(fontSize.toStringAsFixed(1))),
                    CNStepper2(
                      value: fontSize,
                      min: 8,
                      max: 72,
                      onChanged: (value) => setState(() {
                        fontSize = value;
                        font = font?.copyWith(size: CNFontSize.points(value));
                      }),
                    ),
                  ],
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: tintColor,
                  onValueChanged: (index) => setState(() => tintColor = kSystemColors.values.elementAt(index)),
                ),
                'Foreground Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: foregroundColor,
                  onValueChanged: (index) => setState(() => foregroundColor = kSystemColors.values.elementAt(index)),
                ),
                'Border Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: borderColor,
                  onValueChanged: (index) => setState(() => borderColor = kSystemColors.values.elementAt(index)),
                ),
                'Border Width': Row(
                  children: [
                    Expanded(child: Text(borderWidth?.toStringAsFixed(1) ?? '0')),
                    CNStepper2(
                      value: borderWidth ?? 0,
                      min: 0,
                      max: 10,
                      onChanged: borderColor != null ? (value) => setState(() => borderWidth = value) : null,
                    ),
                  ],
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

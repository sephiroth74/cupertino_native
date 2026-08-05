import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;
const _kFontSize = 12.0;

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
  bool enabled = true;
  CNFont? font;
  double fontSize = _kFontSize;
  Color? foregroundColor;
  bool limitLength = false;
  bool selectable = true;
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
    return SafeArea(
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
                  child: CNTextField(
                    autofocus: true,
                    paddings: EdgeInsets.all(borderWidth ?? 0),
                    controlSize: controlSize,
                    debugLog: _kDebugLog,
                    textFieldStyle: textFieldStyle,
                    controller: controller,
                    enabled: enabled,
                    selectable: selectable,
                    maxLength: limitLength ? 10 : null,
                    overlay: borderWidth != null && borderColor != null
                        ? CNOverlay.stroke(
                            CNRoundedRectangle(cornerRadius: 8.0),
                            color: borderColor,
                            lineWidth: borderWidth!,
                          )
                        : null,
                    foregroundColor: foregroundColor,
                    font: font,
                    tint: tintColor,
                    placeholder: 'Enter something...',
                    onFocusChange: (value) {
                      debugPrint('onFocusChange: $value');
                    },
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
            options: {
              'Enabled': CNToggle(
                isOn: enabled,
                onChanged: (value) => setState(() => enabled = value),
              ),
              'Selectable (read-only)': CNToggle(
                isOn: selectable,
                onChanged: enabled
                    ? null
                    : (value) => setState(() => selectable = value),
              ),
              'Max 10 chars': CNToggle(
                isOn: limitLength,
                onChanged: (value) => setState(() => limitLength = value),
              ),
              'Control Size': ControlSizePicker(
                value: controlSize,
                onChanged: (size) => setState(() => controlSize = size),
              ),
              'Style': CNPicker(
                selection: textFieldStyle.name,
                onChanged: (value) => setState(
                  () => textFieldStyle = CNTextFieldStyle.values.firstWhere(
                    (style) => style.name == value,
                  ),
                ),
                children: CNTextFieldStyle.values
                    .map((style) => CNChildText(style.name, tag: style.name))
                    .toList(),
              ),
              'Font': FontPicker(
                value: font,
                fonts: kAvailableFonts,
                onChanged: (newFont) => setState(() => font = newFont),
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                onChanged: (newSize) => setState(() => fontSize = newSize),
              ),
              'Tint Color': ColorPicker(
                colors: kSystemColors,
                value: tintColor,
                onChanged: (color) => setState(() => tintColor = color),
              ),
              'Foreground Color': ColorPicker(
                colors: kSystemColors,
                value: foregroundColor,
                onChanged: (color) => setState(() => foregroundColor = color),
              ),
              'Border Color': ColorPicker(
                colors: kSystemColors,
                value: borderColor,
                onChanged: (color) => setState(() => borderColor = color),
              ),
              'Border Width': SizeSliderPicker(
                value: borderWidth ?? 0,
                min: 0.0,
                max: 10.0,
                onChanged: borderColor != null
                    ? (newWidth) => setState(() => borderWidth = newWidth)
                    : null,
              ),
            },
          ),
        ],
      ),
    );
  }
}

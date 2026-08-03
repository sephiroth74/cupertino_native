import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const _kDebugLog = false;
const _kFontSize = 16.0;

class TextEditorDemoPage extends StatefulWidget {
  const TextEditorDemoPage({super.key});

  @override
  State<TextEditorDemoPage> createState() => _TextEditorDemoPageState();
}

class _TextEditorDemoPageState extends State<TextEditorDemoPage> {
  Color? borderColor;
  double? borderWidth;
  final TextEditingController controller = TextEditingController(
    text: 'The quick brown fox jumps over the lazy dog.\n\nType here…',
  );

  bool editable = true;
  CNFont? font = CNFont.system(CNFontSize.points(_kFontSize));
  double fontSize = _kFontSize;
  Color? foregroundColor;
  bool limitLength = false;
  bool lowercaseOnly = false;
  String selectionInfo = '';
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
    if (selection.isValid && mounted) {
      setState(() {
        selectionInfo = 'Selection: [${selection.baseOffset}, ${selection.extentOffset}]\nLength: ${controller.text.length}';
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CNTextEditor(
                      autofocus: true,
                      debugLog: _kDebugLog,
                      controller: controller,
                      editable: editable,
                      maxLength: limitLength ? 20 : null,
                      inputFormatters: lowercaseOnly
                          ? [
                              TextInputFormatter.withFunction(
                                (oldValue, newValue) => newValue.copyWith(text: newValue.text.toLowerCase()),
                              ),
                            ]
                          : null,
                      borderColor: borderColor,
                      borderWidth: borderWidth,
                      foregroundColor: foregroundColor,
                      font: font,
                      tint: tintColor,
                      onChanged: (value) {
                        debugPrint('onChanged (len=${value.length})');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(selectionInfo),
                ],
              ),
            ),
          ),
          RightSideOptionContainer(
            title: 'Options',
            options: {
              'Editable': CNToggle(isOn: editable, onChanged: (value) => setState(() => editable = value)),
              'Max 20 chars': CNToggle(isOn: limitLength, onChanged: (value) => setState(() => limitLength = value)),
              'Lowercase only': CNToggle(isOn: lowercaseOnly, onChanged: (value) => setState(() => lowercaseOnly = value)),
              'Font': FontPicker(
                value: font,
                fonts: kAvailableFonts,
                onChanged: (newFont) => setState(() {
                  font = newFont?.copyWith(size: CNFontSize.points(fontSize));
                }),
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                onChanged: (newSize) => setState(() {
                  fontSize = newSize;
                  font = CNFont.system(CNFontSize.points(fontSize));
                }),
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
                onChanged: borderColor != null ? (newWidth) => setState(() => borderWidth = newWidth) : null,
              ),
            },
          ),
        ],
      ),
    );
  }
}

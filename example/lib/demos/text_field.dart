import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeMode;

class TextFieldDemoPage extends StatefulWidget {
  const TextFieldDemoPage({super.key});

  @override
  State<TextFieldDemoPage> createState() => _TextFieldDemoPageState();
}

class _TextFieldDemoPageState extends State<TextFieldDemoPage> {
  final TextEditingController _controller = TextEditingController(text: '');
  String _selectionInfo = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateSelectionInfo);
    _updateSelectionInfo();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSelectionInfo);
    _controller.dispose();
    super.dispose();
  }

  void _updateSelectionInfo() {
    final selection = _controller.selection;
    if (selection.isValid && mounted) {
      setState(() {
        _selectionInfo =
            'Selection: [${selection.baseOffset}, ${selection.extentOffset}]';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Text Field')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Default Text Field',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CNTextField(
                controller: _controller,
                placeholder: 'Enter something...',
                placeholderColor: CupertinoColors.systemGrey,
                bezelStyle: CNTextFieldBezelStyle.round,
                width: 320,
                onChanged: (value) {
                  // The controller receives the change automatically
                },
              ),
            ),
            const SizedBox(height: 12),
            Text('Current value: ${_controller.text}'),
            Text(_selectionInfo),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Set Text',
                  onPressed: () {
                    _controller.text = 'Flutter says hi!';
                  },
                ),
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Clear Text',
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Styled Text Field',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CNTextField(
              controller: TextEditingController(text: 'Styled field'),
              backgroundColor: CupertinoColors.systemYellow.withOpacity(0.3),
              font: const CNFont.system(
                CNFontSize.points(16),
                weight: CNFontWeight.bold,
              ),
              width: 320,
              bezelStyle: CNTextFieldBezelStyle.round,
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            CNTextField(
              controller: TextEditingController(text: ''),
              placeholder: 'Styled placeholder...',
              placeholderColor: CupertinoColors.systemRed.withOpacity(0.8),
              placeholderFont: const CNFont.monospacedSystem(
                CNFontSize.points(16),
                weight: CNFontWeight.bold,
              ),
              backgroundColor: CupertinoColors.systemFill,
              width: 320,
              bezelStyle: CNTextFieldBezelStyle.round,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

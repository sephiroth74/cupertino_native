import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeMode;

class TextFieldDemoPage extends StatefulWidget {
  const TextFieldDemoPage({super.key});

  @override
  State<TextFieldDemoPage> createState() => _TextFieldDemoPageState();
}

class _TextFieldDemoPageState extends State<TextFieldDemoPage> {
  final TextEditingController _controller = TextEditingController(
    text: 'Initial text',
  );
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
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text('Set Text'),
                  onPressed: () {
                    _controller.text = 'Flutter says hi!';
                  },
                ),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text('Clear Text'),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: const Text('Select All'),
                  onPressed: () {
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
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
          ],
        ),
      ),
    );
  }
}

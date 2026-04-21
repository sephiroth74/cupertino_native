import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class TextViewDemoPage extends StatefulWidget {
  const TextViewDemoPage({super.key});

  @override
  State<TextViewDemoPage> createState() => _TextViewDemoPageState();
}

class _TextViewDemoPageState extends State<TextViewDemoPage> {
  final TextEditingController _controller = TextEditingController(
    text: 'Line 1\nLine 2\nLine 3',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Text View')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'CNTextView (multiline)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CNTextView(
              controller: _controller,
              placeholder: 'Write notes here...',
              width: 420,
              height: 150,
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            Text('Characters: ${_controller.text.length}'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Set Sample',
                  onPressed: () {
                    _controller.text =
                        'Project Notes\n- Finish Text View API\n- Add tests\n- Update docs';
                    setState(() {});
                  },
                ),
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Clear',
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'CNTextArea alias',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CNTextArea(
              placeholder: 'Text Area alias works exactly like CNTextView.',
              width: 420,
              height: 120,
              backgroundColor: CupertinoColors.systemGrey6,
              font: const CNFont.monospacedSystem(CNFontSize.points(13)),
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

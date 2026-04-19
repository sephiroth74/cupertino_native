import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class SecureTextFieldDemoPage extends StatefulWidget {
  const SecureTextFieldDemoPage({super.key});

  @override
  State<SecureTextFieldDemoPage> createState() =>
      _SecureTextFieldDemoPageState();
}

class _SecureTextFieldDemoPageState extends State<SecureTextFieldDemoPage> {
  final TextEditingController _controller = TextEditingController(text: '');
  String _valueInfo = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateValueInfo);
    _updateValueInfo();
  }

  @override
  void dispose() {
    _controller.removeListener(_updateValueInfo);
    _controller.dispose();
    super.dispose();
  }

  void _updateValueInfo() {
    if (!mounted) return;
    setState(() {
      _valueInfo = 'Length: ${_controller.text.length}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Secure Text Field'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Default Secure Text Field',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CNSecureTextField(
              controller: _controller,
              placeholder: 'Enter password...',
              width: 320,
              bezelStyle: CNTextFieldBezelStyle.round,
              onChanged: (_) {},
            ),
            const SizedBox(height: 12),
            Text(_valueInfo),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Set Sample',
                  onPressed: () {
                    _controller.text = 's3cr3t-passw0rd';
                  },
                ),
                CNButton(
                  style: CNButtonStyle.filled,
                  label: 'Clear',
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Styled Secure Text Field',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CNSecureTextField(
              controller: TextEditingController(text: ''),
              placeholder: 'Styled secure input',
              placeholderColor: CupertinoColors.systemGrey,
              placeholderFont: const CNFont.monospacedSystem(
                CNFontSize.points(14),
                weight: CNFontWeight.medium,
              ),
              backgroundColor: CupertinoColors.systemYellow.withOpacity(0.25),
              font: const CNFont.system(
                CNFontSize.points(15),
                weight: CNFontWeight.semibold,
              ),
              controlSize: CNControlSize.regular,
              bezelStyle: CNTextFieldBezelStyle.round,
              width: 320,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

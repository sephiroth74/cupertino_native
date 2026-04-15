import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ComboBoxDemoPage extends StatefulWidget {
  const ComboBoxDemoPage({super.key});

  @override
  State<ComboBoxDemoPage> createState() => _ComboBoxDemoPageState();
}

class _ComboBoxDemoPageState extends State<ComboBoxDemoPage> {
  // Plain String state — no TextEditingController needed.
  String _editableText = 'Apple';
  String _selectableText = 'Banana';
  String _noneText = 'Cherry';

  final List<String> _items = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Combo Box')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Editable (default) ──────────────────────────────────────────
            const Text(
              'Editable (default)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'behavior: CNComboBoxBehavior.editable — user can type and pick from the dropdown.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            CNComboBox(
              items: _items,
              text: _editableText,
              behavior: CNComboBoxBehavior.editable,
              placeholder: 'Type or choose…',
              width: 320,
              onChanged: (value) => setState(() => _editableText = value),
              onSubmitted: (value) => setState(() => _editableText = value),
            ),
            const SizedBox(height: 4),
            Text(
              'Current value: "$_editableText"',
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 32),

            // ── Selectable ──────────────────────────────────────────────────
            const Text(
              'Selectable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'behavior: CNComboBoxBehavior.selectable — user can open the dropdown and pick an item, but cannot type.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            CNComboBox(
              items: _items,
              text: _selectableText,
              behavior: CNComboBoxBehavior.selectable,
              placeholder: 'Choose an item…',
              width: 320,
              onChanged: (value) => setState(() => _selectableText = value),
            ),
            const SizedBox(height: 4),
            Text(
              'Current value: "$_selectableText"',
              style: const TextStyle(fontSize: 12),
            ),

            const SizedBox(height: 32),

            // ── None (display-only) ─────────────────────────────────────────
            const Text(
              'Display-only',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'behavior: CNComboBoxBehavior.none — control is fully disabled; shows the value but accepts no input.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            CNComboBox(
              items: _items,
              text: _noneText,
              behavior: CNComboBoxBehavior.none,
              width: 320,
            ),
            const SizedBox(height: 4),
            Text(
              'Fixed value: "$_noneText"',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

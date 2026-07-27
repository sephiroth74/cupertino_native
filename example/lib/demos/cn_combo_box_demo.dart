import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ComboBoxDemoPage extends StatefulWidget {
  const ComboBoxDemoPage({super.key});

  @override
  State<ComboBoxDemoPage> createState() => _ComboBoxDemoPageState();
}

class _ComboBoxDemoPageState extends State<ComboBoxDemoPage> {
  final _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
    'Kiwi',
    'Lemon',
    'Mango',
    'Nectarine',
    'Orange',
    'Papaya',
    'Quince',
    'Raspberry',
    'Strawberry',
  ];

  String _selectedValue = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CNComboBox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          CNComboBox(
            text: _selectedValue,
            items: _fruits,
            placeholder: 'Select a fruit...',
            completes: true,
            numberOfVisibleItems: 8,
            constraints: const BoxConstraints(maxWidth: 250),
            onChanged: (value) {
              setState(() => _selectedValue = value);
            },
            onSelectionChanged: (index) {
              debugPrint('Selection index: $index');
            },
          ),
          const SizedBox(height: 16),
          Text('Value: $_selectedValue'),
        ],
      ),
    );
  }
}

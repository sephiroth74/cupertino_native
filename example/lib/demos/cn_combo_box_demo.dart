import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:flutter/cupertino.dart';

class ComboBoxDemoPage extends StatefulWidget {
  const ComboBoxDemoPage({super.key});

  @override
  State<ComboBoxDemoPage> createState() => _ComboBoxDemoPageState();
}

class _ComboBoxDemoPageState extends State<ComboBoxDemoPage> {
  bool completes = true;
  bool isEnabled = true;

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
    return CNContentArea(
      builder: (context, scrollController) {
        return SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CNComboBox', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      const Text('Bordered', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      CNComboBox(
                        text: _selectedValue,
                        items: _fruits,
                        placeholder: 'Select a fruit...',
                        completes: completes,
                        constraints: const BoxConstraints(maxWidth: 200),
                        onChanged: isEnabled
                            ? (value) {
                                setState(() => _selectedValue = value);
                              }
                            : null,
                        onSelectionChanged: isEnabled
                            ? (index) {
                                debugPrint('Selection index: $index');
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Plain', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      CNComboBox(
                        text: _selectedValue,
                        items: _fruits,
                        style: CNComboBoxStyle.plain,
                        placeholder: 'Select a fruit...',
                        completes: completes,
                        constraints: const BoxConstraints(maxWidth: 200),
                        onChanged: isEnabled
                            ? (value) {
                                setState(() => _selectedValue = value);
                              }
                            : null,
                        onSelectionChanged: isEnabled
                            ? (index) {
                                debugPrint('Selection index: $index');
                              }
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Value: $_selectedValue'),
                    ],
                  ),
                ),
              ),

              RightSideOptionContainer(
                options: {
                  'Enabled': CNToggle(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value)),
                  'Completes': CNToggle(isOn: completes, onChanged: (value) => setState(() => completes = value)),
                  },
              ),
            ],
          ),
        );
      },
    );
  }
}

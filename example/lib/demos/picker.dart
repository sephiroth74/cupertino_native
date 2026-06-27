import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class PickerDemoPage extends StatefulWidget {
  const PickerDemoPage({super.key});

  @override
  State<PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<PickerDemoPage> {
  int _basicPickerIndex = 0;
  int _coloredPickerIndex = 1;
  CNControlSize _controlSize = CNControlSize.large;
  int _controlSizeIndex = CNControlSize.values.indexOf(CNControlSize.large);
  int _iconPickerIndex = 0;
  int _labelPickerIndex = 0;
  CNPickerStyle _pickerStyle = CNPickerStyle.radioGroup;
  int _shrinkWrappedPickerIndex = 0;
  final List<CNControlSize> _sizes = CNControlSize.values;
  int _sublabelPickerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Picker (SwiftUI)')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey.withOpacity(0.2),
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: CNPicker(
                        label: 'Control Size',
                        sublabel: 'Select Control Size',
                        items: CNControlSize.values.map((e) => e.name).toList(),
                        selectedIndex: _controlSizeIndex,
                        pickerStyle: CNPickerStyle.menu,
                        controlSize: CNControlSize.large,
                        onValueChanged: (i) => setState(() {
                          _controlSizeIndex = i;
                          _controlSize = CNControlSize.values[i];
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CNPicker(
                        items: CNPickerStyle.values.map((e) => e.name).toList(),
                        selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                        pickerStyle: CNPickerStyle.segmented,
                        controlSize: _controlSize,
                        onValueChanged: (i) => setState(() {
                          _pickerStyle = CNPickerStyle.values[i];
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CNPicker(
                        icons: [
                          CNSymbol('square.split.2x1'),
                          CNSymbol('circle.inset.filled'),
                          CNSymbol('list.bullet'),
                          CNSymbol('gearshape'),
                          CNSymbol('rectangle.portrait'),
                          CNSymbol('paintpalette'),
                        ],
                        selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                        pickerStyle: CNPickerStyle.palette,
                        controlSize: _controlSize,
                        onValueChanged: (i) => setState(() {
                          _pickerStyle = CNPickerStyle.values[i];
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CNPicker(
                        label: 'Radio Group Picker',
                        items: CNPickerStyle.values.map((e) => e.name).toList(),
                        selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                        pickerStyle: CNPickerStyle.radioGroup,
                        controlSize: _controlSize,
                        onValueChanged: (i) => setState(() {
                          _pickerStyle = CNPickerStyle.values[i];
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: CupertinoColors.systemGrey.withOpacity(0.2),
                            style: BorderStyle.solid,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: CNPicker(
                          label: 'Picker Style',
                          sublabel: 'Select Picker Style',
                          items: CNPickerStyle.values.map((e) => e.name).toList(),
                          selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                          pickerStyle: CNPickerStyle.menu,
                          controlSize: _controlSize,
                          onValueChanged: (i) => setState(() {
                            _pickerStyle = CNPickerStyle.values[i];
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

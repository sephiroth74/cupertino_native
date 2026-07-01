import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  CNControlSize _controlSize = CNControlSize.large;
  String _last = 'None';
  bool _shrinkWrap = true;
  final List<CNControlSize> _sizes = CNControlSize.values;
  final Color? _tint = null;
  CNImageScale _imageScale = CNImageScale.large;
  CNSymbolRenderingMode _symbolRenderingMode = CNSymbolRenderingMode.hierarchical;
  CNButtonStyle _buttonStyle = CNButtonStyle.automatic;

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Text buttons'),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNPicker(
                      onValueChanged: (value) {
                        setState(() {
                          debugPrint('Selected control size: ${_sizes[value]}');
                          _controlSize = _sizes[value];
                        });
                      },
                      selectedIndex: _sizes.indexOf(_controlSize),
                      controlSize: CNControlSize.large,
                      pickerStyle: CNPickerStyle.automatic,
                      shrinkWrap: true,
                      items: CNControlSize.values.map((size) => CNPickerItem.text(size.name)).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNPicker(
                      selectedIndex: _imageScale.index,
                      controlSize: CNControlSize.large,
                      shrinkWrap: true,
                      pickerStyle: CNPickerStyle.menu,
                      items: CNImageScale.values.map((scale) => CNPickerItem.text(scale.name)).toList(),
                      onValueChanged: (value) {
                        setState(() {
                          debugPrint('Selected image scale: ${CNImageScale.values[value]}');
                          _imageScale = CNImageScale.values[value];
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNPicker(
                      selectedIndex: _symbolRenderingMode.index,
                      controlSize: CNControlSize.large,
                      shrinkWrap: true,
                      pickerStyle: CNPickerStyle.menu,
                      items: CNSymbolRenderingMode.values.map((mode) => CNPickerItem.text(mode.name)).toList(),
                      onValueChanged: (value) {
                        setState(() {
                          debugPrint('Selected symbol rendering mode: ${CNSymbolRenderingMode.values[value]}');
                          _symbolRenderingMode = CNSymbolRenderingMode.values[value];
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNPicker(
                      selectedIndex: _buttonStyle.index,
                      controlSize: CNControlSize.large,
                      shrinkWrap: true,
                      pickerStyle: CNPickerStyle.menu,
                      items: CNButtonStyle.values.map((style) => CNPickerItem.text(style.name)).toList(),
                      onValueChanged: (value) {
                        setState(() {
                          debugPrint('Selected button style: ${CNButtonStyle.values[value]}');
                          _buttonStyle = CNButtonStyle.values[value];
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {0: FlexColumnWidth(200), 1: FlexColumnWidth(200)},
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CNButton(
                          label: 'Label Only',
                          symbolRenderingMode: _symbolRenderingMode,
                          style: _buttonStyle,
                          imageScale: _imageScale,
                          onPressed: () => _set('Automatic'),
                          shrinkWrap: _shrinkWrap,
                          controlSize: _controlSize,
                          tint: _tint,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CNButton(
                          label: 'Label and Icon',
                          systemImage: 'square.and.arrow.up',
                          symbolRenderingMode: _symbolRenderingMode,
                          style: _buttonStyle,
                          imageScale: _imageScale,
                          onPressed: () => _set('Plain'),
                          shrinkWrap: _shrinkWrap,
                          controlSize: _controlSize,
                          tint: _tint,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CNButton(
                          systemImage: 'square.and.arrow.up',
                          symbolRenderingMode: _symbolRenderingMode,
                          style: _buttonStyle,
                          imageScale: _imageScale,
                          onPressed: () => _set('Icon Only'),
                          shrinkWrap: _shrinkWrap,
                          controlSize: _controlSize,
                          tint: _tint,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const SizedBox.shrink(), // Empty cell
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('Last pressed: $_last'),
            ],
          ),
        ),
      ),
    );
  }
}

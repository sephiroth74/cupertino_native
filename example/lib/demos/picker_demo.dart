import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class PickerDemoPage extends StatefulWidget {
  const PickerDemoPage({super.key});

  @override
  State<PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<PickerDemoPage> {
  bool withLabels = true;

  CNControlSize _controlSize = CNControlSize.large;
  int _controlSizeIndex = CNControlSize.values.indexOf(CNControlSize.large);
  Color? _foregroundColor;
  CNPickerStyle _pickerStyle = CNPickerStyle.menu;
  Color? _tintColor;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Picker (SwiftUI)')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                          style: BorderStyle.solid,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: PixelPerfectProbe(
                        adjustPosition: true,
                        child: CNPicker(
                          key: ValueKey(1),
                          labelChildren: withLabels
                              ? [CNText('Control Size: ${_controlSize.name}'), CNText('Select an option from the list')]
                              : [],
                          items: CNControlSize.values
                              .map(
                                (e) => CNLabel(
                                  CNText(e.name),
                                  icon: CNImage(systemSymbolName: 'textformat.size'),
                                  modifiers: CNViewModifiers(tag: e.index),
                                ),
                              )
                              .toList(),
                          selectedIndex: _controlSizeIndex,
                          pickerStyle: _pickerStyle,
                          modifiers: CNViewModifiers(
                            controlSize: _controlSize,
                            tint: _tintColor,
                            foregroundColor: _foregroundColor,
                          ),
                          onValueChanged: (i) => setState(() {
                            _controlSizeIndex = i;
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Control Size': CNPicker(
                  selectedIndex: CNControlSize.values.indexOf(_controlSize),
                  onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                  items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                  modifiers: CNViewModifiers(controlSize: CNControlSize.large),
                ),
                'Picker Style': CNPicker(
                  selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                  onValueChanged: (index) => setState(() => _pickerStyle = CNPickerStyle.values[index]),
                  items: CNPickerStyle.values.map((style) {
                    return CNText(style.name);
                  }).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                  modifiers: CNViewModifiers(controlSize: CNControlSize.large),
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  value: _tintColor,
                  onChanged: (c) => setState(() => _tintColor = c),
                ),
                'Foreground Color': ColorPicker(
                  colors: kSystemColors,
                  value: _foregroundColor,
                  onChanged: (c) => setState(() => _foregroundColor = c),
                ),
                'With Labels': CNToggle(value: withLabels, onChanged: (value) => setState(() => withLabels = value)),
              },
            ),
          ],
        ),
      ),
    );
  }
}

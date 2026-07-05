import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class PickerDemoPage extends StatefulWidget {
  const PickerDemoPage({super.key});

  @override
  State<PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<PickerDemoPage> {
  CNControlSize _controlSize = CNControlSize.large;
  int _controlSizeIndex = CNControlSize.values.indexOf(CNControlSize.large);
  Color? _foregroundColor;
  CNPickerStyle _pickerStyle = CNPickerStyle.radioGroup;
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
                                color: CupertinoColors.systemGrey.withValues(alpha: 0.2),
                                style: BorderStyle.solid,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: CNPicker(
                              labelChildren: [CNText('Basic Picker'), CNText('Select an option from the list')],
                              items: CNControlSize.values
                                  .map(
                                    (e) => CNLabel(
                                      CNText(e.name),
                                      icon: CNImage(systemSymbolName: 'textformat.size'),
                                      tag: e.index,
                                    ),
                                  )
                                  .toList(),
                              selectedIndex: _controlSizeIndex,
                              pickerStyle: _pickerStyle,
                              viewModifiers: CNViewModifiers(
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
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints.expand(width: 350),
                decoration: BoxDecoration(
                  color: CNTheme.of(context).fillPrimaryColor,
                  border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: const Text('Control Size')),
                        CNPicker(
                          selectedIndex: CNControlSize.values.indexOf(_controlSize),
                          onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                          items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                          viewModifiers: CNViewModifiers(
                            controlSize: CNControlSize.large,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Picker Style')),
                        CNPicker(
                          selectedIndex: CNPickerStyle.values.indexOf(_pickerStyle),
                          onValueChanged: (index) => setState(() => _pickerStyle = CNPickerStyle.values[index]),
                          items: CNPickerStyle.values.map((style) {
                            return CNText(style.name);
                          }).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                          viewModifiers: CNViewModifiers(
                            controlSize: CNControlSize.large,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const Text('Tint Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            _tintColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == _tintColor).key,
                          ),
                          onValueChanged: (index) => setState(() => _tintColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys
                              .map(
                                (colorName) => CNLabel(
                                  CNText(colorName),
                                  icon: CNImage(
                                    systemSymbolName: kSystemColors[colorName] != null ? 'circle.fill' : 'circle',
                                    viewModifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                                  ),
                                ),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
                          viewModifiers: CNViewModifiers(
                            controlSize: CNControlSize.large,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const Text('Foreground Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            _foregroundColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == _foregroundColor).key,
                          ),
                          onValueChanged: (index) => setState(() => _foregroundColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys
                              .map(
                                (colorName) => CNLabel(
                                  CNText(colorName),
                                  icon: CNImage(
                                    systemSymbolName: kSystemColors[colorName] != null ? 'circle.fill' : 'circle',
                                    viewModifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                                  ),
                                ),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
                          viewModifiers: CNViewModifiers(
                            controlSize: CNControlSize.large,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

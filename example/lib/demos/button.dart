import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

const _kSystemColors = {
  'none': null,
  'red': CNColors.red,
  'orange': CNColors.orange,
  'yellow': CNColors.yellow,
  'green': CNColors.green,
  'mint': CNColors.mint,
  'teal': CNColors.teal,
  'cyan': CNColors.cyan,
  'blue': CNColors.blue,
  'indigo': CNColors.indigo,
  'pink': CNColors.pink,
  'purple': CNColors.purple,
  'brown': CNColors.brown,
  'gray': CNColors.gray,
  'fillPrimary': CNColors.fillPrimary,
  'fillSecondary': CNColors.fillSecondary,
  'fillTertiary': CNColors.fillTertiary,
  'fillQuaternary': CNColors.fillQuaternary,
  'fillQuinary': CNColors.fillQuinary,
};

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  CNButtonStyle _buttonStyle = CNButtonStyle.automatic;
  CNControlSize _controlSize = CNControlSize.large;
  // ignore: unused_field
  String _last = 'None';

  Color? _tintColor;

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CNButton(
                        onPressed: () => _set('Default'),
                        modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                        style: _buttonStyle,
                        children: const [CNText('Default')],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CNButton(
                        onPressed: () => _set('Button with Icon'),
                        modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                        style: _buttonStyle,
                        shrinkWrap: true,
                        children: const [
                          CNImage(systemSymbolName: 'square.and.arrow.up'),
                          CNText('Button with Icon'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CNButton(
                        onPressed: () => _set('Icon Only'),
                        modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                        style: _buttonStyle,
                        shrinkWrap: true,
                        children: const [CNImage(systemSymbolName: 'square.and.arrow.up')],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CNButton(
                        onPressed: () => _set('Progress View'),
                        modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                        style: _buttonStyle,
                        shrinkWrap: true,
                        children: const [
                          CNProgressView(
                            progressViewStyle: CNProgressViewStyle.linear,
                            modifiers: CNViewModifiers(controlSize: CNControlSize.small, width: 50, tint: CNColors.white),
                          ),
                          CNText('Progress View'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: BoxConstraints.expand(width: 350),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Button Style')),
                        CNPicker(
                          selectedIndex: CNButtonStyle.values.indexOf(_buttonStyle),
                          onValueChanged: (index) => setState(() => _buttonStyle = CNButtonStyle.values[index]),
                          items: CNButtonStyle.values.map((size) => CNText(size.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Tint Color')),
                        CNPicker(
                          selectedIndex: _kSystemColors.keys.toList().indexOf(
                            _tintColor == null
                                ? 'none'
                                : _kSystemColors.entries.firstWhere((entry) => entry.value == _tintColor).key,
                          ),
                          onValueChanged: (index) => setState(() => _tintColor = _kSystemColors.values.elementAt(index)),
                          items: _kSystemColors.keys
                              .map(
                                (colorName) => CNLabel(
                                  CNText(colorName),
                                  icon: CNImage(
                                    systemSymbolName: 'circle.fill',
                                    modifiers: CNViewModifiers(tint: _kSystemColors[colorName]),
                                  ),
                                ),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
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

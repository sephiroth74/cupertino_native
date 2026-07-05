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

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _defaultSliderValue = .5;
  bool _isEditing = false;
  bool _isEnabled = true;
  bool _isStepped = false;
  CNControlSize _size = CNControlSize.regular;
  Color? _tintColor;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Slider')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 16),
                  Row(children: [const Text('Default'), Spacer(), Text('Value: ${_defaultSliderValue.toStringAsFixed(2)}')]),
                  CNSlider(
                    value: _defaultSliderValue,
                    onChanged: _isEnabled ? (v) => setState(() => _defaultSliderValue = v) : null,
                    onEditingChanged: (editing) => setState(() => _isEditing = editing),
                    controlSize: _size,
                    step: _isStepped ? 0.025 : null,
                    color: _tintColor,
                  ),
                  const SizedBox(height: 16),
                  Text('Editing: ${_isEditing ? 'true' : 'false'}', style: CNTheme.of(context).typography.body),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                          selectedIndex: CNControlSize.values.indexOf(_size),
                          onValueChanged: (index) => setState(() => _size = CNControlSize.values[index]),
                          items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const Text('Enabled')),
                        CNToggle(
                          value: _isEnabled,
                          onChanged: (enabled) => setState(() => _isEnabled = enabled),
                          modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                          toggleStyle: CNToggleStyle.switch_,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const Text('Steps')),
                        CNToggle(
                          value: _isStepped,
                          onChanged: (enabled) => setState(() => _isStepped = enabled),
                          modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                          toggleStyle: CNToggleStyle.switch_,
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

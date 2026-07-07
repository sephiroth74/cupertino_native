import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

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
  CupertinoDynamicColor? _tintColor;

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
                    step: _isStepped ? 0.025 : null,
                    modifiers: CNViewModifiers(controlSize: _size, tint: _tintColor, padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), enabled: _isEnabled),
                  ),
                  const SizedBox(height: 16),
                  Text('Editing: ${_isEditing ? 'true' : 'false'}', style: CNTheme.of(context).typography.body),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RightSideOptionContainer(
              options: {
                'Control Size': CNPicker(
                  selectedIndex: CNControlSize.values.indexOf(_size),
                  onValueChanged: (index) => setState(() => _size = CNControlSize.values[index]),
                  items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Enabled': CNToggle(
                  value: _isEnabled,
                  onChanged: (enabled) => setState(() => _isEnabled = enabled),
                  modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                  toggleStyle: CNToggleStyle.switch_,
                ),
                'Stepped': CNToggle(
                  value: _isStepped,
                  onChanged: (enabled) => setState(() => _isStepped = enabled),
                  modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                  toggleStyle: CNToggleStyle.switch_,
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: _tintColor,
                  onValueChanged: (value) => setState(() => _tintColor = kSystemColors.values.elementAt(value)),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

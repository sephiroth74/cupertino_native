import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = true;

class SliderDemoPage extends StatefulWidget {
  const SliderDemoPage({super.key});

  @override
  State<SliderDemoPage> createState() => _SliderDemoPageState();
}

class _SliderDemoPageState extends State<SliderDemoPage> {
  double _defaultSliderValue = .5;
  bool _hasTicks = false;
  bool _isEditing = false;
  bool _isEnabled = true;
  bool _isStepped = false;
  bool _showLabels = false;
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
                  Text('Value: ${_defaultSliderValue.toStringAsFixed(2)}'),
                  const SizedBox(height: 16),
                  CNSlider2(
                    debugLog: _kDebugLog,
                    value: _defaultSliderValue,
                    onChanged: _isEnabled
                        ? (v) => setState(() {
                            debugPrint('new value: $v');
                            _defaultSliderValue = v;
                          })
                        : null,
                    onEditingChanged: (editing) => setState(() => _isEditing = editing),
                    minimumValueLabel: _showLabels ? "0.0" : null,
                    maximumValueLabel: _showLabels ? "1.0" : null,
                    step: _isStepped ? 0.05 : null,
                    ticks: _hasTicks
                        ? [
                            CNSliderTick(0.1, label: "0.1"),
                            CNSliderTick(0.2, label: "0.2"),
                            CNSliderTick(0.3, label: "0.3"),
                            CNSliderTick(0.4, label: "0.4"),
                            CNSliderTick(0.5, label: "0.5"),
                            CNSliderTick(0.6, label: "0.6"),
                            CNSliderTick(0.7, label: "0.7"),
                            CNSliderTick(0.8, label: "0.8"),
                            CNSliderTick(0.9, label: "0.9"),
                          ]
                        : null,
                    controlSize: _size,
                    tint: _tintColor,
                    paddings: EdgeInsets.only(bottom: 6, top: 2),
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
                  onChanged: (enabled) => setState(() {
                    _hasTicks = false;
                    _isStepped = enabled;
                  }),
                  modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                  toggleStyle: CNToggleStyle.switch_,
                ),
                'Ticks': CNToggle(
                  value: _hasTicks,
                  onChanged: (enabled) => setState(() {
                    _isStepped = false;
                    _hasTicks = enabled;
                  }),
                  modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                  toggleStyle: CNToggleStyle.switch_,
                ),
                'Labels': CNToggle(
                  value: _showLabels,
                  onChanged: (enabled) => setState(() => _showLabels = enabled),
                  modifiers: CNViewModifiers(controlSize: CNControlSize.small),
                  toggleStyle: CNToggleStyle.switch_,
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  value: _tintColor,
                  onChanged: (c) => setState(() => _tintColor = c),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

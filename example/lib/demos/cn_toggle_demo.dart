import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _kDebugLog = true;

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({super.key});

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  CNControlSize controlSize = CNControlSize.regular;
  bool isEnabled = true;
  bool isOn = true;
  Color? tintColor;
  CNToggle2Style toggleStyle = CNToggle2Style.switchStyle;

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)));
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Toggle Demo')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CNToggle2(
                    debugLog: _kDebugLog,
                    isOn: isOn,
                    toggleStyle: toggleStyle,
                    controlSize: controlSize,
                    tint: tintColor,
                    onChanged: isEnabled ? (v) => setState(() => isOn = v) : null,
                    content: CNChildVStack(
                      alignment: CNAlignment.leading,
                      children: [
                        CNChildText('Vibrate on Ring'),
                        CNChildText(
                          "Enable vibration when the phone rings",
                          font: CNFont.label(CNFontSize.preset(CNFontSizePreset.system)),
                          foregroundColor: CupertinoColors.secondaryLabel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Toggle is ${isOn ? "ON" : "OFF"}', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
                'Toggle Style': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  selectedIndex: CNToggle2Style.values.indexOf(toggleStyle),
                  onValueChanged: (index) => setState(() => toggleStyle = CNToggle2Style.values[index]),
                  items: CNToggle2Style.values.map((style) => CNText(style.name)).toList(),
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: tintColor,
                  onValueChanged: (index) => setState(() => tintColor = kSystemColors.values.elementAt(index)),
                ),
                'Enabled': CNToggle2(
                  isOn: isEnabled,
                  toggleStyle: CNToggle2Style.switchStyle,
                  controlSize: CNControlSize.regular,
                  onChanged: (v) => setState(() => isEnabled = v),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

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
  CNToggleStyle toggleStyle = CNToggleStyle.switchStyle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20),
                CNToggle(
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
                        font: CNFont.label(
                          CNFontSize.preset(CNFontSizePreset.system),
                        ),
                        foregroundColor: CupertinoColors.secondaryLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Toggle is ${isOn ? "ON" : "OFF"}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          RightSideOptionContainer(
            options: {
              'Control Size': ControlSizePicker(
                value: controlSize,
                onChanged: (size) => setState(() => controlSize = size),
              ),
              'Toggle Style': CNPicker(
                selection: toggleStyle.name,
                onChanged: (value) => setState(
                  () => toggleStyle = CNToggleStyle.values.firstWhere(
                    (style) => style.name == value,
                  ),
                ),
                children: CNToggleStyle.values
                    .map((style) => CNChildText(style.name, tag: style.name))
                    .toList(),
              ),
              'Tint Color': ColorPicker(
                colors: kSystemColors,
                value: tintColor,
                onChanged: (color) => setState(() => tintColor = color),
              ),
              'Enabled': CNToggle(
                isOn: isEnabled,
                onChanged: (v) => setState(() => isEnabled = v),
              ),
            },
          ),
        ],
      ),
    );
  }
}

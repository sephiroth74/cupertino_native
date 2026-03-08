import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class CheckboxDemoPage extends StatefulWidget {
  const CheckboxDemoPage({super.key});

  @override
  State<CheckboxDemoPage> createState() => _CheckboxDemoPageState();
}

class _CheckboxDemoPageState extends State<CheckboxDemoPage> {
  bool _basicCheckboxValue = true;
  bool _coloredCheckboxValue = true;
  bool _checkboxesEnabled = true;
  CNControlSize _size = CNControlSize.regular;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Checkbox Demo'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // control sizes
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Enabled'),
                const SizedBox(width: 16),
                CNSwitch(
                  value: _checkboxesEnabled,
                  onChanged: (v) =>
                      setState(() => _checkboxesEnabled = v == true),
                ),
                const SizedBox(width: 32),
                const Text('Size'),
                const SizedBox(width: 16),
                CNPopupMenuButton.icon(
                  buttonIcon: CNSymbol('gearshape', size: 12),
                  items: [
                    CNPopupMenuItem(
                      label: 'Mini',
                      checked: _size == CNControlSize.mini,
                    ),
                    CNPopupMenuItem(
                      label: 'Small',
                      checked: _size == CNControlSize.small,
                    ),
                    CNPopupMenuItem(
                      label: 'Regular',
                      checked: _size == CNControlSize.regular,
                    ),
                    CNPopupMenuItem(
                      label: 'Large',
                      checked: _size == CNControlSize.large,
                    ),
                  ],
                  onSelected: (v) =>
                      setState(() => _size = CNControlSize.values[v]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Basic ${_basicCheckboxValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNCheckbox(
                  label: 'Default checkbox',
                  value: _basicCheckboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled
                      ? (v) => setState(() => _basicCheckboxValue = v)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Colored ${_basicCheckboxValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNCheckbox(
                  label: 'Colored checkbox',
                  color: CupertinoColors.systemMint,
                  value: _basicCheckboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled
                      ? (v) => setState(() => _basicCheckboxValue = v)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Simple ${_basicCheckboxValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNCheckbox(
                  value: _basicCheckboxValue,
                  controlSize: _size,
                  onChanged: _checkboxesEnabled
                      ? (v) => setState(() => _basicCheckboxValue = v)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row(
            //   children: [
            //     Text('Colored ${_coloredCheckboxValue ? 'ON' : 'OFF'}'),
            //     Spacer(),
            //     CNCheckbox(
            //       value: _coloredCheckboxValue,
            //       controlSize: _size,
            //       color: CupertinoColors.systemPink,
            //       onChanged: (v) => setState(() => _coloredCheckboxValue = v),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 48),
            // Row(
            //   children: [
            //     Text('Disabled'),
            //     Spacer(),
            //     CNCheckbox(value: false, onChanged: null, controlSize: _size),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

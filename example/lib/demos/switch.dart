import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class SwitchDemoPage extends StatefulWidget {
  const SwitchDemoPage({super.key});

  @override
  State<SwitchDemoPage> createState() => _SwitchDemoPageState();
}

class _SwitchDemoPageState extends State<SwitchDemoPage> {
  bool _basicSwitchValue = true;
  bool _coloredSwitchValue = true;
  CNControlSize _size = CNControlSize.regular;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Switch')),
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
                Text('Basic ${_basicSwitchValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNSwitch(
                  value: _basicSwitchValue,
                  controlSize: _size,
                  onChanged: (v) => setState(() => _basicSwitchValue = v),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Text('Colored ${_coloredSwitchValue ? 'ON' : 'OFF'}'),
                Spacer(),
                CNSwitch(
                  value: _coloredSwitchValue,
                  controlSize: _size,
                  color: CupertinoColors.systemPink,
                  onChanged: (v) => setState(() => _coloredSwitchValue = v),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Text('Disabled'),
                Spacer(),
                CNSwitch(value: false, onChanged: null, controlSize: _size),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

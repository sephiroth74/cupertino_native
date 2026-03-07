import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class StepperDemoPage extends StatefulWidget {
  const StepperDemoPage({super.key});

  @override
  State<StepperDemoPage> createState() => _StepperDemoPageState();
}

class _StepperDemoPageState extends State<StepperDemoPage> {
  double _value = 5;
  double _wrappedValue = 0;
  double _coarseValue = 10;
  CNControlSize _size = CNControlSize.regular;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Stepper')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
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
                    CNPopupMenuItem(
                      label: 'Extra Large',
                      checked: _size == CNControlSize.extraLarge,
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
                Text('Default: ${_value.toStringAsFixed(0)}'),
                const Spacer(),
                CNStepper(
                  value: _value,
                  min: 0,
                  max: 10,
                  step: 1,
                  controlSize: _size,
                  onChanged: (v) => setState(() => _value = v),
                ),
              ],
            ),
            // const SizedBox(height: 32),
            // Row(
            //   children: [
            //     Text('Wraps: ${_wrappedValue.toStringAsFixed(0)}'),
            //     const Spacer(),
            //     CNStepper(
            //       value: _wrappedValue,
            //       min: 0,
            //       max: 5,
            //       step: 1,
            //       valueWraps: true,
            //       controlSize: _size,
            //       onChanged: (v) => setState(() => _wrappedValue = v),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 32),
            // Row(
            //   children: [
            //     Text('Step 5: ${_coarseValue.toStringAsFixed(0)}'),
            //     const Spacer(),
            //     CNStepper(
            //       value: _coarseValue,
            //       min: 0,
            //       max: 50,
            //       step: 5,
            //       controlSize: _size,
            //       onChanged: (v) => setState(() => _coarseValue = v),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 32),
            // Row(
            //   children: [
            //     Text('Disabled'),
            //     const Spacer(),
            //     CNStepper(
            //       value: 3,
            //       min: 0,
            //       max: 10,
            //       step: 1,
            //       controlSize: _size,
            //       onChanged: null,
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

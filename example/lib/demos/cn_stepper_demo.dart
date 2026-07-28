import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class StepperDemoPage extends StatefulWidget {
  const StepperDemoPage({super.key});

  @override
  State<StepperDemoPage> createState() => _StepperDemoPageState();
}

class _StepperDemoPageState extends State<StepperDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  bool enabled = true;
  double value = 5;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Stepper')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CNText(
                      'Value: ${value.toStringAsFixed(0)}',
                      constraints: BoxConstraints(minWidth: 100, maxWidth: 100, maxHeight: 32),
                    ),
                    const SizedBox(width: 8),
                    CNStepper(
                      debugLog: _kDebugLog,
                      value: value,
                      min: 0,
                      max: 100,
                      step: 1,
                      controlSize: controlSize,
                      onChanged: enabled ? (v) => setState(() => value = v) : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            RightSideOptionContainer(
              title: 'Options',
              options: {
                'Control Size': ControlSizePicker(
                  value: controlSize,
                  onChanged: (newSize) => setState(() => controlSize = newSize),
                ),
                'Enabled': CNToggle(isOn: enabled, onChanged: (v) => setState(() => enabled = v)),
              },
            ),
          ],
        ),
      ),
    );
  }
}

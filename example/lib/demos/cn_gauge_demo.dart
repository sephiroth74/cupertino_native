import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class GaugeDemoPage extends StatefulWidget {
  const GaugeDemoPage({super.key});

  @override
  State<GaugeDemoPage> createState() => _GaugeDemoPageState();
}

class _GaugeDemoPageState extends State<GaugeDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  CNGaugeStyle gaugeStyle = CNGaugeStyle.accessoryCircular;
  CNShapeStyle? gradientTint = CNShapeStyle.gradient([
    CNGradientStop(CNColors.green, 0.0),
    CNGradientStop(CNColors.yellow, 0.33),
    CNGradientStop(CNColors.orange, 0.66),
    CNGradientStop(CNColors.red, 1.0),
  ]);

  bool showLabels = true;
  double sliderValue = 67.0;
  Color? tint;
  bool useGrsdientTint = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                Text('Value: ${sliderValue.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                CNGauge(
                  controlSize: controlSize,
                  paddings: EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                  debugLog: _kDebugLog,
                  value: sliderValue,
                  tint: useGrsdientTint ? gradientTint : tint,
                  gaugeStyle: gaugeStyle,
                  min: 0.0,
                  max: 100.0,
                  label: showLabels ? [CNChildImage('heart.fill', foregroundColor: CNColors.red)] : null,
                  currentValueLabel: showLabels
                      ? [CNChildText(sliderValue.toInt().toString(), foregroundColor: CNColors.green)]
                      : null,
                  minimumValueLabel: showLabels ? [CNChildText('0', foregroundColor: CNColors.green)] : null,
                  maximumValueLabel: showLabels ? [CNChildText('100', foregroundColor: CNColors.red)] : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 8),
          RightSideOptionContainer(
            options: {
              'Control Size': ControlSizePicker(
                value: controlSize,
                onChanged: (newSize) => setState(() => controlSize = newSize),
              ),
              'Gauge Style': CNPicker(
                selection: gaugeStyle.name,
                onChanged: (newStyle) => setState(() => gaugeStyle = CNGaugeStyle.values.firstWhere((s) => s.name == newStyle)),
                children: CNGaugeStyle.values.map((s) => CNChildText(s.name, tag: s.name)).toList(),
              ),
              'Show Labels': CNToggle(isOn: showLabels, onChanged: (enabled) => setState(() => showLabels = enabled)),
              'Gradient Tint': CNToggle(isOn: useGrsdientTint, onChanged: (enabled) => setState(() => useGrsdientTint = enabled)),
              'Tint Color': ColorPicker(
                colors: kSystemColors,
                value: tint,
                enabled: !useGrsdientTint,
                onChanged: (c) => setState(() => tint = c),
              ),
              'Value': SizeSliderPicker(
                value: sliderValue,
                min: 0.0,
                max: 100.0,
                onChanged: (newValue) => setState(() => sliderValue = newValue),
              ),
            },
          ),
        ],
      ),
    );
  }
}

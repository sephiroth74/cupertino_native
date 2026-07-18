import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class ProgressIndicatorsPageDemo extends StatefulWidget {
  const ProgressIndicatorsPageDemo({super.key});

  @override
  State<ProgressIndicatorsPageDemo> createState() => _ProgressIndicatorsPageDemoState();
}

class _ProgressIndicatorsPageDemoState extends State<ProgressIndicatorsPageDemo> {
  CNControlSize controlSize = CNControlSize.regular;
  bool isDetermininate = true;
  double progressValue = 0.75;
  CNProgressViewStyle progressViewStyle = CNProgressViewStyle.linear;
  Color? tintColor;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Progress View')),
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
                  Center(
                    child: CNProgressView2(
                      debugLog: _kDebugLog,
                      value: isDetermininate ? progressValue : null,
                      style: progressViewStyle,
                      controlSize: controlSize,
                      tint: tintColor,
                    ),
                  ),
                ],
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Control Size': ControlSizePicker(
                  value: controlSize,
                  onChanged: (newSize) => setState(() => controlSize = newSize),
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  value: tintColor,
                  onChanged: (newColor) => setState(() => tintColor = newColor),
                ),
                'Progress Style': CNPicker2(
                  selection: progressViewStyle.name,
                  onChanged: (newStyle) =>
                      setState(() => progressViewStyle = CNProgressViewStyle.values.firstWhere((style) => style.name == newStyle)),
                  children: CNProgressViewStyle.values.map((style) => CNChildText(style.name, tag: style.name)).toList(),
                  pickerStyle: CNPickerStyle2.automatic,
                ),
                'Determinate': CNToggle2(isOn: isDetermininate, onChanged: (value) => setState(() => isDetermininate = value)),
                'Value': CNSlider2(
                  value: progressValue,
                  onChanged: isDetermininate
                      ? (value) {
                          setState(() {
                            progressValue = value;
                          });
                        }
                      : null,
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

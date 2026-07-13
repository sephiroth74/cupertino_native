import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = true;

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
  CupertinoDynamicColor? tintColor;

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
                'Control Size': CNPicker(
                  selectedIndex: CNControlSize.values.indexOf(controlSize),
                  onValueChanged: (index) => setState(() => controlSize = CNControlSize.values[index]),
                  items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Tint Color': CNPicker(
                  selectedIndex: kSystemColors.keys.toList().indexOf(
                    tintColor == null ? 'none' : kSystemColors.entries.firstWhere((entry) => entry.value == tintColor).key,
                  ),
                  onValueChanged: (index) => setState(() => tintColor = kSystemColors.values.toList()[index]),
                  items: kSystemColors.keys.map((key) => CNText(key)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Progress Style': CNPicker(
                  selectedIndex: CNProgressViewStyle.values.indexOf(progressViewStyle),
                  onValueChanged: (index) => setState(() => progressViewStyle = CNProgressViewStyle.values[index]),
                  items: CNProgressViewStyle.values.map((style) => CNText(style.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Determinate': CNToggle(value: isDetermininate, onChanged: (value) => setState(() => isDetermininate = value)),
                'Value': CNSlider(
                  value: progressValue,
                  modifiers: CNViewModifiers(enabled: isDetermininate),
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

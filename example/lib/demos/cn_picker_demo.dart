import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class PickerDemoPage extends StatefulWidget {
  const PickerDemoPage({super.key});

  @override
  State<PickerDemoPage> createState() => _PickerDemoPageState();
}

class _PickerDemoPageState extends State<PickerDemoPage> {
  CNControlSize controlSize = CNControlSize.regular;
  Color? foregroundColor;
  bool isEnabled = true;
  CNPickerStyle2 pickerStyle = CNPickerStyle2.menu;
  Color? tintColor;
  String value = 'walk';
  bool withLabels = true;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Picker (SwiftUI)')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: PixelPerfectProbe(
                      adjustPosition: true,
                      child: CNPicker2(
                        debugLog: _kDebugLog,
                        controlSize: controlSize,
                        pickerStyle: pickerStyle,
                        children: [
                          CNChildLabel('Walk', systemImage: 'figure.walk', tag: 'walk'),
                          if (pickerStyle == CNPickerStyle2.menu || pickerStyle == CNPickerStyle2.automatic) CNChildDivider(),
                          CNChildLabel('Airplane', systemImage: 'airplane', tag: 'airplane'),
                          CNChildLabel('Car', systemImage: 'car', tag: 'car'),
                          CNChildLabel('Bus', systemImage: 'bus', tag: 'bus'),
                          CNChildLabel('Tram', systemImage: 'tram', tag: 'tram'),
                          CNChildLabel('Train', systemImage: 'train.side.front.car', tag: 'train.side.front.car'),
                          CNChildLabel('Ferry', systemImage: 'ferry', tag: 'ferry'),
                          CNChildLabel('Sailboat', systemImage: 'sailboat', tag: 'sailboat'),
                          CNChildLabel('Bicycle', systemImage: 'bicycle', tag: 'bicycle'),
                        ],
                        label: withLabels ? [CNChildText('Picker Style'), CNChildText('Make a selection')] : null,
                        tint: tintColor,
                        foregroundColor: foregroundColor,
                        selection: value,
                        onChanged: isEnabled
                            ? (value) {
                                setState(() {
                                  debugPrint('Picker selection changed: $value');
                                  this.value = value;
                                });
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
                'Picker Style': CNPicker2(
                  pickerStyle: CNPickerStyle2.menu,
                  children: [
                    CNChildLabel('automatic', systemImage: 'automatic.brakesignal', tag: CNPickerStyle2.automatic.name),
                    CNChildDivider(),
                    CNChildLabel('inline', systemImage: 'lines.measurement.vertical', tag: CNPickerStyle2.inline.name),
                    CNChildLabel('menu', systemImage: 'filemenu.and.pointer.arrow', tag: CNPickerStyle2.menu.name),
                    CNChildLabel('palette', systemImage: 'swatchpalette', tag: CNPickerStyle2.palette.name),
                    CNChildLabel('radioGroup', systemImage: 'radio', tag: CNPickerStyle2.radioGroup.name),
                    CNChildLabel('segmented', systemImage: 'tablecells', tag: CNPickerStyle2.segmented.name),
                  ],
                  selection: pickerStyle.name,
                  onChanged: (value) {
                    setState(() {
                      pickerStyle = CNPickerStyle2.values.firstWhere((e) => e.name == value);
                    });
                  },
                ),
                'Tint Color': ColorPicker(colors: kSystemColors, value: tintColor, onChanged: (c) => setState(() => tintColor = c)),
                'Foreground Color': ColorPicker(
                  colors: kSystemColors,
                  value: foregroundColor,
                  onChanged: (c) => setState(() => foregroundColor = c),
                ),
                'Labels': CNToggle2(isOn: withLabels, onChanged: (value) => setState(() => withLabels = value)),
                'Enabled': CNToggle2(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value)),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
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
  FlutterPixelGeometry? geometry;
  bool isEnabled = true;
  CNPickerStyle pickerStyle = CNPickerStyle.menu;
  Color? tintColor;
  String value = 'walk';
  bool withLabels = true;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: CNPixelPerfectContainer(
                    onGeometryChanged: (value) {
                      debugPrint('Picker geometry changed: $value');
                      setState(() {
                        geometry = value;
                      });
                    },
                    adjustPosition: true,
                    child: CNPicker(
                      debugLog: _kDebugLog,
                      controlSize: controlSize,
                      pickerStyle: pickerStyle,
                      children: [
                        CNChildLabel(
                          'Walk',
                          systemImage: 'figure.walk',
                          tag: 'walk',
                        ),
                        if (pickerStyle == CNPickerStyle.menu ||
                            pickerStyle == CNPickerStyle.automatic)
                          CNChildDivider(),
                        CNChildLabel(
                          'Airplane',
                          systemImage: 'airplane',
                          tag: 'airplane',
                        ),
                        CNChildLabel('Car', systemImage: 'car', tag: 'car'),
                        CNChildLabel('Bus', systemImage: 'bus', tag: 'bus'),
                        CNChildLabel('Tram', systemImage: 'tram', tag: 'tram'),
                        CNChildLabel(
                          'Train',
                          systemImage: 'train.side.front.car',
                          tag: 'train.side.front.car',
                        ),
                        CNChildLabel(
                          'Ferry',
                          systemImage: 'ferry',
                          tag: 'ferry',
                        ),
                        CNChildLabel(
                          'Sailboat',
                          systemImage: 'sailboat',
                          tag: 'sailboat',
                        ),
                        CNChildLabel(
                          'Bicycle',
                          systemImage: 'bicycle',
                          tag: 'bicycle',
                        ),
                      ],
                      label: withLabels
                          ? [
                              CNChildText('Picker Style'),
                              CNChildText('Make a selection'),
                            ]
                          : null,
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
                const SizedBox(height: 16),
                if (geometry != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Window Position: ${geometry!.windowX}, ${geometry!.windowY}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Window Size: ${geometry!.windowWidth} x ${geometry!.windowHeight}',
                        ),
                        const SizedBox(height: 4),
                        Text('Widget Position: ${geometry!.x}, ${geometry!.y}'),
                        const SizedBox(height: 4),
                        Text(
                          'Widget Size: ${geometry!.width} x ${geometry!.height}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Widget Physical Position: ${geometry!.physicalX} x ${geometry!.physicalY}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Widget Physical Size: ${geometry!.physicalWidth} x ${geometry!.physicalHeight}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Widget Pixel Aligned Position: ${geometry!.pixelAlignedX} x ${geometry!.pixelAlignedY}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Widget Pixel Aligned Size: ${geometry!.pixelAlignedWidth} x ${geometry!.pixelAlignedHeight}',
                        ),
                      ],
                    ),
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
              'Picker Style': CNPicker(
                pickerStyle: CNPickerStyle.menu,
                children: [
                  CNChildLabel(
                    'automatic',
                    systemImage: 'automatic.brakesignal',
                    tag: CNPickerStyle.automatic.name,
                  ),
                  CNChildDivider(),
                  CNChildLabel(
                    'inline',
                    systemImage: 'lines.measurement.vertical',
                    tag: CNPickerStyle.inline.name,
                  ),
                  CNChildLabel(
                    'menu',
                    systemImage: 'filemenu.and.pointer.arrow',
                    tag: CNPickerStyle.menu.name,
                  ),
                  CNChildLabel(
                    'palette',
                    systemImage: 'swatchpalette',
                    tag: CNPickerStyle.palette.name,
                  ),
                  CNChildLabel(
                    'radioGroup',
                    systemImage: 'radio',
                    tag: CNPickerStyle.radioGroup.name,
                  ),
                  CNChildLabel(
                    'segmented',
                    systemImage: 'tablecells',
                    tag: CNPickerStyle.segmented.name,
                  ),
                ],
                selection: pickerStyle.name,
                onChanged: (value) {
                  setState(() {
                    pickerStyle = CNPickerStyle.values.firstWhere(
                      (e) => e.name == value,
                    );
                  });
                },
              ),
              'Tint Color': ColorPicker(
                colors: kSystemColors,
                value: tintColor,
                onChanged: (c) => setState(() => tintColor = c),
              ),
              'Foreground Color': ColorPicker(
                colors: kSystemColors,
                value: foregroundColor,
                onChanged: (c) => setState(() => foregroundColor = c),
              ),
              'Labels': CNToggle(
                isOn: withLabels,
                onChanged: (value) => setState(() => withLabels = value),
              ),
              'Enabled': CNToggle(
                isOn: isEnabled,
                onChanged: (value) => setState(() => isEnabled = value),
              ),
            },
          ),
        ],
      ),
    );
  }
}

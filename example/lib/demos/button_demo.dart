import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/pixel_perfect_probe.dart';
import 'package:flutter/cupertino.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  Color? iconColor;
  CNProgressViewStyle progressViewStyle = CNProgressViewStyle.linear;
  Color? tintColor;
  bool withIcon = false;
  bool withProgress = true;

  CNButtonStyle _buttonStyle = CNButtonStyle.automatic;
  CNControlSize _controlSize = CNControlSize.large;
  // ignore: unused_field
  String _last = 'None';

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: PixelPerfectProbe(
                        enforcePixelPerfectPosition: true,
                        child: CNButton(
                          onPressed: () => _set('Default'),
                          modifiers: CNViewModifiers(
                            shrinkWrap: false,
                            controlSize: _controlSize,
                            constraints: BoxConstraints(maxWidth: 300),
                            tint: tintColor,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          style: _buttonStyle,
                          children: [
                            if (withProgress)
                              CNProgressView(
                                progressViewStyle: progressViewStyle,
                                modifiers: CNViewModifiers(
                                  shrinkWrap: false,
                                  controlSize: CNControlSize.small,
                                  padding: EdgeInsets.only(right: 6),
                                  constraints: BoxConstraints(maxWidth: 30),
                                ),
                              ),
                            if (withIcon)
                              CNImage(
                                systemSymbolName: 'square.and.arrow.up.badge.checkmark',
                                modifiers: CNViewModifiers(padding: EdgeInsets.only(right: 6), foregroundColor: iconColor),
                              ),
                            CNText('Default'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            RightSideOptionContainer(
              options: {
                'Control Size': CNPicker(
                  selectedIndex: CNControlSize.values.indexOf(_controlSize),
                  onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                  items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Button Style': CNPicker(
                  selectedIndex: CNButtonStyle.values.indexOf(_buttonStyle),
                  onValueChanged: (index) => setState(() => _buttonStyle = CNButtonStyle.values[index]),
                  items: CNButtonStyle.values.map((size) => CNText(size.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: tintColor,
                  onValueChanged: (index) => setState(() => tintColor = kSystemColors.values.elementAt(index)),
                ),
                'With Icon': CNToggle(value: withIcon, onChanged: (value) => setState(() => withIcon = value)),
                'Icon Color': ColorPicker(
                  enabled: withIcon,
                  colors: kSystemColors,
                  currentValue: iconColor,
                  onValueChanged: (index) => setState(() => iconColor = kSystemColors.values.elementAt(index)),
                ),
                'With Progress': CNToggle(value: withProgress, onChanged: (value) => setState(() => withProgress = value)),
                'Progress Style': CNPicker(
                  selectedIndex: CNProgressViewStyle.values.indexOf(progressViewStyle),
                  onValueChanged: withProgress
                      ? (index) => setState(() => progressViewStyle = CNProgressViewStyle.values[index])
                      : null,
                  items: CNProgressViewStyle.values.map((style) => CNText(style.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                  modifiers: CNViewModifiers(enabled: withProgress),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

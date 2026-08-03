import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class MenuButtonDemoPage extends StatefulWidget {
  const MenuButtonDemoPage({super.key});

  @override
  State<MenuButtonDemoPage> createState() => _MenuButtonDemoPageState();
}

class _MenuButtonDemoPageState extends State<MenuButtonDemoPage> {
  CNControlSize controlSize = CNControlSize.large;
  bool isEnabled = true;
  String lastAction = 'None';
  CNMenuStyle menuStyle = CNMenuStyle.automatic;
  CupertinoDynamicColor? tintColor;
  bool usePrimaryAction = false;

  void setLastAction(String value) {
    setState(() {
      debugPrint('Pressed: $value');
      lastAction = value;
    });
  }

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
              children: [
                const SizedBox(height: 16),
                Text('Last Action: $lastAction', style: CNTheme.of(context).typography.title2),
                const SizedBox(height: 16),
                CNMenu(
                  debugLog: _kDebugLog,
                  items: [
                    CNChildButton(tag: 'open', title: 'Open in Preview', systemImage: 'star', badge: 2),
                    CNChildDivider(),
                    CNChildButton(tag: 'save', title: 'Save as PDF'),
                    CNChildMenu(
                      tag: 'editPrimary',
                      items: [
                        CNChildButton(tag: 'cut', title: 'Cut', systemImage: 'scissors'),
                        CNChildButton(tag: 'copy', title: 'Copy', systemImage: 'doc.on.doc'),
                        CNChildDivider(),
                        CNChildButton(tag: 'paste', title: 'Paste', systemImage: 'list.bullet.clipboard.fill', enabled: false),
                      ],
                      label: [CNChildLabel('Edit', systemImage: 'highlighter')],
                    ),
                  ],
                  label: [CNChildLabel('PDF', systemImage: 'doc.fill')],
                  primaryActionTag: usePrimaryAction ? 'pdfPrimary' : null,
                  onItemPressed: isEnabled ? (tag) => setLastAction(tag) : null,
                  menuStyle: menuStyle,
                  controlSize: controlSize,
                  tint: tintColor,
                ),
              ],
            ),
          ),
          RightSideOptionContainer(
            options: {
              'Control Size': ControlSizePicker(value: controlSize, onChanged: (size) => setState(() => controlSize = size)),
              'Menu Style': CNPicker(
                selection: menuStyle.name,
                onChanged: (value) => setState(() => menuStyle = CNMenuStyle.values.firstWhere((style) => style.name == value)),
                children: CNMenuStyle.values.map((style) => CNChildText(style.name, tag: style.name)).toList(),
              ),
              'Tint Color': ColorPicker(colors: kSystemColors, value: tintColor, onChanged: (c) => setState(() => tintColor = c)),
              'Enabled': CNToggle(isOn: isEnabled, onChanged: (value) => setState(() => isEnabled = value)),
              'Primary Action': CNToggle(isOn: usePrimaryAction, onChanged: (value) => setState(() => usePrimaryAction = value)),
            },
          ),
        ],
      ),
    );
  }
}

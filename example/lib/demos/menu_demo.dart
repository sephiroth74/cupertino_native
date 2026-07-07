import 'package:cupertino_native/components/divider.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

class MenuButtonDemoPage extends StatefulWidget {
  const MenuButtonDemoPage({super.key});

  @override
  State<MenuButtonDemoPage> createState() => _MenuButtonDemoPageState();
}

class _MenuButtonDemoPageState extends State<MenuButtonDemoPage> {
  CNControlSize _controlSize = CNControlSize.large;
  String _lastAction = 'None';
  CNMenuStyle _menuStyle = CNMenuStyle.automatic;
  CupertinoDynamicColor? _tintColor;

  void _setLastAction(String value) {
    setState(() {
      _lastAction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Menu Button')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Label button'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNMenu(
                      style: _menuStyle,
                      modifiers: CNViewModifiers(tint: _tintColor, controlSize: _controlSize),
                      labels: [
                        CNImage(systemSymbolName: 'star.fill'),
                        CNText('File'),
                      ],
                      onPrimaryAction: () => _setLastAction('Menu_0'),
                      children: [
                        CNButton(
                          children: [
                            CNImage(
                              systemSymbolName: 'star.fill',
                              modifiers: CNViewModifiers(tint: CupertinoColors.systemRed),
                              badge: 'uno',
                            ),
                            const CNText('Button 0'),
                          ],
                          onPressed: () => _setLastAction('Menu_0 -> Button_0'),
                        ),
                        const CNText('Button 0', badge: 2),
                        const CNDivider(),
                        CNButton(
                          badge: '3',
                          children: [
                            CNImage(
                              systemSymbolName: 'star.fill',
                              modifiers: CNViewModifiers(tint: CupertinoColors.systemYellow),
                            ),
                            CNText('Button 1'),
                          ],
                          onPressed: () => _setLastAction('Menu_0 -> Button_1'),
                        ),
                        CNButton(
                          badge: 5,
                          onPressed: () => _setLastAction('Menu_0 -> Button_2'),
                          children: [
                            CNImage(
                              systemSymbolName: 'star.fill',
                              modifiers: CNViewModifiers(tint: CupertinoColors.systemRed),
                            ),
                            CNText('Button 2'),
                          ],
                        ),
                        CNButton(
                          badge: '1',
                          onPressed: () => _setLastAction('Menu_0 -> Button_3'),
                          children: [
                            CNImage(systemSymbolName: 'star.fill'),
                            CNText('Button 3'),
                            CNText('Subtitle'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Icon menu'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNMenu(
                      style: _menuStyle,
                      onPrimaryAction: () => _setLastAction('Menu_1'),
                      modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                      labels: const [CNImage(systemSymbolName: 'ellipsis.circle')],
                      children: [
                        CNButton(
                          children: [
                            CNImage(systemSymbolName: 'gear'),
                            CNText('Settings'),
                          ],
                          onPressed: () => _setLastAction('Menu_1 -> Settings'),
                        ),
                        CNButton(
                          children: [
                            CNImage(systemSymbolName: 'info.circle'),
                            CNText('About'),
                          ],
                          onPressed: () => _setLastAction('Menu_1 -> About'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Label child'),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CNMenu(
                      style: _menuStyle,
                      onPrimaryAction: () => _setLastAction('Menu_2'),
                      modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                      labels: [
                        CNLabel(CNText(_lastAction), icon: CNImage(systemSymbolName: 'wand.and.stars'))
                      ],
                      children: [
                        CNButton(children: const [CNText('Action A')], onPressed: () => _setLastAction('Menu_2 -> Action_A')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Last action: $_lastAction', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                ],
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
                'Menu Style': CNPicker(
                  selectedIndex: CNMenuStyle.values.indexOf(_menuStyle),
                  onValueChanged: (index) => setState(() => _menuStyle = CNMenuStyle.values[index]),
                  items: CNMenuStyle.values.map((style) => CNText(style.name)).toList(),
                  pickerStyle: CNPickerStyle.automatic,
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: _tintColor,
                  onValueChanged: (index) => setState(() => _tintColor = kSystemColors.values.elementAt(index)),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cupertino_native/cupertino_native.dart';
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
  Color? _tintColor;

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
                      controlSize: _controlSize,
                      tint: _tintColor,
                      labels: const [
                        CNImage(systemSymbolName: 'star.fill'),
                        CNText('File'),
                      ],
                      onPrimaryAction: () => _setLastAction('Primary action pressed'),
                      children: [
                        CNButton(
                          children: [
                            const CNImage(systemSymbolName: 'star.fill', tint: CupertinoColors.systemRed, badge: 'uno'),
                            const CNText('Button 0'),
                          ],
                          onPressed: () => _setLastAction('Button 0'),
                        ),
                        const CNText('Button 0', badge: 2),
                        const CNDivider(),
                        CNButton(
                          badge: '3',
                          children: const [
                            CNImage(systemSymbolName: 'star.fill', tint: CupertinoColors.systemYellow),
                            CNText('Button 1'),
                          ],
                          onPressed: () => _setLastAction('Button 1'),
                        ),
                        CNButton(
                          badge: 5,
                          onPressed: () => _setLastAction('Button 2'),
                          children: const [
                            CNImage(systemSymbolName: 'star.fill', tint: CupertinoColors.systemRed),
                            CNText('Button 2'),
                          ],
                        ),
                        CNButton(
                          badge: '1',
                          onPressed: () => _setLastAction('Button 3'),
                          children: const [
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
                      controlSize: _controlSize,
                      tint: _tintColor,
                      labels: const [CNImage(systemSymbolName: 'ellipsis.circle')],
                      children: [
                        CNButton(
                          children: const [
                            CNImage(systemSymbolName: 'gear'),
                            CNText('Settings'),
                          ],
                          onPressed: () => _setLastAction('Settings'),
                        ),
                        CNButton(
                          children: const [
                            CNImage(systemSymbolName: 'info.circle'),
                            CNText('About'),
                          ],
                          onPressed: () => _setLastAction('About'),
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
                      controlSize: _controlSize,
                      tint: _tintColor,
                      labels: [CNLabel.text(_lastAction, icon: const CNImage(systemSymbolName: 'wand.and.stars'))],
                      children: [
                        CNButton(children: const [CNText('Action A')], onPressed: () => _setLastAction('Action A')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Last action: $_lastAction'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: BoxConstraints.expand(width: 350),
                decoration: BoxDecoration(
                  color: CNTheme.of(context).fillPrimaryColor,
                  border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: const Text('Control Size')),
                        CNPicker(
                          selectedIndex: CNControlSize.values.indexOf(_controlSize),
                          onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                          items: CNControlSize.values.map((size) => CNPickerItem(size.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Button Style')),
                        CNPicker(
                          selectedIndex: CNMenuStyle.values.indexOf(_menuStyle),
                          onValueChanged: (index) => setState(() => _menuStyle = CNMenuStyle.values[index]),
                          items: CNMenuStyle.values.map((style) => CNPickerItem(style.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Tint Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            _tintColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == _tintColor).key,
                          ),
                          onValueChanged: (index) => setState(() => _tintColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys
                              .map(
                                (colorName) =>
                                    CNPickerItem(colorName, icon: CNSymbol("circle.fill", color: kSystemColors[colorName])),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setLastAction(String value) {
    setState(() {
      _lastAction = value;
    });
  }
}

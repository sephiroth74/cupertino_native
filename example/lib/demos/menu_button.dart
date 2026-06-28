import 'package:cupertino_native/cupertino_native.dart';
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

  void _setLastAction(String value) {
    setState(() {
      _lastAction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final simpleMenu = CNMenu(
      items: [
        CNMenuItem(title: 'New', subtitle: 'Create a new file', systemImageName: 'doc.badge.plus'),
        CNMenuItem(title: 'Open', subtitle: 'Open an existing file', systemImageName: 'folder'),
        CNMenuItem.separator(),
        CNMenuItem(title: 'Close', subtitle: 'Close the current file', systemImageName: 'xmark'),
      ],
    );

    final nestedMenu = CNMenu(
      items: [
        CNMenuItem(
          title: 'View',
          subtitle: 'View options',
          submenu: CNMenu(
            items: [
              CNMenuItem(title: 'Zoom In', systemImageName: 'plus.magnifyingglass'),
              CNMenuItem(title: 'Zoom Out', systemImageName: 'minus.magnifyingglass'),
            ],
          ),
        ),
        CNMenuItem.separator(),
        CNMenuItem(title: 'Settings', systemImageName: 'gear'),
        CNMenuItem(title: 'About', systemImageName: 'info'),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Menu Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Label button'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CNMenuButton.label(
                buttonLabel: 'File',
                menu: simpleMenu,
                onSelected: (item) => _setLastAction('Selected: ${item.title}'),
                menuStyle: _menuStyle,
                controlSize: _controlSize,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Icon button'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CNMenuButton(
                buttonLabel: 'More',
                buttonIcon: const CNSymbol('scribble'),
                menu: nestedMenu,
                onSelected: (item) => _setLastAction('Selected: ${item.title}'),
                menuStyle: _menuStyle,
                controlSize: _controlSize,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Custom child'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CNMenuButton.label(
                buttonLabel: 'Custom',
                menu: simpleMenu,
                onSelected: (item) => _setLastAction('Selected: ${item.title}'),
                controlSize: _controlSize,
              ),
            ),
            const SizedBox(height: 24),
            Text('Last action: $_lastAction'),
          ],
        ),
      ),
    );
  }
}

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
        CNMenuItem(
          title: 'New',
          subtitle: 'Create a new file',
          image: CNImage(systemSymbolName: 'doc.badge.plus'),
        ),
        CNMenuItem(
          title: 'Open',
          subtitle: 'Open an existing file',
          image: CNImage(systemSymbolName: 'folder'),
        ),
        CNMenuItem.separator(),
        CNMenuItem(
          title: 'Close',
          subtitle: 'Close the current file',
          image: CNImage(systemSymbolName: 'xmark'),
        ),
      ],
    );

    final nestedMenu = CNMenu(
      items: [
        CNMenuItem(
          title: 'View',
          subtitle: 'View options',
          submenu: CNMenu(
            items: [
              CNMenuItem(
                title: 'Zoom In',
                image: CNImage(systemSymbolName: 'plus.magnifyingglass'),
              ),
              CNMenuItem(
                title: 'Zoom Out',
                image: CNImage(systemSymbolName: 'minus.magnifyingglass'),
              ),
            ],
          ),
        ),
        CNMenuItem.separator(),
        CNMenuItem(
          title: 'Settings',
          image: CNImage(systemSymbolName: 'gear'),
        ),
        CNMenuItem(
          title: 'About',
          image: CNImage(systemSymbolName: 'info'),
        ),
      ],
    );

    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Menu Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Label button'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: CNMenuButton(
                label: 'File',
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
                label: 'More',
                image: const CNImage(systemSymbolName: 'ellipsis.circle'),
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
              child: CNMenuButton(
                label: 'Custom',
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

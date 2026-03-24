import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ComboButtonDemoPage extends StatefulWidget {
  const ComboButtonDemoPage({super.key});

  @override
  State<ComboButtonDemoPage> createState() => _ComboButtonDemoPageState();
}

class _ComboButtonDemoPageState extends State<ComboButtonDemoPage> {
  String _lastAction = 'None';

  void _setLastAction(String value) {
    setState(() {
      _lastAction = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final splitMenu = CNMenu(
      items: [
        CNMenuItem(title: 'Open'),
        CNMenuItem(title: 'Open in New Window'),
        CNMenuItem.separator(),
        CNMenuItem(title: 'Reveal in Finder'),
      ],
    );

    final unifiedMenu = CNMenu(
      items: [
        CNMenuItem(
          title: 'Sort',
          submenu: CNMenu(
            items: [
              CNMenuItem(title: 'By Name'),
              CNMenuItem(title: 'By Date'),
            ],
          ),
        ),
        CNMenuItem.separator(),
        CNMenuItem(title: 'Rename'),
        CNMenuItem(title: 'Duplicate'),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Combo Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Split style'),
            const SizedBox(height: 12),
            CNComboButton(
              title: 'File',
              style: CNComboButtonStyle.split,
              image: const CNImage(systemSymbolName: 'doc'),
              menu: splitMenu,
              onPressed: (_) => _setLastAction('Split button pressed'),
              onMenuItemSelected: (item) => _setLastAction('Split menu: ${item.title}'),
            ),
            const SizedBox(height: 24),
            const Text('Unified style'),
            const SizedBox(height: 12),
            CNComboButton(
              title: 'Actions',
              style: CNComboButtonStyle.unified,
              image: const CNImage(systemSymbolName: 'ellipsis.circle'),
              controlSize: CNControlSize.large,
              menu: unifiedMenu,
              onPressed: (_) => _setLastAction('Unified button pressed'),
              onMenuItemSelected: (item) => _setLastAction('Unified menu: ${item.title}'),
            ),
            const SizedBox(height: 24),
            Text('Last action: $_lastAction'),
          ],
        ),
      ),
    );
  }
}

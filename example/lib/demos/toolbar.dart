import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ToolbarDemoPage extends StatefulWidget {
  const ToolbarDemoPage({super.key});

  @override
  State<ToolbarDemoPage> createState() => _ToolbarDemoPageState();
}

class _ToolbarDemoPageState extends State<ToolbarDemoPage> {
  String _lastPressed = 'No toolbar item pressed yet';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Toolbar')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Configure native window toolbar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(_lastPressed),
            const SizedBox(height: 16),
            CNButton(
              label: 'Set Primary Toolbar',
              style: CNButtonStyle.filled,
              onPressed: _setPrimaryToolbar,
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Set Compact Toolbar',
              style: CNButtonStyle.filled,
              onPressed: _setCompactToolbar,
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Clear Toolbar',
              style: CNButtonStyle.gray,
              onPressed: _clearToolbar,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPrimaryToolbar() async {
    await CNToolbar.setItems(
      identifier: 'primary_toolbar',
      displayMode: CNToolbarDisplayMode.iconAndLabel,
      sizeMode: CNToolbarSizeMode.regular,
      items: const [
        CNToolbarItem(
          id: 'new_note',
          label: 'New',
          systemSymbolName: 'square.and.pencil',
          toolTip: 'Create a new note',
        ),
        CNToolbarItem(
          id: 'refresh',
          label: 'Refresh',
          systemSymbolName: 'arrow.clockwise',
          toolTip: 'Reload content',
        ),
        CNToolbarItem(
          id: 'settings',
          label: 'Settings',
          systemSymbolName: 'gearshape',
          toolTip: 'Open settings',
        ),
      ],
      onItemPressed: _onToolbarItemPressed,
    );
  }

  Future<void> _setCompactToolbar() async {
    await CNToolbar.setItems(
      identifier: 'compact_toolbar',
      displayMode: CNToolbarDisplayMode.iconOnly,
      sizeMode: CNToolbarSizeMode.small,
      items: const [
        CNToolbarItem(
          id: 'back',
          label: 'Back',
          systemSymbolName: 'chevron.left',
        ),
        CNToolbarItem(
          id: 'forward',
          label: 'Forward',
          systemSymbolName: 'chevron.right',
        ),
        CNToolbarItem(
          id: 'share',
          label: 'Share',
          systemSymbolName: 'square.and.arrow.up',
        ),
      ],
      onItemPressed: _onToolbarItemPressed,
    );
  }

  Future<void> _clearToolbar() async {
    await CNToolbar.clear();
    if (!mounted) {
      return;
    }
    setState(() {
      _lastPressed = 'Toolbar cleared';
    });
  }

  void _onToolbarItemPressed(String id) {
    if (!mounted) {
      return;
    }
    setState(() {
      _lastPressed = 'Pressed: $id';
    });
  }
}

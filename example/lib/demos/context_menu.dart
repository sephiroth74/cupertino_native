import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ContextMenuDemoPage extends StatefulWidget {
  const ContextMenuDemoPage({super.key});

  @override
  State<ContextMenuDemoPage> createState() => _ContextMenuDemoPageState();
}

class _ContextMenuDemoPageState extends State<ContextMenuDemoPage> {
  String _lastSelection = 'None';

  CNMenu _buildMenu() {
    return CNMenu(
      items: [
        CNMenuItem(
          title: 'Open',
          image: const CNImage(systemSymbolName: 'folder'),
        ),
        CNMenuItem(
          title: 'Rename',
          image: const CNImage(systemSymbolName: 'pencil'),
        ),
        CNMenuItem.separator(),
        CNMenuItem(
          title: 'Share',
          image: const CNImage(systemSymbolName: 'square.and.arrow.up'),
          submenu: CNMenu(
            items: [
              CNMenuItem(
                title: 'Copy Link',
                image: const CNImage(systemSymbolName: 'link'),
              ),
              CNMenuItem(
                title: 'Send via Mail',
                image: const CNImage(systemSymbolName: 'envelope'),
              ),
              CNMenuItem.separator(),
              CNMenuItem(title: 'Export…'),
            ],
          ),
        ),
        CNMenuItem.separator(),
        CNMenuItem(
          title: 'Delete',
          image: CNImage(systemSymbolName: 'trash', symbolConfiguration: CNSymbolConfiguration.hierarchical(CupertinoColors.systemRed)),
        ),
      ],
    );
  }

  CNMenu _buildMultiLevelNoIconsMenu() {
    return CNMenu(
      items: [
        CNMenuItem(
          title: 'File',
          submenu: CNMenu(
            items: [
              CNMenuItem(title: 'New'),
              CNMenuItem(title: 'Open…'),
              CNMenuItem.separator(),
              CNMenuItem(
                title: 'Recent',
                submenu: CNMenu(
                  items: [
                    CNMenuItem(title: 'Project Alpha'),
                    CNMenuItem(title: 'Project Beta'),
                    CNMenuItem(
                      title: 'Archived',
                      submenu: CNMenu(
                        items: [
                          CNMenuItem(title: '2023'),
                          CNMenuItem(title: '2024'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CNMenuItem(
          title: 'Edit',
          submenu: CNMenu(
            items: [
              CNMenuItem(title: 'Undo'),
              CNMenuItem(title: 'Redo'),
              CNMenuItem.separator(),
              CNMenuItem(title: 'Cut'),
              CNMenuItem(title: 'Copy'),
              CNMenuItem(title: 'Paste'),
            ],
          ),
        ),
        CNMenuItem.separator(),
        CNMenuItem(title: 'Close'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = _buildMenu();
    final noIconsMenu = _buildMultiLevelNoIconsMenu();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Context Menu')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Right-click inside the card to open the native context menu.'),
            const SizedBox(height: 12),
            CNContextMenuRegion(
              menu: menu,
              onMenuItemSelected: (item) {
                setState(() => _lastSelection = item.title);
              },
              onCanceled: () {
                setState(() => _lastSelection = 'Canceled');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: CupertinoColors.secondarySystemGroupedBackground, borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Project Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Use secondary click to open actions.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Multi-level menu (no icons)'),
            const SizedBox(height: 12),
            CNContextMenuRegion(
              menu: noIconsMenu,
              onMenuItemSelected: (item) {
                setState(() => _lastSelection = item.title);
              },
              onCanceled: () {
                setState(() => _lastSelection = 'Canceled');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: CupertinoColors.tertiarySystemGroupedBackground, borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Editor Area', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('Right-click to test a multi-level context menu without icons.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Last selection: $_lastSelection'),
          ],
        ),
      ),
    );
  }
}

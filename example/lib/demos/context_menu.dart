import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ContextMenuDemoPage extends StatefulWidget {
  const ContextMenuDemoPage({super.key});

  @override
  State<ContextMenuDemoPage> createState() => _ContextMenuDemoPageState();
}

class _ContextMenuDemoPageState extends State<ContextMenuDemoPage> {
  String _lastSelection = 'None';

  CNMenuModel _buildMenu() {
    return CNMenuModel(
      items: [
        CNMenuModelItem(
          title: 'Open',
          image: const CNImage(systemSymbolName: 'folder'),
        ),
        CNMenuModelItem(
          title: 'Rename',
          image: const CNImage(systemSymbolName: 'pencil'),
        ),
        CNMenuModelItem.separator(),
        CNMenuModelItem(
          title: 'Share',
          image: const CNImage(systemSymbolName: 'square.and.arrow.up'),
          submenu: CNMenuModel(
            items: [
              CNMenuModelItem(
                title: 'Copy Link',
                image: const CNImage(systemSymbolName: 'link'),
              ),
              CNMenuModelItem(
                title: 'Send via Mail',
                image: const CNImage(systemSymbolName: 'envelope'),
              ),
              CNMenuModelItem.separator(),
              CNMenuModelItem(title: 'Export…'),
            ],
          ),
        ),
        CNMenuModelItem.separator(),
        CNMenuModelItem(
          title: 'Delete',
          image: CNImage(
            systemSymbolName: 'trash',
            symbolRenderingMode: CNSymbolRenderingMode.hierarchical,
            foregroundStyleColors: const [CupertinoColors.systemRed],
          ),
        ),
      ],
    );
  }

  CNMenuModel _buildMultiLevelNoIconsMenu() {
    return CNMenuModel(
      items: [
        CNMenuModelItem(
          title: 'File',
          submenu: CNMenuModel(
            items: [
              CNMenuModelItem(title: 'New'),
              CNMenuModelItem(title: 'Open…'),
              CNMenuModelItem.separator(),
              CNMenuModelItem(
                title: 'Recent',
                submenu: CNMenuModel(
                  items: [
                    CNMenuModelItem(title: 'Project Alpha'),
                    CNMenuModelItem(title: 'Project Beta'),
                    CNMenuModelItem(
                      title: 'Archived',
                      submenu: CNMenuModel(
                        items: [
                          CNMenuModelItem(title: '2023'),
                          CNMenuModelItem(title: '2024'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        CNMenuModelItem(
          title: 'Edit',
          submenu: CNMenuModel(
            items: [
              CNMenuModelItem(title: 'Undo'),
              CNMenuModelItem(title: 'Redo'),
              CNMenuModelItem.separator(),
              CNMenuModelItem(title: 'Cut'),
              CNMenuModelItem(title: 'Copy'),
              CNMenuModelItem(title: 'Paste'),
            ],
          ),
        ),
        CNMenuModelItem.separator(),
        CNMenuModelItem(title: 'Close'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = _buildMenu();
    final noIconsMenu = _buildMultiLevelNoIconsMenu();

    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Context Menu')),
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
                decoration: BoxDecoration(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
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

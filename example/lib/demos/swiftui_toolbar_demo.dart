import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/components/toolbar/toolbar.dart';
import 'package:flutter/cupertino.dart';

class SwiftUIToolbarDemo extends StatefulWidget {
  const SwiftUIToolbarDemo({Key? key}) : super(key: key);

  @override
  State<SwiftUIToolbarDemo> createState() => _SwiftUIToolbarDemoState();
}

class _SwiftUIToolbarDemoState extends State<SwiftUIToolbarDemo> {
  String? _lastAction;
  String? _searchQuery;

  @override
  void dispose() {
    CNToolbar.remove();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupToolbar();
    });
  }

  Future<void> _setupToolbar() async {
    try {
      await CNToolbar.create(
        context: context,
        title: 'Mail',
        showSearch: true,
        groups: [
          // Group on the left (navigation placement)
          CNToolbarGroup(
            id: 'nav',
            placement: CNToolbarItemPlacement.navigation,
            items: [
              CNToolbarButtonItem(
                id: 'back',
                systemSymbolName: 'chevron.left',
                onPressed: () {
                  setState(() {
                    _lastAction = 'Action: back';
                  });
                },
              ),
            ],
          ),
          // Group in the middle (principal placement)
          CNToolbarGroup(
            id: 'principal',
            placement: CNToolbarItemPlacement.principal,
            items: [
              CNToolbarButtonItem(
                id: 'home',
                label: 'Home',
                systemSymbolName: 'house',
                onPressed: () {
                  setState(() {
                    _lastAction = 'Action: home';
                  });
                },
              ),
            ],
          ),
          // Grouped items on the right (status placement)
          CNToolbarGroup(
            id: 'actions',
            placement: CNToolbarItemPlacement.status,
            items: [
              CNToolbarButtonItem(
                id: 'compose',
                systemSymbolName: 'square.and.pencil',
                onPressed: () {
                  setState(() {
                    _lastAction = 'Action: compose';
                  });
                },
              ),
              CNToolbarButtonItem(
                id: 'flag',
                systemSymbolName: 'flag',
                onPressed: () {
                  setState(() {
                    _lastAction = 'Action: flag';
                  });
                },
              ),
              CNToolbarButtonItem(
                id: 'delete',
                systemSymbolName: 'trash',
                onPressed: () {
                  setState(() {
                    _lastAction = 'Action: delete';
                  });
                },
              ),
            ],
          ),
        ],
      );

      // Register search callbacks
      CNToolbar.onSearchChanged((query) {
        setState(() {
          _searchQuery = query;
        });
      });

      CNToolbar.onSearchSubmitted((query) {
        setState(() {
          _lastAction = 'Action: search submitted with "$query"';
          _searchQuery = query;
        });
      });
    } catch (e) {
      debugPrint('Error setting up toolbar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(onPressed: () => Navigator.of(context).pop()),
        middle: const Text('Toolbar Demo'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Toolbar Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('Last Action: ${_lastAction ?? 'None'}', style: const TextStyle(fontSize: 14)),
                      if (_searchQuery != null && _searchQuery!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Search Query: "$_searchQuery"', style: const TextStyle(fontSize: 14)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('How to use', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        '• Click toolbar buttons (Compose, Flag, Delete) to trigger actions\n'
                        '• Use the search field to search emails\n'
                        '• Badge numbers show unread counts\n'
                        '• All actions are reflected in the status above',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        '✓ Native macOS 26 SwiftUI toolbar\n'
                        '✓ Toolbar buttons with SF Symbols\n'
                        '✓ Searchable field\n'
                        '✓ Event streaming to Flutter\n'
                        '✓ Platform channel integration',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

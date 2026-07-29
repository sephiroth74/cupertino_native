import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContextMenuDemoPage extends StatefulWidget {
  const ContextMenuDemoPage({super.key});

  @override
  State<ContextMenuDemoPage> createState() => _ContextMenuDemoPageState();
}

class _ContextMenuDemoPageState extends State<ContextMenuDemoPage> {
  String _lastSelection = 'None';

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Context Menu')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Right-click inside the card to open the native context menu.'),
            const SizedBox(height: 16),
            CNContextMenuRegion(
              onItemPressed: (value) {
                setState(() => _lastSelection = value);
              },
              items: [
                CNChildButton(title: 'Open', tag: 'Open', systemImage: 'folder'),
                CNChildButton(title: 'Rename', tag: 'Rename', systemImage: 'square.and.pencil'),
                CNChildDivider(),
                CNChildMenu.simple(
                  'Share',
                  tag: 'Share',
                  items: [
                    CNChildButton(title: 'Copy Link', tag: 'Copy Link'),
                    CNChildButton(title: 'Send via Mail', tag: 'Send via Mail'),
                    CNChildDivider(),
                    CNChildButton(title: 'Export…', tag: 'Export…', enabled: false),
                  ],
                ),
                CNChildDivider(),
                CNChildButton(title: 'Delete', tag: 'Delete'),
              ],

              onCanceled: () {
                setState(() => _lastSelection = 'Canceled');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CNColors.fillTertiary,
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
            TextButton(
              onPressed: () => setState(() => _lastSelection = 'None'),
              child: const Text('Reset Last Selection'),
            ),
            Text('Last selection: $_lastSelection'),
          ],
        ),
      ),
    );
  }
}

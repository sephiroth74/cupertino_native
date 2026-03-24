import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class PopoverDemoPage extends StatefulWidget {
  const PopoverDemoPage({super.key});

  @override
  State<PopoverDemoPage> createState() => _PopoverDemoPageState();
}

class _PopoverDemoPageState extends State<PopoverDemoPage> {
  int? _lastSelectedIndex;

  List<CNPopoverAction> get _actions => const [
    CNPopoverAction(label: 'Open', isDefault: true),
    CNPopoverAction(label: 'Duplicate'),
    CNPopoverAction(label: 'Delete', isDestructive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Popover')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('Text button'),
                const Spacer(),
                CNPopoverButton.label(
                  buttonLabel: 'Details',
                  title: 'Project Actions',
                  message: 'Choose what to do with the current project item.',
                  actions: _actions,
                  onSelected: (index) => setState(() => _lastSelectedIndex = index),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Icon button'),
                const Spacer(),
                CNPopoverButton.icon(
                  buttonIcon: const CNSymbol('info.circle', size: 18),
                  title: 'About This Item',
                  message: 'This popover is anchored to a round icon button and uses native AppKit presentation.',
                  actions: const [CNPopoverAction(label: 'Close', isDefault: true)],
                  onSelected: (index) => setState(() => _lastSelectedIndex = index),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Custom child'),
                const Spacer(),
                CNPopoverButton(
                  title: 'Invite Collaborators',
                  message: 'Share this workspace with your team members, then configure edit permissions from settings.',
                  actions: const [
                    CNPopoverAction(label: 'Share', isDefault: true),
                    CNPopoverAction(label: 'Later'),
                  ],
                  preferredEdge: CNPopoverEdge.right,
                  onSelected: (index) => setState(() => _lastSelectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: CupertinoColors.systemBlue, borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.person_2_fill, color: CupertinoColors.white),
                        SizedBox(width: 8),
                        Text('Invite', style: TextStyle(color: CupertinoColors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Last selected action index: ${_lastSelectedIndex ?? '-'}'),
          ],
        ),
      ),
    );
  }
}

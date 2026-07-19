import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class SheetDemoPage extends StatefulWidget {
  const SheetDemoPage({super.key});

  @override
  State<SheetDemoPage> createState() => _SheetDemoPageState();
}

class _SheetDemoPageState extends State<SheetDemoPage> {
  CNAlertResult? _lastSelected;

  Widget _buildSheetButton({required String title, required CNAlertStyle2 style, required String message}) {
    return CNButton2(
      children: [CNChildText(title)],
      onPressed: () => _showSimpleSheet(title: title, style: style, message: message),
    );
  }

  Future<void> _showSimpleSheet({required String title, required CNAlertStyle2 style, required String message}) async {
    final selected = await CNAlert2.showSheet(
      context,
      title: title,
      message: message,
      style: style,
      actions: const [CNChildButton(title: 'OK', tag: 'ok')],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSelected = selected;
    });
  }

  Future<void> _showCustomActionsSheet() async {
    final selected = await CNAlert2.showSheet(
      context,
      title: 'Document Actions',
      message: 'Choose what to do with the selected document.',
      style: CNAlertStyle2.warning,
      actions: const [
        CNChildButton(title: 'Open', tag: 'open'),
        CNChildButton(title: 'Duplicate', tag: 'duplicate'),
        CNChildButton(title: 'Delete', tag: 'delete', role: CNButtonRole2.destructive),
      ],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSelected = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Sheet')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Last Selection', style: CupertinoTheme.of(context).textTheme.navTitleTextStyle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(8)),
              child: Text(
                _lastSelected == null ? 'No sheet opened yet' : 'Selected action index: $_lastSelected',
                style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
              ),
            ),
            const SizedBox(height: 32),
            _buildSheetButton(
              title: 'Informational Sheet',
              style: CNAlertStyle2.informational,
              message: 'This is a standard informational native sheet.',
            ),
            const SizedBox(height: 16),
            _buildSheetButton(
              title: 'Warning Sheet',
              style: CNAlertStyle2.warning,
              message: 'This action may change project state permanently.',
            ),
            const SizedBox(height: 16),
            _buildSheetButton(
              title: 'Critical Sheet',
              style: CNAlertStyle2.critical,
              message: 'Deleting this item cannot be undone.',
            ),
            const SizedBox(height: 16),
            CNButton(onPressed: _showCustomActionsSheet, children: const [CNText('Sheet With Multiple Actions')]),
          ],
        ),
      ),
    );
  }
}

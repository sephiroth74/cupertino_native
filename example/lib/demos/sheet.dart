import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class SheetDemoPage extends StatefulWidget {
  const SheetDemoPage({super.key});

  @override
  State<SheetDemoPage> createState() => _SheetDemoPageState();
}

class _SheetDemoPageState extends State<SheetDemoPage> {
  int? _lastSelectedIndex;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Sheet')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Last Selection',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _lastSelectedIndex == null
                    ? 'No sheet opened yet'
                    : 'Selected action index: $_lastSelectedIndex',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSheetButton(
              title: 'Informational Sheet',
              style: CNSheetStyle.informational,
              message: 'This is a standard informational native sheet.',
            ),
            const SizedBox(height: 16),
            _buildSheetButton(
              title: 'Warning Sheet',
              style: CNSheetStyle.warning,
              message: 'This action may change project state permanently.',
            ),
            const SizedBox(height: 16),
            _buildSheetButton(
              title: 'Critical Sheet',
              style: CNSheetStyle.critical,
              message: 'Deleting this item cannot be undone.',
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: _showCustomActionsSheet,
              child: const Text('Sheet With Multiple Actions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetButton({
    required String title,
    required CNSheetStyle style,
    required String message,
  }) {
    return CupertinoButton.filled(
      onPressed: () =>
          _showSimpleSheet(title: title, style: style, message: message),
      child: Text(title),
    );
  }

  Future<void> _showSimpleSheet({
    required String title,
    required CNSheetStyle style,
    required String message,
  }) async {
    final selected = await CNSheet.show(
      context,
      title: title,
      message: message,
      style: style,
      actions: const [CNSheetAction('OK', isDefault: true)],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSelectedIndex = selected;
    });
  }

  Future<void> _showCustomActionsSheet() async {
    final selected = await CNSheet.show(
      context,
      title: 'Document Actions',
      message: 'Choose what to do with the selected document.',
      style: CNSheetStyle.warning,
      actions: const [
        CNSheetAction('Save', isDefault: true),
        CNSheetAction('Duplicate'),
        CNSheetAction('Delete', isDestructive: true),
      ],
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _lastSelectedIndex = selected;
    });
  }
}

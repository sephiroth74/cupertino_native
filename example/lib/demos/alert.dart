import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class AlertDemoPage extends StatefulWidget {
  const AlertDemoPage({super.key});

  @override
  State<AlertDemoPage> createState() => _AlertDemoPageState();
}

class _AlertDemoPageState extends State<AlertDemoPage> {
  int? _lastSelectedIndex;

  Future<void> _showInfoAlert() async {
    await CNAlert.show(
      context,
      title: 'Saved',
      message: 'Your changes have been saved successfully.',
      actions: const [CNAlertAction('OK', isDefault: true)],
      style: CNAlertStyle.informational,
      onSelected: (index) => setState(() => _lastSelectedIndex = index),
    );
  }

  Future<void> _showConfirmAlert() async {
    await CNAlert.show(
      context,
      title: 'Delete File',
      message: 'This action cannot be undone.',
      actions: const [
        CNAlertAction('Cancel', isDefault: false),
        CNAlertAction('Ok', isDefault: true),
        CNAlertAction('Delete', isDestructive: true),
      ],
      style: CNAlertStyle.warning,
      onSelected: (index) => setState(() => _lastSelectedIndex = index),
    );
  }

  Future<void> _showCriticalAlert() async {
    await CNAlert.show(
      context,
      title: 'Critical Error',
      message: 'The operation failed due to a critical system condition.',
      actions: const [CNAlertAction('Dismiss', isDefault: true)],
      style: CNAlertStyle.critical,
      onSelected: (index) => setState(() => _lastSelectedIndex = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Alert')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CNButton(
              label: 'Show Informational Alert',
              onPressed: _showInfoAlert,
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Show Confirm Alert',
              onPressed: _showConfirmAlert,
              style: CNButtonStyle.tinted,
            ),
            const SizedBox(height: 12),
            CNButton(
              label: 'Show Critical Alert',
              onPressed: _showCriticalAlert,
              style: CNButtonStyle.borderedProminent,
            ),
            const SizedBox(height: 16),
            Text('Last selected button index: ${_lastSelectedIndex ?? '-'}'),
          ],
        ),
      ),
    );
  }
}

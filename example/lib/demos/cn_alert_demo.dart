import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class AlertDemoPage extends StatefulWidget {
  const AlertDemoPage({super.key});

  @override
  State<AlertDemoPage> createState() => _AlertDemoPageState();
}

class _AlertDemoPageState extends State<AlertDemoPage> {
  CNAlertResult? _lastResult;

  Future<void> _showInfoAlert() async {
    final result = await CNAlert2.show(
      context,
      title: 'Saved',
      message: 'Your changes have been saved successfully.',
      actions: const [CNChildButton(tag: 'ok', title: 'OK')],
      style: CNAlertStyle2.informational,
      suppressionButtonLabel: 'Do not show this again',
    );
    if (result != null) setState(() => _lastResult = result);
  }

  Future<void> _showConfirmAlert() async {
    final result = await CNAlert2.show(
      context,
      title: 'Delete File',
      message: 'This action cannot be undone.',
      actions: const [
        CNChildButton(tag: 'ok', title: 'Ok'),
        CNChildButton(tag: 'cancel', title: 'Cancel', role: CNButtonRole2.cancel),
        CNChildButton(tag: 'delete', title: 'Delete', role: CNButtonRole2.destructive),
      ],
      style: CNAlertStyle2.warning,
    );
    if (result != null) setState(() => _lastResult = result);
  }

  Future<void> _showCriticalAlert() async {
    final result = await CNAlert2.show(
      context,
      title: 'Critical Error',
      message: 'The operation failed due to a critical system condition.',
      actions: const [CNChildButton(tag: 'dismiss', title: 'Dismiss')],
      style: CNAlertStyle2.critical,
    );
    if (result != null) setState(() => _lastResult = result);
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Alert')),
      child: CNContentArea(
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              CNButton2(
                onPressed: _showInfoAlert,
                shrink: true,
                controlSize: CNControlSize.large,
                children: [
                  CNChildLabel(
                    'Show Info Alert',
                    systemImage: 'info.triangle',
                    constraints: BoxConstraints.tightFor(width: 250),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CNButton2(
                shrink: true,
                controlSize: CNControlSize.large,
                onPressed: _showConfirmAlert,
                children: [
                  CNChildLabel(
                    'Show Confirm Alert',
                    systemImage: 'questionmark.circle',
                    constraints: BoxConstraints.tightFor(width: 250),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CNButton2(
                debugLog: false,
                shrink: true,
                controlSize: CNControlSize.large,
                onPressed: _showCriticalAlert,
                children: [
                  CNChildLabel(
                    'Show Critical Alert',
                    systemImage: 'exclamationmark.triangle',
                    constraints: BoxConstraints.tightFor(width: 250),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_lastResult != null) ...[
                Text('Selected index: ${_lastResult!.selectedIndex}'),
                const SizedBox(height: 4),
                Text('Selected tag: ${_lastResult!.selectedTag ?? '-'}'),
                const SizedBox(height: 4),
                Text('Suppression selected: ${_lastResult!.suppressionSelected}'),
              ],
            ],
          );
        }
      ),
    );
  }
}

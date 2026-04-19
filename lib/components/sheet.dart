import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Visual style for a native macOS sheet.
enum CNSheetStyle {
  /// Informational style.
  informational,

  /// Warning style.
  warning,

  /// Critical style.
  critical,
}

/// Action button for [CNSheet.show].
class CNSheetAction {
  /// Creates a sheet action.
  const CNSheetAction(
    this.title, {
    this.isDefault = false,
    this.isDestructive = false,
  });

  /// Button title.
  final String title;

  /// Whether this is the default action.
  final bool isDefault;

  /// Whether this is a destructive action.
  final bool isDestructive;

  /// Serializes this action for method-channel transport.
  Map<String, dynamic> toMap() => {
    'title': title,
    'isDefault': isDefault,
    'isDestructive': isDestructive,
  };
}

/// Utility API to show native macOS sheets.
class CNSheet {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  /// Shows a native macOS sheet and returns the selected action index.
  ///
  /// On non-macOS platforms this falls back to [CupertinoActionSheet].
  static Future<int?> show(
    BuildContext context, {
    String? title,
    required String message,
    List<CNSheetAction> actions = const [CNSheetAction('OK', isDefault: true)],
    CNSheetStyle style = CNSheetStyle.informational,
    ValueChanged<int>? onSelected,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('actions must not be empty.');
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final selected = await _channel.invokeMethod<int>('showSheet', {
        'title': title,
        'message': message,
        'style': style.name,
        'actions': actions.map((a) => a.toMap()).toList(),
      });

      if (selected != null) {
        onSelected?.call(selected);
      }
      return selected;
    }

    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: Text(message),
        actions: [
          for (var i = 0; i < actions.length; i++)
            CupertinoActionSheetAction(
              isDefaultAction: actions[i].isDefault,
              isDestructiveAction: actions[i].isDestructive,
              onPressed: () => Navigator.of(ctx).pop(i),
              child: Text(actions[i].title),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (selected != null) {
      onSelected?.call(selected);
    }
    return selected;
  }
}

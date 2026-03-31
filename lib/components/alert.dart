import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Visual style for a native macOS alert.
enum CNAlertStyle {
  /// Informational style.
  informational,

  /// Warning style.
  warning,

  /// Critical style.
  critical,
}

/// Action button for [CNAlert.show].
class CNAlertAction {
  /// Creates an alert action.
  const CNAlertAction(
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

/// Utility API to show native alerts.
class CNAlert {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  /// Shows a native macOS [NSAlert] and returns the selected action index.
  ///
  /// On non-macOS platforms this falls back to [CupertinoAlertDialog].
  static Future<int?> show(
    BuildContext context, {
    String? title,
    required String message,
    List<CNAlertAction> actions = const [CNAlertAction('OK', isDefault: true)],
    CNAlertStyle style = CNAlertStyle.informational,
    ValueChanged<int>? onSelected,
    String? suppressionButtonLabel,
    bool suppressionInitiallySelected = false,
    ValueChanged<bool>? onSuppressionChanged,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('actions must not be empty.');
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final response = await _channel.invokeMethod<Object>('showAlert', {
        'title': title,
        'message': message,
        'style': style.name,
        'actions': actions.map((a) => a.toMap()).toList(),
        'suppressionButtonLabel': suppressionButtonLabel,
        'suppressionInitiallySelected': suppressionInitiallySelected,
      });
      final resultMap = response is Map
          ? Map<Object?, Object?>.from(response)
          : const <Object?, Object?>{};
      final selected = (resultMap['selectedIndex'] as num?)?.toInt();
      final suppressionSelected = resultMap['suppressionSelected'] as bool?;
      if (selected != null) {
        onSelected?.call(selected);
      }
      if (suppressionSelected != null) {
        onSuppressionChanged?.call(suppressionSelected);
      }
      return selected;
    }

    final selected = await showCupertinoDialog<int>(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: title == null ? null : Text(title),
          content: Text(message),
          actions: [
            for (var i = 0; i < actions.length; i++)
              CupertinoDialogAction(
                isDefaultAction: actions[i].isDefault,
                isDestructiveAction: actions[i].isDestructive,
                onPressed: () => Navigator.of(ctx).pop(i),
                child: Text(actions[i].title),
              ),
          ],
        );
      },
    );
    if (selected != null) {
      onSelected?.call(selected);
    }
    if (suppressionButtonLabel != null) {
      onSuppressionChanged?.call(false);
    }
    return selected;
  }
}

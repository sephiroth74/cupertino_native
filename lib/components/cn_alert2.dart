// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cn_button.dart';
import 'cn_child.dart';

/// Visual style for a native macOS alert.
enum CNAlertStyle2 {
  informational,
  warning,
  critical,
}

/// Result returned by [CNAlert2.show].
class CNAlertResult {
  const CNAlertResult({required this.selectedIndex, this.selectedTag, this.suppressionSelected = false});

  final int selectedIndex;
  final String? selectedTag;
  final bool suppressionSelected;
}

/// Utility API to show native macOS alerts using NSAlert.
///
/// Actions are [CNChildButton] items. The first action becomes the default
/// (Return key). A button with [CNButtonRole2.cancel] gets the Escape key
/// equivalent. A button with [CNButtonRole2.destructive] renders with
/// destructive styling.
class CNAlert2 {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  static Future<CNAlertResult?> show(
    BuildContext context, {
    String? title,
    required String message,
    required List<CNChildButton> actions,
    CNAlertStyle2 style = CNAlertStyle2.informational,
    String? suppressionButtonLabel,
    bool suppressionInitiallySelected = false,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('actions must not be empty.');
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final response = await _channel.invokeMethod<Object>('showAlert2', {
        'title': title,
        'message': message,
        'style': style.name,
        'actions': actions.map((a) => a.toChildPayload(context)).toList(),
        'suppressionButtonLabel': suppressionButtonLabel,
        'suppressionInitiallySelected': suppressionInitiallySelected,
      });
      final resultMap = response is Map ? Map<Object?, Object?>.from(response) : const <Object?, Object?>{};
      final selectedIndex = (resultMap['selectedIndex'] as num?)?.toInt();
      if (selectedIndex == null) return null;

      return CNAlertResult(
        selectedIndex: selectedIndex,
        selectedTag: resultMap['selectedTag'] as String?,
        suppressionSelected: (resultMap['suppressionSelected'] as bool?) ?? false,
      );
    }

    // Non-macOS fallback
    final selected = await showCupertinoDialog<int>(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: title == null ? null : Text(title),
          content: Text(message),
          actions: [
            for (var i = 0; i < actions.length; i++)
              CupertinoDialogAction(
                isDefaultAction: i == 0,
                isDestructiveAction: actions[i].role == CNButtonRole2.destructive,
                onPressed: () => Navigator.of(ctx).pop(i),
                child: Text(actions[i].title),
              ),
          ],
        );
      },
    );
    if (selected == null) return null;

    return CNAlertResult(
      selectedIndex: selected,
      selectedTag: actions[selected].tag,
      suppressionSelected: false,
    );
  }
}

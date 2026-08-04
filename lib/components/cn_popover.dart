// ignore_for_file: public_member_api_docs

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cn_button.dart';
import 'cn_child.dart';

/// Utility API to show native macOS popovers anchored to any widget.
///
/// Call [show] from an `onPressed` callback, passing the [BuildContext] of
/// the widget that should serve as the anchor.
class CNPopover {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  static Future<CNPopoverResult?> show(
    BuildContext context, {
    String? title,
    String? message,
    required List<CNChildButton> actions,
    CNPopoverBehavior behavior = CNPopoverBehavior.transient,
    CNPopoverEdge preferredEdge = CNPopoverEdge.bottom,
    double popoverWidth = 280,
  }) async {
    if (actions.isEmpty) {
      throw ArgumentError('actions must not be empty.');
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;

      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      debugPrint('CNPopover2.show: anchor position=$position, size=$size');

      final response = await _channel.invokeMethod<Object>('showPopover2', {
        'title': title,
        'message': message,
        'actions': actions.map((a) => a.toChildPayload(context)).toList(),
        'behavior': behavior.name,
        'preferredEdge': preferredEdge.name,
        'popoverWidth': popoverWidth,
        'anchorX': position.dx,
        'anchorY': position.dy,
        'anchorWidth': size.width,
        'anchorHeight': size.height,
      });

      final resultMap = response is Map
          ? Map<Object?, Object?>.from(response)
          : const <Object?, Object?>{};
      final selectedIndex = (resultMap['selectedIndex'] as num?)?.toInt();
      if (selectedIndex == null) return null;

      return CNPopoverResult(
        selectedIndex: selectedIndex,
        selectedTag: resultMap['selectedTag'] as String?,
      );
    }

    // Non-macOS fallback
    final selected = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: title == null ? null : Text(title),
        message: message == null ? null : Text(message),
        actions: [
          for (var i = 0; i < actions.length; i++)
            CupertinoActionSheetAction(
              isDefaultAction: i == 0,
              isDestructiveAction: actions[i].role == CNButtonRole.destructive,
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
    if (selected == null) return null;

    return CNPopoverResult(
      selectedIndex: selected,
      selectedTag: actions[selected].tag,
    );
  }
}

/// Popover behavior.
enum CNPopoverBehavior { transient, semitransient, applicationDefined }

/// Preferred edge for popover anchor.
enum CNPopoverEdge { top, bottom, leading, trailing }

/// Result returned by [CNPopover.show].
class CNPopoverResult {
  const CNPopoverResult({required this.selectedIndex, this.selectedTag});

  final int selectedIndex;
  final String? selectedTag;
}

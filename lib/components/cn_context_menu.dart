// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A widget that shows a native context menu on secondary click.
///
/// The menu is built from [items] which can be [CNChildButton],
/// [CNChildDivider], or [CNChildMenu] (for sub-menus).
/// When a button is pressed, [onItemPressed] is called with its [CNChild.tag].
class CNContextMenuRegion extends StatefulWidget {
  const CNContextMenuRegion({
    super.key,
    required this.child,
    required this.items,
    this.onItemPressed,
    this.onCanceled,
    this.enabled = true,
  });

  /// The widget that acts as the trigger region.
  final Widget child;

  /// Whether the context menu is enabled.
  final bool enabled;

  /// The menu items (buttons, dividers, sub-menus).
  final List<CNChild> items;

  /// Called when the menu closes without a selection.
  final VoidCallback? onCanceled;

  /// Called when a button item is pressed, with its tag.
  final ValueChanged<String>? onItemPressed;

  @override
  State<CNContextMenuRegion> createState() => _CNContextMenuRegionState();
}

class _CNContextMenuRegionState extends State<CNContextMenuRegion> {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  Future<void> _openContextMenu(Offset globalPosition) async {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      widget.onCanceled?.call();
      return;
    }

    final itemsPayload = widget.items
        .map((c) => c.toChildPayload(context))
        .toList();

    final response = await _channel.invokeMethod<Object>('showContextMenu2', {
      'items': itemsPayload,
      'x': globalPosition.dx,
      'y': globalPosition.dy,
    });

    if (response is String && response.isNotEmpty) {
      widget.onItemPressed?.call(response);
    } else {
      widget.onCanceled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onSecondaryTapDown: widget.enabled
          ? (details) => _openContextMenu(details.globalPosition)
          : null,
      child: widget.child,
    );
  }
}

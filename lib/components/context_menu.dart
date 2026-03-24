import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'menu.dart';

/// A widget region that opens a native context menu on secondary click.
class CNContextMenuRegion extends StatefulWidget {
  /// Creates a context menu region.
  const CNContextMenuRegion({
    super.key,
    required this.child,
    required this.menu,
    required this.onMenuItemSelected,
    this.onCanceled,
    this.enabled = true,
  });

  /// Child that acts as trigger region.
  final Widget child;

  /// Menu model to render natively.
  final CNMenu menu;

  /// Called when a leaf menu item is selected.
  final ValueChanged<CNMenuItem> onMenuItemSelected;

  /// Called when the menu closes without selection.
  final VoidCallback? onCanceled;

  /// Whether the region is interactive.
  final bool enabled;

  @override
  State<CNContextMenuRegion> createState() => _CNContextMenuRegionState();
}

class _CNContextMenuRegionState extends State<CNContextMenuRegion> {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onSecondaryTapDown: widget.enabled ? (details) => _openContextMenu(details.globalPosition) : null,
      onLongPressStart: widget.enabled && defaultTargetPlatform != TargetPlatform.macOS ? (details) => _openFallbackMenu(context) : null,
      child: widget.child,
    );
  }

  Future<void> _openContextMenu(Offset globalPosition) async {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      await _openFallbackMenu(context);
      return;
    }

    final response = await _channel.invokeMethod<Object>('showContextMenu', {
      'menu': widget.menu.toJson(context),
      'x': globalPosition.dx,
      'y': globalPosition.dy,
    });

    final resultMap = response is Map ? Map<Object?, Object?>.from(response) : const <Object?, Object?>{};

    if (resultMap.isEmpty) {
      widget.onCanceled?.call();
      return;
    }

    final identifier = resultMap['identifier'] as String?;
    if (identifier == null || identifier.isEmpty) {
      widget.onCanceled?.call();
      return;
    }

    final item = widget.menu.findItemByIdentifier(identifier);
    if (item == null || !item.enabled) {
      widget.onCanceled?.call();
      return;
    }

    widget.onMenuItemSelected(item);
  }

  Future<void> _openFallbackMenu(BuildContext context) async {
    final selectableItems = widget.menu.items.where((item) => !item.isSeparator && item.enabled).toList();
    if (selectableItems.isEmpty) {
      widget.onCanceled?.call();
      return;
    }

    final selectedIndex = await showCupertinoModalPopup<int>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          actions: [
            for (var i = 0; i < selectableItems.length; i++)
              CupertinoActionSheetAction(onPressed: () => Navigator.of(ctx).pop(i), child: Text(selectableItems[i].title)),
          ],
          cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        );
      },
    );

    if (selectedIndex == null) {
      widget.onCanceled?.call();
      return;
    }

    widget.onMenuItemSelected(selectableItems[selectedIndex]);
  }
}

import 'package:flutter/cupertino.dart';

import 'toolbar_group.dart';
import 'toolbar_controller.dart';

/// Public API for creating and managing SwiftUI toolbar
class CNToolbar {
  static final _controller = CNToolbarController();

  /// Create and show a toolbar with the given groups
  ///
  /// Example:
  /// ```dart
  /// await CNToolbar.create(
  ///   context: context,
  ///   title: 'Mail',
  ///   groups: [
  ///     CNToolbarGroup(
  ///       id: 'actions',
  ///       placement: CNToolbarItemPlacement.status,
  ///       items: [
  ///         CNToolbarButtonItem(
  ///           id: 'compose',
  ///           label: 'Compose',
  ///           systemSymbolName: 'square.and.pencil',
  ///         ),
  ///       ],
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<void> create({
    required BuildContext context,
    required String title,
    required List<CNToolbarGroup> groups,
    bool showSearch = false,
  }) async {
    _controller.init();
    await _controller.makeToolbar(title: title, items: groups, showSearch: showSearch, context: context);
  }

  /// Remove and dispose the toolbar
  static Future<void> remove() async {
    await _controller.clearToolbar();
  }

  /// Dispose all resources
  static void dispose() {
    _controller.dispose();
  }

  /// Register a callback for a toolbar item
  /// Useful for dynamic callback updates
  static void registerCallback(String itemId, VoidCallback callback) {
    _controller.registerButtonCallback(itemId, callback);
  }

  /// Unregister a callback for a toolbar item
  static void unregisterCallback(String itemId) {
    _controller.unregisterButtonCallback(itemId);
  }

  /// Register a callback for search text changes
  static void onSearchChanged(void Function(String) callback) {
    _controller.onSearchChanged(callback);
  }

  /// Register a callback for search submission
  static void onSearchSubmitted(void Function(String) callback) {
    _controller.onSearchSubmitted(callback);
  }
}

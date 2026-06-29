import 'toolbar_button_item.dart';
import 'toolbar_controller.dart';
import 'toolbar_item.dart';

/// Public API for creating and managing SwiftUI toolbar
class CNToolbar {
  static final _controller = CNToolbarController();

  /// Create and show a toolbar with the given items
  ///
  /// Example:
  /// ```dart
  /// await CNToolbar.create(
  ///   title: 'Mail',
  ///   items: [
  ///     CNToolbarButtonItem(
  ///       id: 'compose',
  ///       label: 'Compose',
  ///       systemSymbolName: 'square.and.pencil',
  ///       onPressed: () {
  ///         print('Compose pressed!');
  ///       },
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<void> create({required String title, required List<CNToolbarItem> items, bool showSearch = false}) async {
    _controller.init();
    await _controller.makeToolbar(title: title, items: items, showSearch: showSearch);
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
}

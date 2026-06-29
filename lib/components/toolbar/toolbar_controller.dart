import 'dart:async';
import 'package:flutter/services.dart';

import 'toolbar_button_item.dart';
import 'toolbar_item.dart';

/// Controller for managing toolbar lifecycle and events
class CNToolbarController {
  static const platform = MethodChannel('cupertino_native');
  static const eventChannel = EventChannel('cupertino_native/toolbar_events');

  /// Map of itemId -> callback for button presses
  final Map<String, VoidCallback> _buttonCallbacks = {};

  /// Subscription to toolbar events
  StreamSubscription? _eventSubscription;

  /// Whether toolbar is currently created
  bool _isCreated = false;

  /// Initialize the controller and listen to toolbar events
  void init() {
    if (_isCreated) return;
    _listenToToolbarEvents();
  }

  /// Create toolbar with given items and title
  Future<void> makeToolbar({required String title, required List<CNToolbarItem> items, bool showSearch = false}) async {
    try {
      // Register callbacks from button items
      _clearButtonCallbacks();
      for (final item in items) {
        if (item is CNToolbarButtonItem && item.onPressed != null) {
          _buttonCallbacks[item.id] = item.onPressed!;
        }
      }

      // Send toolbar configuration to native side
      final itemsList = items.map((item) => item.toMap()).toList();
      await platform.invokeMethod('makeToolbar', {'title': title, 'items': itemsList, 'showSearch': showSearch});

      _isCreated = true;
      init();
    } catch (e) {
      print('Error creating toolbar: $e');
      rethrow;
    }
  }

  /// Clear/remove toolbar
  Future<void> clearToolbar() async {
    try {
      await platform.invokeMethod('clearToolbar');
      _isCreated = false;
      _clearButtonCallbacks();
      await _eventSubscription?.cancel();
      _eventSubscription = null;
    } catch (e) {
      print('Error clearing toolbar: $e');
      rethrow;
    }
  }

  /// Listen to toolbar events from native side
  void _listenToToolbarEvents() {
    _eventSubscription ??= eventChannel.receiveBroadcastStream().listen(
      (event) {
        _handleToolbarEvent(event);
      },
      onError: (error) {
        print('Toolbar event error: $error');
      },
    );
  }

  /// Handle toolbar event from native side
  void _handleToolbarEvent(dynamic event) {
    if (event is! Map) return;

    final data = Map<String, dynamic>.from(event as Map);
    final itemId = data['id'] as String?;
    final eventType = data['type'] as String?;

    if (itemId == null) return;

    switch (eventType) {
      case 'buttonPressed':
        _buttonCallbacks[itemId]?.call();
        break;
      case 'searchChanged':
        // Handle search field changes (future)
        break;
      case 'pickerChanged':
        // Handle picker changes (future)
        break;
      default:
        print('Unknown event type: $eventType');
    }
  }

  /// Clear all registered callbacks
  void _clearButtonCallbacks() {
    _buttonCallbacks.clear();
  }

  /// Register a button callback
  void registerButtonCallback(String itemId, VoidCallback callback) {
    _buttonCallbacks[itemId] = callback;
  }

  /// Unregister a button callback
  void unregisterButtonCallback(String itemId) {
    _buttonCallbacks.remove(itemId);
  }

  /// Dispose resources
  void dispose() async {
    await clearToolbar();
    await _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import '../../channel/params.dart';
import 'toolbar_button_item.dart';
import 'toolbar_group.dart';
import 'toolbar_item.dart';
import 'toolbar_picker.dart';

/// Controller for managing toolbar lifecycle and events
class CNToolbarController {
  // ignore: public_member_api_docs
  static const eventChannel = EventChannel('cupertino_native/toolbar_events');

  // ignore: public_member_api_docs
  static const platform = MethodChannel('cupertino_native');

  /// Callback for search text changes
  void Function(String)? _onSearchChanged;

  /// Callback for search submission
  void Function(String)? _onSearchSubmitted;

  /// Map of itemId -> callback for button presses
  final Map<String, VoidCallback> _buttonCallbacks = {};

  /// Map of itemId -> callback for picker selection changes
  final Map<String, void Function(String)> _pickerCallbacks = {};

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
  Future<void> makeToolbar({
    required String title,
    required List<CNToolbarItem> items,
    bool showSearch = false,
    required BuildContext context,
  }) async {
    try {
      // Register callbacks from button items (recursive through groups)
      _clearButtonCallbacks();
      _registerCallbacksRecursive(items);

      // Send toolbar configuration to native side
      final itemsList = items.map((item) {
        final itemMap = item.toMap();
        // Convert Color to ARGB int using resolveColorToArgb
        if (item.tint != null) {
          itemMap['tint'] = resolveColorToArgb(item.tint, context);
        }
        return itemMap;
      }).toList();
      await platform.invokeMethod('makeToolbar', {'title': title, 'items': itemsList, 'showSearch': showSearch});

      _isCreated = true;
      init();
    } catch (e) {
      debugPrint('Error creating toolbar: $e');
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
      debugPrint('Error clearing toolbar: $e');
      rethrow;
    }
  }

  /// Register a button callback
  void registerButtonCallback(String itemId, VoidCallback callback) {
    _buttonCallbacks[itemId] = callback;
  }

  /// Unregister a button callback
  void unregisterButtonCallback(String itemId) {
    _buttonCallbacks.remove(itemId);
  }

  /// Register callback for search text changes
  void onSearchChanged(void Function(String) callback) {
    _onSearchChanged = callback;
  }

  /// Register callback for search submission
  void onSearchSubmitted(void Function(String) callback) {
    _onSearchSubmitted = callback;
  }

  /// Dispose resources
  void dispose() async {
    await clearToolbar();
    await _eventSubscription?.cancel();
    _eventSubscription = null;
  }

  /// Listen to toolbar events from native side
  void _listenToToolbarEvents() {
    _eventSubscription ??= eventChannel.receiveBroadcastStream().listen(
      (event) {
        _handleToolbarEvent(event);
      },
      onError: (error) {
        debugPrint('Toolbar event error: $error');
      },
    );
  }

  /// Handle toolbar event from native side
  void _handleToolbarEvent(dynamic event) {
    if (event is! Map) return;

    final data = Map<String, dynamic>.from(event as Map);
    final eventType = data['type'] as String?;
    final itemId = data['id'] as String?;
    final query = data['query'] as String?;
    final value = data['value'] as String?;

    switch (eventType) {
      case 'buttonPressed':
        if (itemId != null) {
          _buttonCallbacks[itemId]?.call();
        }
        break;
      case 'pickerChanged':
        if (itemId != null && value != null) {
          _pickerCallbacks[itemId]?.call(value);
        }
        break;
      case 'searchChanged':
        if (query != null) {
          _onSearchChanged?.call(query);
        }
        break;
      case 'searchSubmitted':
        if (query != null) {
          _onSearchSubmitted?.call(query);
        }
        break;
      case 'pickerChanged':
        // Handle picker changes (future)
        break;
      default:
        debugPrint('Unknown event type: $eventType');
    }
  }

  /// Clear all registered callbacks
  void _clearButtonCallbacks() {
    _buttonCallbacks.clear();
    _pickerCallbacks.clear();
  }

  /// Recursively register callbacks from items and groups
  void _registerCallbacksRecursive(List<CNToolbarItem> items) {
    for (final item in items) {
      if (item is CNToolbarButtonItem && item.onPressed != null) {
        _buttonCallbacks[item.id] = item.onPressed!;
      } else if (item is CNToolbarPickerItem && item.onChanged != null) {
        _pickerCallbacks[item.id] = item.onChanged!;
      } else if (item is CNToolbarGroup) {
        _registerCallbacksRecursive(item.items);
      }
    }
  }
}

import 'dart:async';
import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/components/menu_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';

import '../../channel/params.dart';
import 'toolbar_button_item.dart';
import 'toolbar_group.dart';
import 'toolbar_item.dart';
import 'toolbar_menu_button_item.dart';
import 'toolbar_picker.dart';
import 'toolbar_toggle_item.dart';

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

  /// Subscription to toolbar events
  StreamSubscription? _eventSubscription;

  /// Whether toolbar is currently created
  bool _isCreated = false;

  /// Map of menu-button itemId -> menu model/callback pair
  final Map<String, _ToolbarMenuButtonRegistration> _menuButtonRegistrations = {};

  /// Map of itemId -> callback for picker selection changes
  final Map<String, void Function(String)> _pickerCallbacks = {};

  /// Map of itemId -> callback for toggle state changes
  final Map<String, void Function(bool)> _toggleCallbacks = {};

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
      final itemsList = items.map((item) => _serializeItem(item, context)).toList();
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

  /// Register a toggle callback
  void registerToggleCallback(String itemId, void Function(bool) callback) {
    _toggleCallbacks[itemId] = callback;
  }

  /// Unregister a toggle callback
  void unregisterToggleCallback(String itemId) {
    _toggleCallbacks.remove(itemId);
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

  Map<String, dynamic> _serializeItem(CNToolbarItem item, BuildContext context) {
    final itemMap = item.toMap();

    if (item is CNToolbarMenuButtonItem) {
      itemMap['menu'] = item.menu.toChannelMap(context);
      itemMap['image'] = CNChannelSerialization.object(item.image, context);
    }

    if (item.tint != null) {
      itemMap['tint'] = resolveColorToArgb(item.tint, context);
    }

    if (item is CNToolbarGroup) {
      itemMap['items'] = item.items.map((child) => _serializeItem(child, context)).toList();
    }

    return itemMap;
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

    final data = Map<String, dynamic>.from(event);
    final eventType = data['type'] as String?;
    final itemId = data['id'] as String?;
    final query = data['query'] as String?;
    final value = data['value'];
    final identifier = data['identifier'] as String?;

    switch (eventType) {
      case 'buttonPressed':
        if (itemId != null) {
          _buttonCallbacks[itemId]?.call();
        }
        break;
      case 'pickerChanged':
        if (itemId != null && value is String) {
          _pickerCallbacks[itemId]?.call(value);
        }
        break;
      case 'toggleChanged':
        if (itemId != null && value is bool) {
          _toggleCallbacks[itemId]?.call(value);
        }
        break;
      case 'menuButtonItemSelected':
        if (itemId != null && identifier != null) {
          final registration = _menuButtonRegistrations[itemId];
          if (registration != null) {
            final selectedItem = registration.menu.findItemByIdentifier(identifier);
            if (selectedItem != null && selectedItem.enabled) {
              registration.onSelected(selectedItem);
            }
          }
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
      default:
        debugPrint('Unknown event type: $eventType');
    }
  }

  /// Clear all registered callbacks
  void _clearButtonCallbacks() {
    _buttonCallbacks.clear();
    _pickerCallbacks.clear();
    _toggleCallbacks.clear();
    _menuButtonRegistrations.clear();
  }

  /// Recursively register callbacks from items and groups
  void _registerCallbacksRecursive(List<CNToolbarItem> items) {
    for (final item in items) {
      if (item is CNToolbarButtonItem && item.onPressed != null) {
        _buttonCallbacks[item.id] = item.onPressed!;
      } else if (item is CNToolbarPickerItem && item.onChanged != null) {
        _pickerCallbacks[item.id] = item.onChanged!;
      } else if (item is CNToolbarToggleItem && item.onChanged != null) {
        _toggleCallbacks[item.id] = item.onChanged!;
      } else if (item is CNToolbarMenuButtonItem) {
        _menuButtonRegistrations[item.id] = _ToolbarMenuButtonRegistration(menu: item.menu, onSelected: item.onSelected);
      } else if (item is CNToolbarGroup) {
        _registerCallbacksRecursive(item.items);
      }
    }
  }
}

class _ToolbarMenuButtonRegistration {
  _ToolbarMenuButtonRegistration({required this.menu, required this.onSelected});

  final CNMenuModel menu;
  final ValueChanged<CNMenuModelItem> onSelected;
}

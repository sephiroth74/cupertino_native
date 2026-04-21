import 'package:flutter/services.dart';

/// Display mode for a native macOS toolbar.
enum CNToolbarDisplayMode {
  /// Show icon and label.
  iconAndLabel,

  /// Show icon only.
  iconOnly,

  /// Show label only.
  labelOnly,

  /// Follow system default.
  automatic,
}

/// Size mode for a native macOS toolbar.
enum CNToolbarSizeMode {
  /// Regular toolbar item size.
  regular,

  /// Small toolbar item size.
  small,

  /// Follow system default.
  automatic,
}

/// A single toolbar button item.
class CNToolbarItem {
  /// Creates a toolbar item.
  const CNToolbarItem({
    required this.id,
    required this.label,
    this.toolTip,
    this.systemSymbolName,
  });

  /// Stable identifier for this item.
  final String id;

  /// Visible label for this item.
  final String label;

  /// Optional tooltip.
  final String? toolTip;

  /// Optional SF Symbol name for icon.
  final String? systemSymbolName;

  /// Serializes this item for method-channel transport.
  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'toolTip': toolTip,
    'systemSymbolName': systemSymbolName,
  };
}

/// Utility API to configure native macOS window toolbars.
class CNToolbar {
  static const MethodChannel _channel = MethodChannel('cupertino_native');
  static const MethodChannel _eventsChannel = MethodChannel(
    'cupertino_native/toolbar_events',
  );

  static bool _eventsHandlerInstalled = false;
  static ValueChanged<String>? _onItemPressed;

  /// Sets or replaces the native toolbar on the host window.
  static Future<void> setItems({
    required List<CNToolbarItem> items,
    String identifier = 'CupertinoNativeToolbar',
    bool allowsUserCustomization = false,
    bool autosavesConfiguration = false,
    CNToolbarDisplayMode displayMode = CNToolbarDisplayMode.iconAndLabel,
    CNToolbarSizeMode sizeMode = CNToolbarSizeMode.regular,
    ValueChanged<String>? onItemPressed,
  }) async {
    _ensureEventsHandler();
    _onItemPressed = onItemPressed;

    await _channel.invokeMethod<void>('setToolbar', {
      'identifier': identifier,
      'items': items.map((item) => item.toMap()).toList(),
      'allowsUserCustomization': allowsUserCustomization,
      'autosavesConfiguration': autosavesConfiguration,
      'displayMode': displayMode.name,
      'sizeMode': sizeMode.name,
    });
  }

  /// Removes the toolbar from the host window.
  static Future<void> clear() async {
    await _channel.invokeMethod<void>('clearToolbar');
  }

  static void _ensureEventsHandler() {
    if (_eventsHandlerInstalled) {
      return;
    }
    _eventsHandlerInstalled = true;
    _eventsChannel.setMethodCallHandler((call) async {
      if (call.method == 'onToolbarItemPressed') {
        final args = call.arguments;
        if (args is Map) {
          final dynamic idRaw = args['id'];
          if (idRaw is String) {
            _onItemPressed?.call(idRaw);
          }
        }
      }
    });
  }
}

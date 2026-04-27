import 'package:flutter/services.dart';

import '../style/combo_box_behavior.dart';
import '../style/combo_button_style.dart';

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

/// Kind of toolbar item to render natively.
enum CNToolbarItemKind {
  /// Standard pressable toolbar button.
  button,

  /// Native search field embedded in the toolbar.
  searchField,

  /// Native combo box embedded in the toolbar.
  comboBox,

  /// Native combo button embedded in the toolbar.
  comboButton,
}

/// Menu item used by [CNToolbarItem.comboButton].
class CNToolbarMenuItem {
  /// Creates a toolbar combo-button menu item.
  const CNToolbarMenuItem({
    required this.id,
    required this.title,
    this.tag,
    this.enabled = true,
  }) : isSeparator = false;

  /// Creates a separator entry for the combo-button menu.
  const CNToolbarMenuItem.separator({required this.id})
    : title = '',
      tag = null,
      enabled = false,
      isSeparator = true;

  /// Stable identifier for this menu item.
  final String id;

  /// Visible title.
  final String title;

  /// Optional integer tag.
  final int? tag;

  /// Whether the item can be selected.
  final bool enabled;

  /// Whether this entry is a separator.
  final bool isSeparator;

  /// Serializes this item for method-channel transport.
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'tag': tag,
    'enabled': enabled,
    'isSeparator': isSeparator,
  };
}

/// A single toolbar item definition.
class CNToolbarItem {
  /// Creates a toolbar button item.
  const CNToolbarItem({
    required this.id,
    required this.label,
    this.toolTip,
    this.systemSymbolName,
  }) : kind = CNToolbarItemKind.button,
       text = null,
       placeholder = null,
       width = null,
       items = null,
       behavior = null,
       menuItems = null,
       comboButtonStyle = null;

  /// Creates a toolbar search field item.
  const CNToolbarItem.searchField({
    required this.id,
    this.label = 'Search',
    this.toolTip,
    this.text = '',
    this.placeholder,
    this.width = 180,
  }) : kind = CNToolbarItemKind.searchField,
       systemSymbolName = null,
       items = null,
       behavior = null,
       menuItems = null,
       comboButtonStyle = null;

  /// Creates a toolbar combo box item.
  const CNToolbarItem.comboBox({
    required this.id,
    required this.items,
    this.label = 'Combo Box',
    this.toolTip,
    this.text = '',
    this.placeholder,
    this.width = 160,
    this.behavior = CNComboBoxBehavior.editable,
  }) : kind = CNToolbarItemKind.comboBox,
       systemSymbolName = null,
       menuItems = null,
       comboButtonStyle = null;

  /// Creates a toolbar combo button item.
  const CNToolbarItem.comboButton({
    required this.id,
    required this.label,
    required this.menuItems,
    this.toolTip,
    this.systemSymbolName,
    this.width = 160,
    this.comboButtonStyle = CNComboButtonStyle.split,
  }) : kind = CNToolbarItemKind.comboButton,
       text = null,
       placeholder = null,
       items = null,
       behavior = null;

  /// Kind of item to render.
  final CNToolbarItemKind kind;

  /// Stable identifier for this item.
  final String id;

  /// Visible label for this item.
  final String label;

  /// Optional tooltip.
  final String? toolTip;

  /// Optional SF Symbol name for icon.
  final String? systemSymbolName;

  /// Current text value for search or combo-box items.
  final String? text;

  /// Placeholder for search or combo-box items.
  final String? placeholder;

  /// Preferred width for custom toolbar views.
  final double? width;

  /// Available items for toolbar combo-box items.
  final List<String>? items;

  /// Interaction mode for toolbar combo-box items.
  final CNComboBoxBehavior? behavior;

  /// Menu items for toolbar combo-button items.
  final List<CNToolbarMenuItem>? menuItems;

  /// Visual style for toolbar combo-button items.
  final CNComboButtonStyle? comboButtonStyle;

  /// Serializes this item for method-channel transport.
  Map<String, dynamic> toMap() => {
    'kind': kind.name,
    'id': id,
    'label': label,
    'toolTip': toolTip,
    'systemSymbolName': systemSymbolName,
    'text': text,
    'placeholder': placeholder,
    'width': width,
    'items': items,
    'behavior': behavior?.name,
    'menuItems': menuItems?.map((item) => item.toMap()).toList(),
    'comboButtonStyle': comboButtonStyle?.name,
  };
}

/// Toolbar event emitted by native toolbar controls.
class CNToolbarEvent {
  /// Creates a toolbar event.
  const CNToolbarEvent({
    required this.itemId,
    required this.type,
    this.text,
    this.selectedIndex,
    this.menuItemId,
    this.menuItemTitle,
    this.menuItemTag,
  });

  /// Stable identifier of the toolbar item that produced the event.
  final String itemId;

  /// Event type, such as `buttonPressed`, `searchChanged`, `comboBoxChanged`.
  final String type;

  /// Optional text payload.
  final String? text;

  /// Optional selected index for combo-box events.
  final int? selectedIndex;

  /// Optional selected menu item identifier.
  final String? menuItemId;

  /// Optional selected menu item title.
  final String? menuItemTitle;

  /// Optional selected menu item tag.
  final int? menuItemTag;

  /// Deserializes a toolbar event from the native payload.
  factory CNToolbarEvent.fromMap(Map<Object?, Object?> map) {
    return CNToolbarEvent(
      itemId: (map['id'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'unknown',
      text: map['text'] as String?,
      selectedIndex: (map['selectedIndex'] as num?)?.toInt(),
      menuItemId: map['menuItemId'] as String?,
      menuItemTitle: map['menuItemTitle'] as String?,
      menuItemTag: (map['menuItemTag'] as num?)?.toInt(),
    );
  }
}

/// Utility API to configure native macOS window toolbars.
class CNToolbar {
  static const MethodChannel _channel = MethodChannel('cupertino_native');
  static const MethodChannel _eventsChannel = MethodChannel(
    'cupertino_native/toolbar_events',
  );

  static bool _eventsHandlerInstalled = false;
  static ValueChanged<String>? _onItemPressed;
  static ValueChanged<CNToolbarEvent>? _onEvent;

  /// Sets or replaces the native toolbar on the host window.
  static Future<void> setItems({
    required List<CNToolbarItem> items,
    String identifier = 'CupertinoNativeToolbar',
    bool allowsUserCustomization = false,
    bool autosavesConfiguration = false,
    CNToolbarDisplayMode displayMode = CNToolbarDisplayMode.iconAndLabel,
    CNToolbarSizeMode sizeMode = CNToolbarSizeMode.regular,
    ValueChanged<String>? onItemPressed,
    ValueChanged<CNToolbarEvent>? onEvent,
  }) async {
    _ensureEventsHandler();
    _onItemPressed = onItemPressed;
    _onEvent = onEvent;

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
    _onItemPressed = null;
    _onEvent = null;
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
            _onEvent?.call(
              CNToolbarEvent(itemId: idRaw, type: 'buttonPressed'),
            );
          }
        }
      } else if (call.method == 'onToolbarEvent') {
        final args = call.arguments;
        if (args is Map) {
          final event = CNToolbarEvent.fromMap(
            Map<Object?, Object?>.from(args),
          );
          if (event.type == 'buttonPressed' ||
              event.type == 'comboButtonPressed') {
            _onItemPressed?.call(event.itemId);
          }
          _onEvent?.call(event);
        }
      }
    });
  }
}

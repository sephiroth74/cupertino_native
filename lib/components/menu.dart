import 'package:cupertino_native/components/image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// A menu model used by [CNComboButton].
class CNMenu extends ChangeNotifier with EquatableMixin {
  /// The top-level menu items.
  final List<CNMenuItem> items;

  /// Creates a menu with the provided [items].
  CNMenu({required this.items}) {
    // Listen to all items for changes
    for (final item in items) {
      item.addListener(notifyListeners);
    }
  }

  /// Creates an empty menu.
  factory CNMenu.empty() {
    return CNMenu(items: []);
  }

  /// Serializes the menu to JSON for platform channel communication.
  String toJson(BuildContext context) {
    final itemsJson = items.map((item) => item.toJson(context)).join(', ');
    return '''
    {
      "items": [$itemsJson]
    }
    ''';
  }

  /// Returns the first menu item with the given platform [identifier].
  CNMenuItem? findItemByIdentifier(String identifier) {
    if (identifier.isEmpty) return null;
    return _findIn(items, identifier);
  }

  CNMenuItem? _findIn(List<CNMenuItem> nodes, String identifier) {
    for (final item in nodes) {
      if (!item.isSeparator && item.identifier == identifier) {
        return item;
      }
      final submenuItems = item.submenu?.items;
      if (submenuItems != null) {
        final nested = _findIn(submenuItems, identifier);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  @override
  void dispose() {
    for (final item in items) {
      item.removeListener(notifyListeners);
      item.dispose();
    }
    super.dispose();
  }

  @override
  List<Object?> get props => [items];
}

/// Represents the state of a CNMenuItem
enum CNMenuItemState {
  /// The menu item is not selected.
  off,

  /// The menu item is selected.
  on,

  /// The menu item is in an indeterminate state.
  mixed,
}

/// Represents a single item in a CNMenu, which can have a title, an optional tag,
/// an optional symbol configuration, and an optional submenu.
/// It also has a state (on, off, mixed) and an enabled/disabled status.
// ignore: must_be_immutable
class CNMenuItem extends ChangeNotifier with EquatableMixin {
  static int _identifierCounter = 0;

  /// Whether this entry is a visual separator.
  final bool isSeparator;

  /// The state of the menu item, which can be on, off, or mixed (indeterminate).
  final CNMenuItemState state;

  /// An optional integer tag that can be used to identify the item.
  final int? tag;

  /// The title of the menu item, which is displayed to the user.
  final String title;

  /// An optional symbol image associated with the menu item, which can be rendered according to the provided symbol configuration.
  final CNImage? image;

  /// An optional submenu that can be displayed when the user interacts with this menu item.
  final CNMenu? submenu;

  /// Whether the menu item is enabled or disabled. Disabled items are typically shown in a dimmed state and cannot be interacted with.
  final bool enabled;

  final int _identifier;

  /// A unique identifier for this menu item, used for platform communication. It is generated automatically and should not be set manually.
  String get identifier => isSeparator ? '' : 'menuItem_$_identifier';

  /// Creates a new CNMenuItem with the given properties. The [title] is required, while other properties are optional.
  /// The [state] defaults to [CNMenuItemState.off], and [enabled] defaults to true.
  /// The [tag] can be used to store an arbitrary integer value for identification purposes.
  CNMenuItem({required this.title, this.tag, this.image, this.submenu, this.state = CNMenuItemState.off, this.enabled = true})
    : isSeparator = false,
      _identifier = _identifierCounter++;

  /// Creates a separator entry for [CNMenu].
  CNMenuItem.separator()
    : title = '',
      tag = null,
      image = null,
      submenu = null,
      state = CNMenuItemState.off,
      enabled = false,
      isSeparator = true,
      _identifier = _identifierCounter++;

  /// Converts this menu item to a JSON string representation, which is used for communication with the native platform.
  /// The JSON includes all relevant properties of the menu item, such as title, tag, state, symbol configuration, enabled status, and submenu (if any).
  String toJson(BuildContext context) {
    if (isSeparator) {
      return '''
    {
      "separator": true
    }
    ''';
    }

    return '''
    {
      "separator": false,
      "title": "$title",
      "tag": $tag,
      "identifier": "menuItem_$_identifier",
      "state": "${state.name}",
      "image": ${image?.toJson(context) ?? 'null'},
      "enabled": $enabled,
      "submenu": ${submenu?.toJson(context) ?? 'null'}
    }
    ''';
  }

  @override
  List<Object?> get props => [_identifier, isSeparator, state, tag, title, image, submenu, enabled];
}

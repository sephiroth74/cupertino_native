import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Data model used by context-menu and toolbar menu integrations.
// ignore: must_be_immutable
class CNMenuModel extends ChangeNotifier with Equatable implements CNChannelSerializable {
  /// Creates a menu model with the provided [items].
  CNMenuModel({required this.items}) {
    for (final item in items) {
      item.addListener(notifyListeners);
    }
  }

  /// Creates an empty menu model.
  factory CNMenuModel.empty() {
    return CNMenuModel(items: []);
  }

  /// The top-level menu items.
  final List<CNMenuModelItem> items;

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

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) => toMap(context, ignoreTheme: ignoreTheme);

  /// Serializes the model to a platform-channel payload.
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false}) {
    return {'items': CNChannelSerialization.objects(items, context, ignoreTheme: ignoreTheme)};
  }

  /// Serializes this model to JSON.
  String toJson(BuildContext context, {bool ignoreTheme = false}) {
    return jsonEncode(toMap(context, ignoreTheme: ignoreTheme));
  }

  /// Returns the first item with the given platform [identifier].
  CNMenuModelItem? findItemByIdentifier(String identifier) {
    if (identifier.isEmpty) return null;
    return _findIn(items, identifier);
  }

  CNMenuModelItem? _findIn(List<CNMenuModelItem> nodes, String identifier) {
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
}

/// Represents the state of a [CNMenuModelItem].
enum CNMenuModelItemState {
  /// The menu item is not selected.
  off,

  /// The menu item is selected.
  on,

  /// The menu item is in an indeterminate state.
  mixed,
}

/// A single item in [CNMenuModel].
// ignore: must_be_immutable
class CNMenuModelItem extends ChangeNotifier with Equatable implements CNChannelSerializable {
  /// Creates a menu item.
  CNMenuModelItem({
    required this.title,
    this.subtitle,
    this.tag,
    this.image,
    this.submenu,
    this.state = CNMenuModelItemState.off,
    this.enabled = true,
  }) : isSeparator = false,
       _identifier = _identifierCounter++;

  /// Creates a separator entry.
  CNMenuModelItem.separator()
    : title = '',
      subtitle = null,
      tag = null,
      image = null,
      submenu = null,
      state = CNMenuModelItemState.off,
      enabled = false,
      isSeparator = true,
      _identifier = _identifierCounter++;

  /// Whether the menu item is enabled.
  final bool enabled;

  /// Optional symbol/image.
  final CNImage? image;

  /// Whether this entry is a separator.
  final bool isSeparator;

  /// Item check state.
  final CNMenuModelItemState state;

  /// Optional submenu.
  final CNMenuModel? submenu;

  /// Optional subtitle.
  final String? subtitle;

  /// Optional item tag.
  final int? tag;

  /// Item title.
  final String title;

  static int _identifierCounter = 0;

  final int _identifier;

  @override
  List<Object?> get props => [_identifier, isSeparator, state, tag, title, subtitle, image, submenu, enabled];

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) => toMap(context, ignoreTheme: ignoreTheme);

  /// Stable identifier used across channel communication.
  String get identifier => isSeparator ? '' : 'menuItem_$_identifier';

  /// Serializes this item to a platform-channel payload.
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false}) {
    if (isSeparator) {
      return {'separator': true};
    }

    return {
      'separator': false,
      'title': title,
      'subtitle': subtitle,
      'tag': tag,
      'identifier': 'menuItem_$_identifier',
      'state': state.name,
      'image': CNChannelSerialization.object(image, context, ignoreTheme: ignoreTheme),
      'enabled': enabled,
      'submenu': CNChannelSerialization.object(submenu, context, ignoreTheme: ignoreTheme),
    };
  }

  /// Serializes this item to JSON.
  String toJson(BuildContext context, {bool ignoreTheme = false}) {
    return jsonEncode(toMap(context, ignoreTheme: ignoreTheme));
  }
}

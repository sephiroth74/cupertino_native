import 'package:cupertino_native/components/menu.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/style/menu_style.dart';
import 'package:flutter/widgets.dart';

import 'toolbar_item.dart';

/// A toolbar menu button item backed by native macOS Menu.
class CNToolbarMenuButtonItem extends CNToolbarItem {
  /// Creates a toolbar menu button item.
  const CNToolbarMenuButtonItem({
    required super.id,
    required this.menu,
    required this.onSelected,
    super.tint,
    super.disabled,
    super.controlSize,
    this.label,
    this.image,
    this.menuStyle = CNMenuStyle.automatic,
  }) : assert(label != null || image != null, 'CNToolbarMenuButtonItem requires a label or image.');

  /// Optional icon shown on the menu button.
  final CNImage? image;

  /// Optional text label shown on the menu button.
  final String? label;

  /// The menu model to show.
  final CNMenu menu;

  /// Native menu style.
  final CNMenuStyle menuStyle;

  /// Called when a leaf menu item is selected.
  final ValueChanged<CNMenuItem> onSelected;

  @override
  Map<String, dynamic> customProperties() {
    return {'label': label, 'menuStyle': menuStyle.name};
  }

  @override
  String get kind => 'menuButton';
}

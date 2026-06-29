import 'toolbar_placement.dart';

/// Base class for all toolbar items
abstract class CNToolbarItem {
  /// Unique identifier for this toolbar item
  final String id;

  /// Display label or title
  final String label;

  /// Where to place this item in the toolbar
  final CNToolbarItemPlacement placement;

  /// Hex color for tint (#RRGGBB)
  final String? tintColor;

  /// Whether this item is disabled
  final bool disabled;

  const CNToolbarItem({
    required this.id,
    required this.label,
    this.placement = CNToolbarItemPlacement.automatic,
    this.tintColor,
    this.disabled = false,
  });

  /// Convert to dictionary for native platform channel
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'placement': placement.toNativeString(),
      'tintColor': tintColor,
      'disabled': disabled,
      'kind': kind,
      ...customProperties(),
    };
  }

  /// Item kind (button, textField, search, picker, etc)
  String get kind;

  /// Override to add custom properties specific to subclass
  Map<String, dynamic> customProperties() => {};
}

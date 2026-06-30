import 'toolbar_item.dart';
import 'toolbar_placement.dart';

/// A group of toolbar items that will be rendered together
/// Groups are displayed as ToolbarItemGroup in SwiftUI
class CNToolbarGroup extends CNToolbarItem {
  /// Create a toolbar group with the given items
  CNToolbarGroup({required super.id, required this.items, required this.placement, super.tint, super.disabled}) {
    if (items.isEmpty) {
      throw ArgumentError('A toolbar group must contain at least one item');
    }
  }

  /// Items contained in this group
  final List<CNToolbarItem> items;

  /// Where to place this group in the toolbar
  final CNToolbarItemPlacement placement;

  @override
  Map<String, dynamic> customProperties() {
    return {'placement': placement.toNativeString(), 'items': items.map((item) => item.toMap()).toList()};
  }

  @override
  String get kind => 'group';
}

/// Toolbar item placement enum - maps to SwiftUI ToolbarItemPlacement
enum CNToolbarItemPlacement { automatic, principal, navigation, status, confirmationAction, destructiveAction, cancellationAction }

// ignore: public_member_api_docs
extension CNToolbarItemPlacementExt on CNToolbarItemPlacement {
  /// Convert enum to string for native side
  String toNativeString() {
    return name;
  }

  /// Parse from string
  static CNToolbarItemPlacement fromString(String value) {
    return CNToolbarItemPlacement.values.firstWhere(
      (e) => e.toNativeString() == value,
      orElse: () => CNToolbarItemPlacement.automatic,
    );
  }
}

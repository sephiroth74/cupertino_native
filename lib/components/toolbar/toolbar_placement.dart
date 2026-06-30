/// Toolbar item placement enum - maps to SwiftUI ToolbarItemPlacement
enum CNToolbarItemPlacement { 
  /// The placement is determined automatically by the system
  automatic, 
  /// The placement is in the principal area of the toolbar
  principal, 
  /// The placement is in the navigation area of the toolbar
  navigation, 
  /// The placement is in the status area of the toolbar
  status, 
  /// The placement is in the confirmation area of the toolbar
  confirmationAction, 
  /// The placement is in the destructive action area of the toolbar
  destructiveAction, 
  /// The placement is in the cancellation action area of the toolbar
  cancellationAction
}

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

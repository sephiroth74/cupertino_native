/// Toolbar item placement enum - maps to SwiftUI ToolbarItemPlacement
enum CNToolbarItemPlacement {
  /// Automatically select the best placement
  automatic,

  /// Place in the principal area (typically center)
  principal,

  /// Place in the navigation area (typically right side)
  navigation,

  /// Place in the status area
  status,

  /// Place as a confirmation action
  confirmationAction,

  /// Place as a destructive action
  destructiveAction,

  /// Place as a cancellation action
  cancellationAction,
}

// ignore: public_member_api_docs
extension CNToolbarItemPlacementExt on CNToolbarItemPlacement {
  /// Convert enum to string for native side
  String toNativeString() {
    switch (this) {
      case CNToolbarItemPlacement.automatic:
        return 'automatic';
      case CNToolbarItemPlacement.principal:
        return 'principal';
      case CNToolbarItemPlacement.navigation:
        return 'navigation';
      case CNToolbarItemPlacement.status:
        return 'status';
      case CNToolbarItemPlacement.confirmationAction:
        return 'confirmationAction';
      case CNToolbarItemPlacement.destructiveAction:
        return 'destructiveAction';
      case CNToolbarItemPlacement.cancellationAction:
        return 'cancellationAction';
    }
  }

  /// Parse from string
  static CNToolbarItemPlacement fromString(String value) {
    return CNToolbarItemPlacement.values.firstWhere(
      (e) => e.toNativeString() == value,
      orElse: () => CNToolbarItemPlacement.automatic,
    );
  }
}

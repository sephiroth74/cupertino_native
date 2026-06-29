import 'toolbar_item.dart';
import 'toolbar_placement.dart';

/// A toolbar button item
class CNToolbarButtonItem extends CNToolbarItem {
  /// SF Symbol name (e.g., 'square.and.pencil')
  final String? systemSymbolName;

  /// Button style (e.g., 'borderedProminent')
  final String? buttonStyle;

  /// Callback when button is pressed
  /// This is NOT serialized - it's stored locally for event handling
  final VoidCallback? onPressed;

  // ignore: public_member_api_docs
  const CNToolbarButtonItem({
    required String id,
    required String label,
    CNToolbarItemPlacement placement = CNToolbarItemPlacement.automatic,
    String? tintColor,
    bool disabled = false,
    this.systemSymbolName,
    this.buttonStyle,
    this.onPressed,
  }) : super(id: id, label: label, placement: placement, tintColor: tintColor, disabled: disabled);

  @override
  String get kind => 'button';

  @override
  Map<String, dynamic> customProperties() {
    return {'systemSymbolName': systemSymbolName, 'buttonStyle': buttonStyle};
  }
}

/// Callback type for button press
typedef VoidCallback = void Function();

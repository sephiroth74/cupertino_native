import 'package:flutter/cupertino.dart';

import 'toolbar_item.dart';

/// A toolbar button item
class CNToolbarButtonItem extends CNToolbarItem {
  // ignore: public_member_api_docs
  const CNToolbarButtonItem({
    required super.id,
    super.placement,
    super.tint,
    super.disabled,
    this.label,
    this.systemSymbolName,
    this.buttonStyle,
    this.onPressed,
  }) : assert(systemSymbolName != null || label != null, 'Either systemSymbolName or label must be provided for a button item');

  /// Optional display label for this button
  final String? label;

  /// Button style (e.g., 'borderedProminent')
  final String? buttonStyle;

  /// Callback when button is pressed
  /// This is NOT serialized - it's stored locally for event handling
  final VoidCallback? onPressed;

  /// SF Symbol name (e.g., 'square.and.pencil')
  final String? systemSymbolName;

  @override
  Map<String, dynamic> customProperties() {
    return {'systemSymbolName': systemSymbolName, 'buttonStyle': buttonStyle, 'label': label};
  }

  @override
  String get kind => 'button';
}

/// Callback type for button press
typedef VoidCallback = void Function();

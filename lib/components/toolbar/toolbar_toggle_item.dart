import 'package:flutter/cupertino.dart';

import 'toolbar_item.dart';

/// A toolbar toggle item for on/off state
class CNToolbarToggleItem extends CNToolbarItem {
  // ignore: public_member_api_docs
  const CNToolbarToggleItem({
    required super.id,
    super.tint,
    super.disabled,
    this.label,
    this.systemSymbolName,
    required this.isOn,
    this.toggleStyle,
    this.onChanged,
  });

  /// Callback when toggle state changes
  /// This is NOT serialized - it's stored locally for event handling
  final void Function(bool)? onChanged;

  /// Current on/off state
  final bool isOn;

  /// Optional display label for this toggle
  final String? label;

  /// Optional SF Symbol name for the toggle
  final String? systemSymbolName;

  /// Toggle style: 'switch', 'button', 'automatic' (macOS specific)
  final String? toggleStyle;

  @override
  Map<String, dynamic> customProperties() {
    return {'label': label, 'systemSymbolName': systemSymbolName, 'isOn': isOn, 'toggleStyle': toggleStyle};
  }

  @override
  String get kind => 'toggle';
}

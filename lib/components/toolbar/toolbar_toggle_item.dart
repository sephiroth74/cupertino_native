import 'package:cupertino_native/components/toggle.dart';

import 'toolbar_item.dart';

/// A toolbar toggle item for on/off state
class CNToolbarToggleItem extends CNToolbarItem {
  // ignore: public_member_api_docs
  const CNToolbarToggleItem({
    required super.id,
    super.tint,
    super.disabled,
    super.controlSize,
    this.label,
    this.systemSymbolName,
    required this.isOn,
    this.toggleStyle = CNToggleStyle.automatic,
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
  final CNToggleStyle toggleStyle;

  @override
  Map<String, dynamic> customProperties() {
    return {'label': label, 'systemSymbolName': systemSymbolName, 'isOn': isOn, 'toggleStyle': toggleStyle.name};
  }

  @override
  String get kind => 'toggle';
}

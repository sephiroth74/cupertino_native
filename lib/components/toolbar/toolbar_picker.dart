import 'package:flutter/cupertino.dart';

import '../../model/picker_style.dart';
import 'toolbar_item.dart';

/// A toolbar picker item for selecting from a list of options
class CNToolbarPickerItem extends CNToolbarItem {
  // ignore: public_member_api_docs
  const CNToolbarPickerItem({
    required super.id,
    super.tint,
    super.disabled,
    this.label,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.pickerStyle,
  });

  /// Callback when selection changes
  /// This is NOT serialized - it's stored locally for event handling
  final void Function(String)? onChanged;

  /// List of available options in the picker
  final List<String> items;

  /// Optional display label for this picker
  final String? label;

  /// Picker style (macOS specific)
  final CNPickerStyle? pickerStyle;

  /// Currently selected value
  final String? selectedValue;

  @override
  Map<String, dynamic> customProperties() {
    return {'label': label, 'items': items, 'selectedValue': selectedValue, 'pickerStyle': pickerStyle?.name};
  }

  @override
  String get kind => 'picker';
}

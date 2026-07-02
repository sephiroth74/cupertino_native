import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/painting.dart';

/// Base class for all toolbar items
abstract class CNToolbarItem {
  // ignore: public_member_api_docs
  const CNToolbarItem({required this.id, this.tint, this.disabled = false, this.controlSize = CNControlSize.regular});

  /// Control size for this item
  final CNControlSize controlSize;

  /// Whether this item is disabled
  final bool disabled;

  /// Unique identifier for this toolbar item
  final String id;

  /// Tint/accent color for this item
  final Color? tint;

  /// Convert to dictionary for native platform channel
  Map<String, dynamic> toMap() {
    return {'id': id, 'tint': tint, 'disabled': disabled, 'controlSize': controlSize.name, 'kind': kind, ...customProperties()};
  }

  /// Item kind (button, textField, search, picker, etc)
  String get kind;

  /// Override to add custom properties specific to subclass
  Map<String, dynamic> customProperties() => {};
}

import 'package:flutter/widgets.dart';

import 'view_modifiers.dart';

/// Single shared mixin to write common SwiftUI view modifiers into channel payloads.
mixin CNViewModifiable on Widget {
  /// Optional shared modifier bag for this view.
  CNViewModifiers? get modifiers => null;

  /// Backward-compatible `padding` accessor.
  EdgeInsets? get padding => modifiers?.padding;

  /// Backward-compatible `tag` accessor.
  Object? get tag => modifiers?.tag;

  /// Backward-compatible `enabled` accessor.
  bool get enabled => modifiers?.enabled ?? true;

  /// Backward-compatible `frame` accessors.
  double? get width => modifiers?.width;

  /// Backward-compatible `frame` accessors.
  double? get height => modifiers?.height;

  /// Writes all available shared modifiers into a method-channel payload.
  void writeModifiers(Map<String, dynamic> payload, BuildContext context) {
    modifiers?.writeToPayload(payload, context);
  }
}

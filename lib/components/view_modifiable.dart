import 'package:flutter/widgets.dart';

import 'view_modifiers.dart';

/// Single shared mixin to write common SwiftUI view modifiers into channel payloads.
mixin CNViewModifiable on Widget {
  /// Backward-compatible `padding` accessor.
  EdgeInsets? get padding => viewModifiers?.padding;

  /// Backward-compatible `tag` accessor.
  Object? get tag => viewModifiers?.tag;

  /// Optional shared modifier bag for this view.
  CNViewModifiers? get viewModifiers => null;

  /// Writes all available shared modifiers into a method-channel payload.
  void writeViewModifiers(Map<String, dynamic> payload, BuildContext context) {
    viewModifiers?.writeToPayload(payload, context);
  }
}

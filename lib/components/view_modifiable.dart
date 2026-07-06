import 'package:flutter/widgets.dart';

import 'view_modifiers.dart';

/// Single shared mixin to write common SwiftUI view modifiers into channel payloads.
mixin CNViewModifiable on Widget {
  /// Constraints forwarded to native frame handling.
  BoxConstraints? get constraints => modifiers?.constraints;

  /// Backward-compatible `enabled` accessor.
  bool get enabled => modifiers?.enabled ?? true;

  /// Backward-compatible frame accessor derived from tight constraints.
  @Deprecated('Use constraints or wrap widget with SizedBox.')
  double? get height {
    final c = modifiers?.constraints;
    if (c == null || !c.hasTightHeight) return null;
    return c.minHeight;
  }

  /// Optional shared modifier bag for this view.
  CNViewModifiers? get modifiers => null;

  /// Backward-compatible `padding` accessor.
  EdgeInsets? get padding => modifiers?.padding;

  /// Whether native side should use intrinsic sizing.
  bool get shrinkWrap => modifiers?.shrinkWrap ?? true;

  /// Backward-compatible `tag` accessor.
  Object? get tag => modifiers?.tag;

  /// Backward-compatible frame accessor derived from tight constraints.
  @Deprecated('Use constraints or wrap widget with SizedBox.')
  double? get width {
    final c = modifiers?.constraints;
    if (c == null || !c.hasTightWidth) return null;
    return c.minWidth;
  }

  /// Writes all available shared modifiers into a method-channel payload.
  void writeModifiers(Map<String, dynamic> payload, BuildContext context) {
    modifiers?.writeToPayload(payload, context);
  }
}

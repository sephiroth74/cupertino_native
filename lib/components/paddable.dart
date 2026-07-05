import 'package:flutter/widgets.dart';

import 'view_modifiable.dart';

/// Common contract for widgets that can carry SwiftUI `.padding(...)` values.
mixin CNPaddable on CNViewModifiable {
  /// Optional EdgeInsets serialized for native SwiftUI rendering.
  @override
  EdgeInsets? get padding;

  /// Adds serialized `padding` values to the channel payload when present.
  void writePadding(Map<String, dynamic> payload) {
    final value = padding ?? viewModifiers?.padding;
    if (value == null) return;

    payload['padding'] = {'top': value.top, 'leading': value.left, 'bottom': value.bottom, 'trailing': value.right};
  }
}

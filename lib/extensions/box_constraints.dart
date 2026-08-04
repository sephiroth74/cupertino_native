import 'package:flutter/widgets.dart';

/// Utility extensions for serializing and inspecting [BoxConstraints].
extension BoxConstraintsX on BoxConstraints {
  /// Returns the tight height when height is tightly constrained, otherwise null.
  double? get tightHeight {
    return hasTightHeight ? minHeight : null;
  }

  /// Returns the tight width when width is tightly constrained, otherwise null.
  double? get tightWidth {
    return hasTightWidth ? minWidth : null;
  }

  /// Converts constraints to a channel-friendly map.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    map['minWidth'] = minWidth.isNaN
        ? null
        : (minWidth.isFinite ? minWidth : "infinity");
    map['maxWidth'] = maxWidth.isNaN
        ? null
        : (maxWidth.isFinite ? maxWidth : "infinity");
    map['minHeight'] = minHeight.isNaN
        ? null
        : (minHeight.isFinite ? minHeight : "infinity");
    map['maxHeight'] = maxHeight.isNaN
        ? null
        : (maxHeight.isFinite ? maxHeight : "infinity");
    if (tightWidth != null && tightWidth!.isFinite)
      map['idealWidth'] = tightWidth;
    if (tightHeight != null && tightHeight!.isFinite)
      map['idealHeight'] = tightHeight;

    return map;
  }
}

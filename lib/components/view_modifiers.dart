import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

import '../channel/params.dart';

/// Shared modifier payload for SwiftUI-backed widgets.
class CNViewModifiers {
  /// Creates a shared modifier object that can be serialized for native SwiftUI views.
  const CNViewModifiers({
    this.tag,
    this.padding,
    this.controlSize,
    this.constraints,
    this.shrinkWrap = true,
    this.tint,
    this.foregroundColor,
    this.enabled,
  }) : assert(tag == null || tag is int || tag is String, 'Tag must be an int or String.');

  /// SwiftUI frame constraints applied when [shrinkWrap] is false.
  final BoxConstraints? constraints;

  /// SwiftUI `controlSize` identifier.
  final CNControlSize? controlSize;

  /// Enabled state forwarded to native views.
  final bool? enabled;

  /// Foreground color for native text/icon rendering.
  final Color? foregroundColor;

  /// SwiftUI `.padding(...)` value.
  final EdgeInsets? padding;

  /// If true, native view ignores frame constraints and uses intrinsic sizing.
  final bool shrinkWrap;

  /// SwiftUI `.tag(...)` value.
  final Object? tag;

  /// Tint color for native control rendering.
  final Color? tint;

  /// Backward-compatible height accessor derived from tight constraints.
  @Deprecated('Use constraints or wrap widget with SizedBox.')
  double? get height => constraints?.tightHeight;

  /// Backward-compatible width accessor derived from tight constraints.
  @Deprecated('Use constraints or wrap widget with SizedBox.')
  double? get width => constraints?.tightWidth;

  /// Serializes present modifiers into the outgoing method-channel payload.
  void writeToPayload(Map<String, dynamic> payload, BuildContext context) {
    if (tag != null) {
      payload['tag'] = tag;
    }

    if (padding != null) {
      payload['padding'] = {'top': padding!.top, 'leading': padding!.left, 'bottom': padding!.bottom, 'trailing': padding!.right};
    }

    if (controlSize != null) {
      payload['controlSize'] = controlSize!.name;
    }

    payload['shrinkWrap'] = shrinkWrap;

    if (constraints != null) {
      payload['constraints'] = constraints!.toMap();
    }

    if (enabled != null) {
      payload['enabled'] = enabled;
    }

    final tintArgb = resolveColorToArgb(tint, context);
    if (tintArgb != null) {
      payload['tint'] = tintArgb;
    }

    final foregroundArgb = resolveColorToArgb(foregroundColor, context);
    if (foregroundArgb != null) {
      payload['foregroundColor'] = foregroundArgb;
    }
  }
}

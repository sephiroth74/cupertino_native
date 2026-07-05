import 'package:cupertino_native/model/control_size.dart';
import 'package:flutter/widgets.dart';

import '../channel/params.dart';

/// Shared modifier payload for SwiftUI-backed widgets.
class CNViewModifiers {
  /// Creates a shared modifier object that can be serialized for native SwiftUI views.
  const CNViewModifiers({
    this.tag,
    this.padding,
    this.controlSize,
    this.width,
    this.height,
    this.tint,
    this.foregroundColor,
    this.enabled,
  }) : assert(tag == null || tag is int || tag is String, 'Tag must be an int or String.');

  /// SwiftUI `controlSize` identifier.
  final CNControlSize? controlSize;

  /// Enabled state forwarded to native views.
  final bool? enabled;

  /// Foreground color for native text/icon rendering.
  final Color? foregroundColor;

  /// Optional explicit height in logical pixels.
  final double? height;

  /// SwiftUI `.padding(...)` value.
  final EdgeInsets? padding;

  /// SwiftUI `.tag(...)` value.
  final Object? tag;

  /// Tint color for native control rendering.
  final Color? tint;

  /// Optional explicit width in logical pixels.
  final double? width;

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

    if (width != null) {
      payload['width'] = width;
    }

    if (height != null) {
      payload['height'] = height;
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

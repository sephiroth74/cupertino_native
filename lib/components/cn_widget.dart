// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:flutter/widgets.dart';

/// Base class for all new CN widgets that render via a native SwiftUI platform view.
///
/// Subclasses declare their own specific properties and implement [toPayload]
/// to serialize them for the native side. Shared concerns (constraints, padding,
/// shrink, tint, foregroundColor) are defined here.
abstract class CNWidget extends StatefulWidget {
  const CNWidget({super.key});

  /// Optional explicit constraints forwarded to native frame handling.
  BoxConstraints? get constraints;

  /// The foreground color to apply to the native view.
  Color? get foregroundColor;

  /// The native platform view type identifier (e.g. `"CupertinoNativeImage2"`).
  String get nativeViewType;

  /// Optional padding applied via SwiftUI `.padding(...)`.
  EdgeInsetsGeometry? get paddings;

  /// Whether the widget should shrink to fit its intrinsic content size.
  /// When false, the widget expands to fill its resolved constraints.
  bool get shrink;

  /// Optional tint color forwarded to native rendering.
  Color? get tint;

  /// Serializes the shared modifier fields into a payload map.
  /// Subclasses should call this from [toPayload] to include the common fields.
  Map<String, dynamic> writeSharedFields(
    BuildContext context, {
    required Map<String, dynamic> payload,
    required BoxConstraints? constraints,
  }) {
    payload['foregroundColor'] = resolveColorToArgb(foregroundColor, context);
    payload['tint'] = resolveColorToArgb(tint, context);
    payload['shrink'] = shrink;

    if (paddings != null) {
      final resolvedPadding = paddings!.resolve(Directionality.of(context));
      payload['paddings'] = {
        'top': resolvedPadding.top,
        'leading': resolvedPadding.left,
        'bottom': resolvedPadding.bottom,
        'trailing': resolvedPadding.right,
      };
    }

    if (constraints != null) {
      payload['constraints'] = {
        'minWidth': constraints.minWidth.isNaN ? null : (constraints.minWidth.isFinite ? constraints.minWidth : "infinity"),
        'maxWidth': constraints.maxWidth.isNaN ? null : (constraints.maxWidth.isFinite ? constraints.maxWidth : "infinity"),
        'minHeight': constraints.minHeight.isNaN ? null : (constraints.minHeight.isFinite ? constraints.minHeight : "infinity"),
        'maxHeight': constraints.maxHeight.isNaN ? null : (constraints.maxHeight.isFinite ? constraints.maxHeight : "infinity"),
      };
    }

    return payload;
  }
}
